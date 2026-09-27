# Fluid-force candidate — isolated from the active smooth implementation

Status: implemented and numerically validated, **not ready for Gold adoption**.
The full fluid-stage proof is open. Performance is better than C on several
integrated workloads, while the chain24 and fluid-disabled cases remain
inconclusive. No universal parity claim is made.

This directory was produced in a side conversation. The live
`experimental/smooth/src` files and Git state were not replaced. `work/` is a
self-contained source snapshot with the candidate applied. `fluid.patch` is
relative to the source snapshot captured at the beginning of this work;
`changes.json` records both base and candidate hashes. Do not apply it blindly
over concurrent edits. No branch was committed, merged or pushed.

## Implemented scope

Reference: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The official latest-release API was
checked on 2026-09-27 and returned 3.14.0. Reviewed `engine_passive.c`:
`mj_fluid`, `mj_inertiaBoxFluidModel`, `mj_ellipsoidFluidModel`,
`mj_addedMassForces`, `mj_viscousForces`; also `mju_geomSemiAxes`.

Both supported fluid models are implemented in the scalar hinge/slide,
unconstrained Euler pipeline:

* Inertia-box viscous force/torque and quadratic drag.
* Geometry ellipsoids: Stokes drag, quadratic drag, angular drag, Magnus lift,
  Kutta lift, and velocity-dependent added mass/inertia terms.
* World-frame wind transformed into each local fluid frame.
* Geometry interaction coefficients and sphere/capsule/cylinder/ellipsoid/box
  semi-axis conventions. Zero-interaction geometries are skipped.
* A positive ellipsoid interaction on any geometry replaces the inertia-box
  model for the owning body, matching C. Bodies below `mjMINVAL` mass are skipped.
* Fluid loads join passive forces before the acceleration/Euler solves, and
  coexist with motor, gravity, bias, spring/damper, generalized and Cartesian
  external forces. Both spring and damper disabled also skips fluids, matching C.
* Geometry-local positions/orientations, body COM offsets, multiple geometries,
  welded descendants and massless fixed carriers are exercised by tests.

As in C's forward fluid call, the acceleration-dependent added-mass term is not
included: C passes a null acceleration pointer. The candidate does not extend
joint support to ball/free, add contacts, flex, tendons, sleeping or other
features excluded by the existing smooth pipeline.

## Implementation and cost

`mj-fluid_box` specifies and proves the ordered floating-point box formulas,
with coefficients prepared once. `mj-fluid_added_mass` separates momentum and
cross-product arithmetic. `mj-fluid_kernels` contains ellipsoid preprocessing,
lift/drag and ordered force composition. `mj-data-fluid_phase` owns the copied
fluid metadata and accumulation into passive force.

Dimensions, coefficient products and the mass reciprocal are prepared during
Create. Inertial rotations and RNE body velocities are reused when available;
the dense/small-model fallback constructs body velocities. Disabled fluids have
an early exit. Temporary fallback arrays have zero length on the reuse path.

Fluid wrenches are accumulated once along the body tree and projected onto each
scalar joint, rather than projecting every geometry separately through all its
ancestors. The hot traversal is O(nbody + njoint + active fluid elements), excluding
the existing mass/solver cost. The reversed summation order and reconstructed
root-frame offsets change floating-point rounding: the tests establish numerical
agreement, not bitwise identity or a universal equivalence proof.

Metadata is owned by the simulation and survives freeing the source model.
Free releases it. Configuration snapshots include the fluid metadata. No new
assumptions, check suppressions or SPARK_Mode-Off implementation bodies were
introduced. Release measurements use the project's existing `-gnatp` policy;
that policy is not a proof of the newly added stage.

## Validation

Final source: Strict and Compatible each pass 816 scenarios / 132,072 numeric
comparisons (1,632 scenarios / 264,144 comparisons total), with fluids and external
Cartesian loads together. Tolerance is `2e-10 + 2e-10*abs(reference)`.
The suite includes 53 fluid fixtures plus 15 existing fixtures, zero/tiny wind,
resting states, 100-step trajectories, 24-DOF chains/stars/forests, combined
external loads, lifecycle and error-policy checks. The final checked executable
is identified by hash in `summary.json`; all final release trajectories were
also checked against C before accepting their timings.

Seven box subprograms close 131 proof obligations with zero open checks, on the
final source, following the smallest-subprogram-first workflow. A whole-unit
run timed out and must not be described as passed. Momentum and Cross_Term
close another 14 checks; Blend_Force and Blend_Torque close 20. These latter
results are component properties, not a proof of the complete ellipsoid model.

Still open: full added-mass composition, ellipsoid geometric/lift expressions,
metadata construction/lifecycle, velocity reuse and wrench traversal, and their
caller contracts. Earlier dynamics proofs refer to earlier source snapshots and
do not transfer automatically to this candidate. These are unfinished proof
engineering tasks, not documented mathematical exceptions granting Silver.

## Integrated performance

Two sessions; each uses 13 models, three states/model, 24 alternating Ada/C
blocks, four measured 100-step trajectories per invocation and two warmups.
Input creation, resets and output checks are outside the timed step loop. CPU
12 on Ryzen 7 9800X3D; native GNAT/GCC 16.1; C uses the pinned native SIMD build.
Exact flags, executable/library hashes, raw trajectories, per-state median/MAD,
p95 and bootstrap intervals are in the evidence archive.

Other proof work was running on the host during this investigation. Results
are exploratory. Ranges below span the six state/session medians, not pooled
averages and not confidence intervals. **Ratio = Ada time / C time; lower is
better.** Individual paired-block bootstrap 95% intervals are retained. An
interval containing 1 does not prove parity or absence of regression.

| Model | DOFs | Ada/C median range | Every per-state/session CI below 1? |
|---|---:|---:|---|
| fluid_box_branched_multijoint_wind | 5 | 0.793–0.811 | Yes |
| fluid_box_branches24 | 24 | 0.940–0.978 | No |
| fluid_box_chain24 | 24 | 0.997–1.038 | No |
| fluid_box_chain_12_wind | 12 | 0.914–0.949 | Yes |
| fluid_box_hinge_motor_wind | 1 | 0.663–0.685 | Yes |
| fluid_box_star24 | 24 | 0.907–0.956 | No |
| fluid_ellipsoid_branches24 | 24 | 0.913–0.967 | No |
| fluid_ellipsoid_chain24 | 24 | 0.968–1.019 | No |
| fluid_ellipsoid_ellipsoid_all | 3 | 0.786–0.821 | Yes |
| fluid_ellipsoid_multiple | 3 | 0.726–0.741 | Yes |
| fluid_ellipsoid_sphere_all | 3 | 0.789–0.817 | Yes |
| fluid_ellipsoid_star24 | 24 | 0.887–0.923 | No |
| fluid_flags_both_off | 3 | 0.971–1.041 | No |

The explicit performance requirement is therefore not yet closed for every
workload. Repeat in a quiescent environment and resolve reproducible residual
slowdowns before adopting. No unweighted average or count of faster cases is
used as an overall performance result. A pre-fluid implementation cannot run
nonzero-fluid models; the saved original source is for patch provenance, not a
numerically equivalent loaded-workload timing baseline. A separate no-fluid
baseline regression measurement remains pending.

## Reproduction on this workstation

Use `/var/tmp/sparkling-movement-env/bin/python` (MuJoCo 3.14.0 and NumPy) and
`/var/tmp/sparkling-matrix-recovery/toolchains`. From this directory:

```sh
/var/tmp/sparkling-movement-env/bin/python work/experimental/smooth/tools/compare_numerics.py --repo work --report-dir /var/tmp/fluid-check --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --extra-fixtures fixtures --samples 12 --external --policy Strict
python3 work/experimental/smooth/tools/prove_fragments.py --repo work --report-dir /var/tmp/fluid-box-proof --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --unit mj-fluid_box --name Viscous_Linear --name Viscous_Angular --name Drag_Linear --name Drag_Angular --name Component --name Prepare --name Evaluate --provers cvc5,z3,altergo --prover-seconds 5 --steps 0 --jobs 2 --cap-mb 3000 --wall-seconds 130 --prepare-seconds 130 --total-seconds 900
/var/tmp/sparkling-movement-env/bin/python tools/build.py replay-build
/var/tmp/sparkling-movement-env/bin/python tools/measure.py replay-build replay-measurements 24
```

Use a fresh report/build directory for each run. Proofs were run with a 64 MiB
stack (`ulimit -s 65536`). The standalone build tools preserve source snapshots
and keep output away from the active implementation. `evidence.zip` preserves
final numerical results, proof reports (including timeouts), performance records,
source manifests and reference metadata. `SHA256SUMS` covers the supplied bundle.
