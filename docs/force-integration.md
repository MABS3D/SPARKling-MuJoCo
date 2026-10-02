# Force integration into the active smooth engine — 2026-10-02

The active `experimental/smooth` engine now combines activation, standard joint
muscles, fluids, fixed tendons and spatial tendons with ball/free joints.
This is a working integration into owned Model/Data, Forward and Euler, not just
another copy of the independent candidates. The complete requested scope is not
finished: advanced actuator blocks/transmissions, adhesion and flex remain open.
Whole-pipeline Gold and performance parity with C are not established.

Reference: official [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0),
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; the stable release was checked
on 2026-10-02. C differential tests use the official 3.14.0 Python distribution.
The implementation follows the activation/force ordering in
[engine_forward.c](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_forward.c),
tendon routing and armature in
[engine_core_smooth.c](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_core_smooth.c),
and fluid forces in
[engine_passive.c](https://github.com/google-deepmind/mujoco/blob/9ecbb9d7b5ee623f54745638d36799ff90e6f7cd/src/engine/engine_passive.c).

## Integrated behavior

| Area | Active scope |
|---|---|
| Activation | Owned state, integrator/filter/filterexact, limits, control clipping, actearly, enable flag, reset and Euler commit |
| Muscles | Muscle dynamics + gain + bias together, joint/jointinparent hinge/slide/ball/free transmissions, copied calibration/length range and parameters |
| Fluids | Inertia-box and ellipsoid drag, viscosity, wind, lift and added-mass terms; geometric metadata prepared at creation |
| Fixed tendons | Ordered length, sparse velocity, repeated joints, linear/polynomial spring and damping, fixed armature, and mixtures with spatial tendons |
| Spatial tendons | Existing sphere/cylinder/pulley paths now accept models with ball/free joints; velocity Jacobians remain indexed by `nv` |

Muscles and the three basic activation kinds can coexist with stateless motors.
The loader retains separate control and activation addresses and owns all the
configuration: tests free the source model immediately after creation. The
simple scalar path remains available; a cached `Has_Muscles` flag selects the
more general force path only when needed. Configuration invariants tie that
flag and activation indices to the owned actuator metadata.

`Activation_Count`, `Activation_Values`, `Activation_Rates` and `Set_Activation`
expose the additional state. The existing `State_Values` layout remains
`[qpos,qvel,time]`; `Complete_State_Values` also includes activation. A rejected
Euler update leaves position, velocity, activation and time unchanged. With
actearly disabled, Forward may succeed using the current activation even when
the prospective next activation is outside the supported domain; Euler then
rejects the state transition. Enabling actearly rejects that force evaluation.

Fixed tendons retain two different reductions: length follows the original
wrap order, while velocity follows C's sparse four-lane reduction, including
zero slots for duplicate joint columns. Only tendon CSR permits nondecreasing
columns; mass and the other CSR structures retain strict ordering. The ordered
armature products are cached at model creation. They update only C's existing
reduced mass pattern, including its omission of cross-branch entries, and write
both entries of the public symmetric matrix. Different tendons' additions are
not regrouped. Fixed-only models avoid construction of spatial body Jacobians.
A fixed tendon still references scalar hinge/slide joints; ball/free joints may
coexist elsewhere, so position and velocity addresses can differ.

Fluid accumulation reuses body velocities produced by the recursive force pass
when available. The fallback constructs them once. Body wrenches are projected
by reverse traversal of the body tree. The phase is skipped when the model has
no fluid elements. Existing explicit numerical limits and failure statuses are
retained; bounded-domain agreement does not imply support for every C input.

## Numerical evidence

The frozen [evidence index](../experimental/smooth/results/20261002-force-integration/index.json)
records the actual probe hashes, source snapshots and commands. The archives
contain input/output, model XML/MJB, build logs and proof diagnostics. Counts
below are suites, not a count of distinct models across all runs.

| Suite | Result |
|---|---|
| Final mixed muscles/activation + fixed/spatial tendons + ellipsoid fluids + hinge/slide/ball/free | 1,152 scenarios, 72,576 comparisons passed |
| Mixed activation/muscles/spatial tendons + inertia-box fluids, Strict policy | 1,152 scenarios, 43,776 comparisons passed |
| Activation options, Strict policy | 432 scenarios, 3,456 comparisons passed |
| Activation edge/capacity cases | 46 passed, including 1,024 states |
| Activation failure atomicity, final probe | 4 passed |
| Large fixed-tendon spring/damper cancellation, final probe | Passed the checked projection fallback against C |
| Fixed-tendon C regression plus scalar baseline | 208 scenarios, 30,904 comparisons passed; final rebuild reran 104 scenarios/15,452 comparisons |
| Fluid candidate fixtures plus baseline | 408 scenarios, 68,088 comparisons passed |
| Manifold regression | 432 scenarios, 48,640 comparisons passed |
| Spatial tendon regression | 320 scenarios, 21,944 comparisons passed |
| Quaternion boundaries / capacity | 32 boundaries passed; 280 coordinates / 210 DOFs passed |

Mixed tests compare initial acceleration, mass, passive force, actuator force,
projected force, transmission length/velocity and activation derivative, then
position, velocity, activation and time after 1 or 100 steps. They include
Cartesian body loads, activation limits, actearly, global actuation disabling,
control-clamp disabling and nontrivial activation addresses. Builds use
`-O0 -gnata -gnato -gnatVa -ffp-contract=off`. Tolerance is
`2e-10 + 2e-10*abs(reference)`. Unsupported feature checks and source-model
lifetime checks also pass. These tests are not universal equivalence proofs.

## Formal evidence and remaining obligations

Proofs start at small subprograms, with explicit time/memory limits. No new
`Assume`, skipped proof body, suppression or trusted application body was added.
Existing deallocation patterns are retained. A successful scoped proof uses the
contracts of callees; it does not close the whole engine or real-number accuracy.

| Target | Fresh evidence |
|---|---|
| Activation derivative/raw update/limited update/preparation | Selected subprograms pass |
| `MJ.Activation`, whole unit | 24/25 checks; runtime Exp boundary remains open |
| `Compute_Activated` | 81 checks, none open |
| `MJ.Muscle_Actuation`, whole unit | 24 checks, none open |
| `MJ.Muscle_Kernels` | Whole run: 299/301; the two diagnostics then close in `Optimal_Length` (6 checks) and `Bias` (21 checks) on unchanged sources |
| `MJ.Fluid_Transport`, whole unit | 71 checks, none open |
| Fixed `Dot` / `Fixed_Kinematics` | 25 / 10 checks, none open |
| Tendon mass pair / ordered mass accumulation | 33 / 22 checks, none open; functional update and symmetry included |
| `MJ.Tendon_Kernels` | Whole run: 395/397; spring-model equality then closes scoped. The sparse-reduction assertion remains open |

The index includes any later scoped follow-up results separately. Full closure
of the new loaders, the reused RNE velocity buffer, manifold muscle actuation,
fluid/passive accumulation and Euler composition remains pending. The full
fluid kernel set was not reproved in this integration run. Solver timeouts and
missing caller invariants are unfinished proof engineering, not mathematical
exceptions authorizing a Silver completion claim.

## Complete-step performance

The benchmark runs 64-step trajectories with reset, input preparation and state
readback outside timing. It checks the final state checksum against C, including
activation. There are 12 alternating paired blocks after one warmup block,
256 trajectories per block, on one logical CPU in a shared host. Raw wall/CPU
samples, p95 trajectory timings, compiler/CPU information, source hashes and
paired bootstrap intervals are retained in `performance.json`.

| Workload | Ada µs/step | C µs/step | Paired Ada/C | 95% interval |
|---|---:|---:|---:|---:|
| Slide + integrator | 0.421 | 0.488 | 0.868 | 0.773–0.957 |
| Ball + exact filter + spatial tendon | 1.072 | 0.984 | 1.114 | 1.025–1.137 |
| Free + muscle + spatial tendon | 1.197 | 1.048 | 1.169 | 1.036–1.231 |
| Slide + muscle + fixed/spatial tendons + fluids | 1.319 | 1.255 | 1.055 | 1.036–1.152 |
| Ball + muscle + fixed/spatial tendons + fluids | 1.797 | 1.500 | 1.167 | 1.142–1.232 |
| Free + exact filter + fixed/spatial tendons + fluids | 1.986 | 1.639 | 1.214 | 1.144–1.225 |

These workloads have disabled constraints. This session establishes neither
aggregate parity nor broad performance superiority. Dense body Jacobians and
spatial-path validation still differ from C; their individual contributions
were not isolated by this benchmark. Newly supported models have no equivalent
pre-integration Ada baseline. Historical candidate timings are not substituted
for full-step timings.

The diagnostic release profile uses `-O3 -gnatp -gnatn -march=native -flto`, with
FP contraction disabled. The C driver links the official wheel with normal
SIMD; internal wheel compiler flags are not independently controlled. The checked
default build stays enabled. Because composition proofs remain open, the
unchecked benchmark profile is not declared a fully verified production build.

## Work still required for the requested scope

1. Advanced actuation: replace the one-control/one-output layout restriction
   with owned input/output/activation blocks and connect PID/DC/SO3 and their
   state updates, antiwindup, exact updates, clipping and SO3 reanchoring.
2. Transmissions: site/refsite, slider-crank and tendon rows, including inherited
   damping/armature and aggregate force limits. Mixed general muscle laws also
   remain unsupported.
3. Adhesion: connect body actuators to contacts and normal Jacobians before
   constraint solution, including gap contacts, contact averaging and cone
   layouts. The general smooth entry has no contact producer.
4. Flex/materials: load flex topology and compiled elastic metrics, map vertices
   to articulated bodies, accumulate elastic/bending forces and connect flex
   collision/constraints. Material and elastic candidates alone do not supply
   these lifecycle and geometry producers. Contact materials are already used
   by the separately developed constrained entry; that is outside this change.
5. Spatial armature/Jdot, tendon constraints, remaining composition proofs and
   equivalent integrated performance measurements as each scope is expanded.

The separate `experimental/constrained-step` entry has its own explicit scope;
this smooth integration does not automatically enable activation, adhesion or
flex there. Its concurrently developed files were not edited by this work.

## Reproduction

Run from the repository root using Python with MuJoCo 3.14.0 and NumPy. Output
directories must be new. Substitute the actual toolchain and resulting probe
paths:

```sh
python experimental/smooth/tools/compare_numerics.py --report-dir /tmp/forces-build --toolchain-root /path/to/toolchains --samples 8
python experimental/smooth/tools/test_actuation_integration.py --probe /path/to/smooth_probe --out /tmp/forces-mixed --fixed --fluid ellipsoid
python experimental/smooth/tools/test_actuation_integration.py --probe /path/to/smooth_probe --out /tmp/forces-box --fluid box --policy Strict
python experimental/smooth/tools/test_manifolds.py --out /tmp/forces-manifolds --toolchain-root /path/to/toolchains
python experimental/smooth/tools/benchmark_force_integration.py --out /tmp/forces-timing --toolchain-root /path/to/toolchains --batches 256 --blocks 12
python3 experimental/smooth/tools/prove_fragments.py --source-dir experimental/spatial-tendon-candidate/src --unit mj-spatial_tendon_models --name Store_Mass_Pair --name Add_Mass --toolchain-root /path/to/toolchains --report-dir /tmp/forces-mass-proof --provers cvc5,z3,altergo --prover-seconds 5 --steps 0 --wall-seconds 90 --prepare-seconds 90 --total-seconds 230
```

Provenance: activation from `adhesion-activation-candidate` was merged with the
current manifold/tendon path; muscle kernels are reused from `muscle-candidate`;
fluid integration comes from `fluid-candidate/integration-20260928`, with the
later `ellipsoid-proof-candidate` kernels; fixed-tendon arithmetic and ordered
mass modeling come from `fixed-tendon-candidate`. The fixed loader/adapter was
adapted for mixed spatial paths and separate position/velocity addresses.
