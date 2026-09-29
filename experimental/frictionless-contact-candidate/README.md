# Frictionless plane–sphere contact: scalar candidate

This separate candidate implements detection → constraint assembly → normal
force → acceleration → semi-implicit Euler for **one sphere on one vertical
slider above one fixed horizontal plane**. It reuses `MJ.Collision.Plane_Sphere`.
It is not connected to `MJ.Data`, the generic smooth pipeline, or `mj_step` in
the port. Running the main engine does not enable this contact solver.

Reference: [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0),
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Six relevant source files were
checked against that official commit and the local native reference. See
`results/reference.json` for hashes. Latest stable release was checked on
2026-09-29. Source provenance is retained in `NOTICE.md`.

## Verified results (2026-09-29)

- Complete-unit proofs: **404 checks, zero unproved, zero warnings**, comprising
  226 for `MJ.Contact_Rows`, 72 for `MJ.Contact_Slider`, and 106 for the reused
  `MJ.Collision`. All 29 new runtime/model subprograms are covered. The 29
  minimal-subprogram diagnostic runs passed before the complete-unit runs.
- **751 cases and 9,012 scalar comparisons per build**, passing independently
  in development, validation and release; 2 additional atomic-rejection cases
  pass per build. Counts/statuses match exactly. Largest scaled numeric error
  `abs(Ada-C)/(1+abs(C))` is 7.43e-15. The largest raw force difference is
  1.91e-6 in large-force cases; it is not a universal absolute-error bound.
- Sources stayed unchanged across the final proofs, builds, numerical tests
  and performance runs. Matching hashes, commands and full reports are retained
  in [the summary](results/summary.json) and [evidence archive](results/contact-evidence.zip).
  The [property ledger](verification.md) defines the functional assurance scope.

Two runs on an AMD Ryzen 7 9800X3D under WSL/Linux, pinned to CPU 12, each use
21 alternating C/Ada pairs per fixture. Each sample averages eight 1,000-step
trajectories; two warmup trajectories precede them. Times below are median CPU
nanoseconds per step, shown as run 1 / run 2. All paired-ratio 95% bootstrap
intervals favor this scalar specialization; raw samples, MAD and sample-average
p95 timings are preserved. Timed paths were verified after each trajectory.
No previous Ada contact implementation existed to supply a port baseline.

| Trajectory | Scalar Ada, ns/step | General C `mj_step`, ns/step |
|---|---:|---:|
| Fall, impact, rest | 19.42 / 19.43 | 1046.2 / 1051.7 |
| Resting | 22.19 / 22.19 | 1161.5 / 1119.6 |
| Detaching | 1.53 / 1.53 | 516.4 / 523.3 |
| Free flight | 1.52 / 1.51 | 518.8 / 530.1 |

These timings compare a fixed one-dimensional implementation with the full C
engine. They demonstrate low cost for this candidate, **not general MuJoCo
parity or a speedup for arbitrary contacts/multi-DOF models**. C's normal AVX
paths are enabled; compiler/reference flags and library hashes are recorded in
`results/reference-build-environment.json` and the archived build receipts.

## Physical scope

The sphere is centered at its body's center of mass; its sole coordinate is
world height, the slider axis is +Z, and the plane normal is +Z. Consequently
`J = 1`, `M = mass`, and the C simple-body inverse weight is `1/mass`. Gravity
and an externally applied generalized force are included. Mass/radius are
strictly positive. No heap allocation occurs in the candidate step.

Contact has `condim=1`: only a compressive normal force, no tangential force,
torsional friction, or rolling friction. Standard positive `solref`, `refsafe`
clamping, and the quadratic `solimp` shape (`power=2`) are supported. Inputs
are already normalized to their documented typed domains; this API is not an
XML loader or arbitrary-byte validator.

The MuJoCo 3.14 collision threshold is `margin + gap`. A detected contact
becomes an active constraint only when `distance < margin`; equality is
excluded. A detected contact need not produce a nonzero force. In particular,
separating bodies can have a positive geometric overlap but zero normal force.

This is MuJoCo's regularized soft contact. Equilibrium penetration is expected.
For mass 2 kg, radius 0.1 m, gravity −9.81 m/s² and default parameters, a drop
settles near height 0.099632818 m with reaction 19.62 N. It does not enforce
perfect rigid nonpenetration or a separate hard-bounce rule.

Still absent from this candidate: arbitrary articulated bodies and Jacobians,
coupled/multiple contacts, tangential friction cones, joint limits, equality
constraints, adhesion, actuator dynamics, damping/springs/armature, tendon and
flex contacts, parameter mixing, general solimp powers, negative/direct solref,
implicit/discrete solref, islands, warm starts, and the generic iterative solvers.

## Minimal use

```ada
C : constant MJ.Contact_Slider.Configuration := (Mass => 2.0, others => <>);
S : MJ.Contact_Slider.State := (Height => 0.3, others => <>);
E : MJ.Contact_Slider.Evaluation;
Result : MJ.Contact_Slider.Status;
--  Call in a loop, handling Numeric_Limit before advancing further:
MJ.Contact_Slider.Step (C, S, Applied => 0.0, E => E, Result => Result);
```

## Scalar equations and C mapping

`MJ.Contact_Rows` preserves the C arithmetic order for stiffness/damping,
impedance, regularization and reference acceleration. Let `i` be impedance,
`w=1/m`, `a0=((m*g)+applied)*w`, and `p=distance-margin`:

```
R    = max(1e-15, ((1-i)*w)/i)
aref = (-B*v) - ((K*i)*p)
AR   = w + R
f    = max(0, 0 - (a0-aref)*(1/AR))
a    = a0 + f*w
v'   = v + h*a
z'   = z + h*v'
t'   = t + h
```

The unilateral scalar minimizer replaces iteration only because there is
exactly one independent constraint. General multi-contact solving is not a
sequence of independent applications of this formula.

| Candidate operation | C reference |
|---|---|
| Plane–sphere geometry and activation | `engine_collision_primitive.c`, `engine_collision_driver.c` |
| Quadratic impedance, K/B, R and aref | `getimpedance`, `mj_makeImpedance`, `mj_referenceConstraint` in `engine_core_constraint.c` |
| Inverse mass/weight for a simple slider body | `engine_setconst.c` |
| Diagonal scalar constrained solve | `mj_projectConstraint`, `mj_solPGS` |
| Smooth acceleration and Euler update | `mj_fwdAcceleration`, `mj_EulerSkip` in `engine_forward.c` |

There is an intentional floating-point distinction: C forms its projected
matrix using `Y = J M^(-1/2)` and `Y Yᵀ + R`; the scalar candidate uses `1/m + R`.
These can round differently. C's iterative PGS stopping rule also differs from
the closed scalar solution. Differential tests use explicit tolerances; they
are not a universal proof of bitwise equivalence with C.

## API, contracts and rejection

- `MJ.Contact_Rows.Assemble` computes a complete scalar constraint row.
- `MJ.Contact_Slider.Evaluate` detects contact and evaluates the row without
  advancing time or modifying the input state.
- `MJ.Contact_Slider.Step` computes one complete step. Diagnostics describe the
  state before integration, matching C's step outputs.

`State` height/velocity have bounds ±1e10 and time has bounds [0, 1e10]. The
configuration and intermediate types expose their separate bounds in the
specifications. `Numeric_Limit` rejects a detection margin outside the existing
collision primitive's domain, an impedance outside the checked positive range,
or an Euler result outside the state domain. A rejected step preserves **all
three state fields**. `Evaluation.Result` reports evaluation status; the separate
`Step` result also covers integration failure. `Row.Accepted` is relevant only
when `Diagnostics.Active` is true.

Exact ghost specifications cover the stated floating-point operations, branch
choices, defaults, full row assembly, complete evaluation, accepted-step
conditions, integration results and atomic rejection. Models do not call the
runtime implementations. Expression-body hiding is proof decomposition; each
hidden expression body is separately verified. No assumptions or suppressed
proof obligations are introduced. Static ghost contracts incur no release cost.

These contracts do not prove a universal forward-error bound, a real-arithmetic
complementarity residual, long-time stability, or correctness of MuJoCo itself.
The positive impedance guard remains because the current proof uses a coarse
bound for the rounded sigmoid; no admissible differential case triggered it.

## Reproduction and evidence

Linux/WSL toolchains and reference paths are configurable through the GPR
external variables and the build script. Defaults point to this machine's
existing toolchains and MuJoCo reference; no downloads occur in these runners.
Use a Python environment with MuJoCo 3.14.0 and NumPy for numeric/measurement
scripts. From the repository root, with a fresh output directory:

```sh
python3 experimental/frictionless-contact-candidate/tests/prove.py --out /tmp/contact-proof --phase all
python3 experimental/frictionless-contact-candidate/tests/build.py --out /tmp/contact-build --mode validation
python3 experimental/frictionless-contact-candidate/tests/compare.py --binary /tmp/contact-build/validation/bin/contact_probe --out /tmp/contact-numeric
python3 experimental/frictionless-contact-candidate/tests/build.py --out /tmp/contact-build --mode benchmark
python3 experimental/frictionless-contact-candidate/tests/measure.py --binary /tmp/contact-build/benchmark/bin/contact_bench --out /tmp/contact-perf/session.json --cpu 12
```

Development (`-O0`, checks), validation (`-O2`, checks), and release (`-O3`, no
checks, native/LTO) use FMA contraction disabled. The proof runner starts with
individual subprograms and then proves complete units. Final acceptance must
use unchanged source hashes and fresh complete-unit reports; diagnostic failures
are not accepted as evidence.

The numerical corpus checks contact/constraint counts exactly and 12 numeric
outputs with absolute/relative tolerance 2e-10, including threshold neighbors,
impedance branches, forces, 400 seeded random cases and long trajectories.
Independent checks cover free fall, static force balance, separating contact
and atomic rejection. Tolerance is a test criterion, not a proved error bound.

Performance compares full scalar trajectories against the native C `mj_step`
on the same one-body model. Input preparation, model loading and output checks
are outside timing; each timed trajectory is checked after execution. Ada's
fixed scalar configuration setup is inside its timed call. Alternating paired
samples report CPU/wall times, dispersion and bootstrap confidence intervals.
Reported p95 is a percentile of sample-average time per step, not individual
step latency. This measures a specialized candidate versus a general engine;
it cannot establish general simulator parity or a benefit on multi-DOF scenes.

The existing native C reference uses finite-math optimizations. Its XML compiler
fails its NaN self-test, so the harness loads an MJB generated outside timing by
the version-matched Python MuJoCo package. It does not disable the self-test or
modify the reference library. Native dynamics are checked for every benchmark
trajectory, and both reference-library identities are recorded in the evidence.
