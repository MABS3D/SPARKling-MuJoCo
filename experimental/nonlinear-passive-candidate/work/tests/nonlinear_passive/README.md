# Scalar polynomial elasticity and damping

Implemented for the smooth pipeline's hinge and slide joints, against MuJoCo
3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The latest stable
release was checked on 2026-09-27. Upstream sources:

- [Spring/damper forces](https://github.com/google-deepmind/mujoco/blob/3.14.0/src/engine/engine_passive.c)
- [Polynomial evaluation and derivative](https://github.com/google-deepmind/mujoco/blob/3.14.0/src/engine/engine_util_misc.c)
- [Euler implicit damping](https://github.com/google-deepmind/mujoco/blob/3.14.0/src/engine/engine_forward.c)

With `x = q - q_spring` and `a = abs(v)`:

```
spring = -x * ((k + k2*x) + k3*(x*x))
damper = -v * ((b + b2*a) + b3*(a*a))
implicit diagonal increment = h * ((b + (2*b2)*a) + (3*b3)*(a*a))
```

The two coefficients come from `jnt_stiffnesspoly` and `dof_dampingpoly` in
MJB; XML uses three values in `stiffness`/`damping`. The additions and products
retain the upstream floating-point evaluation order. Euler uses the derivative
at the current velocity, including when the linear damping coefficient is zero.
The existing spring, damper and Euler-damping flags remain effective.

Coefficients use the existing Tier0 domain (absolute value at most 1e10), with
nonnegative linear coefficients as before. Higher coefficients can be negative.
Initialization checks these bounds; an out-of-domain coefficient returns
`Invalid_Model` from `Create`. The MJB loader can reject it earlier with
`Invalid_Parameter` in its general model validation. Negative polynomial coefficients do not imply dissipativity or
positive effective inertia. The existing Strict rejection / Compatible pivot
policy still governs the solve. No universal stability claim is made.

The implementation adds no separate array traversal. Passive forces are evaluated
in the existing joint loop; the derivative is evaluated in the existing diagonal
update for both dense and ancestor solvers. The existing damping-presence search
now includes both polynomial coefficients. No per-step allocation is added.

This does not add free/ball joints, nonlinear tendons or actuator damping. Those
features remain outside this scalar-joint change.

## Isolation

This feature was developed in a separate worktree based on `677e7547`, to avoid
changing the active main-thread checkout. It does not include that checkout's
uncommitted external-force and gravity-guard work. It has not been merged or
pushed. Integration must preserve those concurrent changes.

## Validation

See `evidence-summary.json` and the archived evidence for final statuses. Proofs,
numerical differential tests and timings are separate claims. A timed-out proof
is unfinished engineering, not a Silver exception. Closed kernel contracts
specify exact floating-point formulas, not error bounds against real arithmetic.

The numerical suite includes mixed linear/polynomial terms, pure nonlinear
terms, signed coefficients, zero and negative velocities, scalar and branched
models, a 12-DOF chain, flag combinations and 100-step trajectories. Both Strict
and Compatible modes use the normal MuJoCo 3.14 C oracle. The scalar boundary
suite directly calls C `mju_polyForce` and `mjd_xPolyForce` and checks exact
floating-point equality, including the limits of the admitted domain.

`benchmark.py` measures complete Euler trajectories, not just the new kernel.
Input preparation and output formatting are outside the timed interval; every
trajectory's final state is checked against C. Release Ada uses GNAT 16.1 with
O3, native ISA, LTO and disabled runtime assertions; floating-point contraction
is off. C uses the pinned normal library with its SIMD paths. The manifest
records flags, compiler versions, CPU, hashes and C library identity.

Each case uses three initial states and 18 blocks, eight trajectories of 100
steps per block after three warmups. Variant order is rotated and reversed.
Confidence intervals bootstrap paired block ratios. Workload ratios are reported
separately; there is no average of unrelated percentage changes. Background
activity can affect these measurements and is documented with the evidence.

## Reproduction

Run from the repository root using a Python environment with MuJoCo 3.14 and
NumPy. Use fresh report directories.

```
python tests/nonlinear_passive/make_fixtures.py
python experimental/smooth/tools/compare_numerics.py \
  --toolchain-root TOOLCHAINS --report-dir REPORT --samples 24 \
  --extra-fixtures tests/nonlinear_passive/fixtures --policy Compatible
python tests/nonlinear_passive/check_kernels.py \
  --toolchain-root TOOLCHAINS --out SCALAR_REPORT
python tests/nonlinear_passive/benchmark.py --out BENCH --build \
  --toolchain-root TOOLCHAINS --c-library LIBMUJOCO
python tests/nonlinear_passive/benchmark.py --out BENCH --cpu 12 \
  --blocks 18 --session session1
```

Repeat the numerical command with `--policy Strict`; `--probe` can reuse the
checked executable from its first report. Start GNATprove at the individual
subprograms of `mj-nonlinear_passive` before its integration callers.

## Integrated measurements on the isolated feature branch

Final release session: 18 paired blocks per initial state, three states per model.
Other proof/build work was active on the host; these are diagnostic measurements,
not a quiet-machine performance acceptance. The baseline is commit `677e7547`,
not the concurrent main-thread working tree.

| Workload | Ada/C time ratio across states | Interpretation |
| --- | ---: | --- |
| hinge_motor | 0.723–0.728 | faster than C in this session |
| slide | 0.760–0.802 | faster than C in this session |
| branched_multijoint | 0.932–0.956 | faster than C in this session |
| chain_12 | 1.257–1.318 | slower than C |
| nonlinear_hinge_motor_both | 0.691–0.708 | faster than C in this session |
| nonlinear_slide_both | 0.784–0.815 | faster than C in this session |
| nonlinear_branched_multijoint_both | 0.907–1.010 | some uncertainty intervals overlap parity |
| nonlinear_chain_12_both | 1.270–1.363 | slower than C |
| nonlinear_chain_12_pure | 1.265–1.293 | slower than C |

All timed final states passed the C differential check; maximum absolute error
was 3.11e-15. The 12-DOF chain remains slower.
The performance requirement is **not met for every workload**. The initial pilot
also showed the chain slower; its build manifest is retained separately.
The change must not be presented as establishing general C performance parity.

## Formal proof closure

12 selected distinct scopes closed, 195 emitted proof checks. 2 scopes remain pending. Duplicate declarations/bodies are counted once.

| Subprogram | Result | Checks | Report |
| --- | --- | ---: | --- |
| `mj-nonlinear_passive.adb:Polynomial` | completed_no_unproved | 12 | kernels3 |
| `mj-nonlinear_passive.adb:Damping_Derivative` | completed_no_unproved | 11 | kernels3 |
| `mj-nonlinear_passive.adb:Force_Component` | completed_no_unproved | 4 | kernels3 |
| `mj-nonlinear_passive.adb:Damper_Component` | completed_no_unproved | 6 | kernels3 |
| `mj-nonlinear_passive.adb:Passive_Force` | completed_no_unproved | 8 | kernels3 |
| `mj-data.adb:Joint_Element` | completed_no_unproved | 31 | integration |
| `mj-data.adb:Dof_Element` | completed_no_unproved | 23 | integration |
| `mj-data.adb:Read_Joint_Config` | unproved_checks | 79 | reader-final |
| `mj-data-forces_phase.adb:Passive_Buffers` | completed_no_unproved | 39 | integration |
| `mj-data-inertia_phase.adb:Damping_Present` | completed_no_unproved | 21 | integration |
| `mj-data-inertia_phase.adb:Load_Ancestor_Buffers` | completed_no_unproved | 17 | integration |
| `mj-data-inertia_phase.adb:Solve_Strict_Buffers` | unproved_checks | 51 | strict-final |
| `mj-data-inertia_phase.adb:Solve_Workspace` | completed_no_unproved | 4 | integration |
| `mj-data-inertia_phase.adb:Solve` | completed_no_unproved | 19 | solver3 |

The kernel report concerns the final scalar source. Intermediate integration
reports retain their exact source snapshots; later reports supersede failed
trials where listed. The complete dynamics proof is not claimed.
