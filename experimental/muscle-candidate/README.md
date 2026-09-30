# Muscle kernels and scalar actuation (MuJoCo 3.14.0)

This standalone candidate implements all five upstream muscle utility functions,
plus scalar force evaluation and owned Euler activation updates. It uses caller
provided transmission length/velocity, calibrated length range and `acc0`.
It is isolated from the active smooth engine and from concurrent actuator work.
It does **not** add muscle support to the active MJB loader or smooth pipeline.

## Implemented behavior

| Ada function | Upstream reference / behavior |
| --- | --- |
| `MJ.Muscle_Kernels.Length_Gain` | `mju_muscleGainLength`: four length branches and zero outside the range |
| `Gain` | `mju_muscleGain`: force scaling, normalized length/velocity, ordered active force |
| `Bias` | `mju_muscleBias`: zero below unit length, quadratic transition, linear extension |
| `Timescale` | `mju_muscleDynamicsTimescale`: hard switching or quintic smoothing |
| `Dynamics` | `mju_muscleDynamics`: excitation/activation clamping, asymmetric time constants |
| `MJ.Muscle_Actuation.Evaluate` | separate gain/bias parameter arrays, control limits, `actearly`, force limits |
| `Step` | Euler `act + act_dot*timestep`, optional activation limits, atomic finite-state update |

`Parameters(0..8)` follows C: normalized range endpoints, force, scale, lmin,
lmax, vmax, fpmax, fvmax. `Dynamics_Parameters(0..2)` is activation time,
deactivation time, smoothing width. Kernel defaults match upstream `<muscle>`.
Control and activation limits are opt-in, as in the upstream default; the dynamics
function always clips excitation and activation for its timescale calculation.
Importantly, its excitation difference uses the **original** activation, including
values outside `[0,1]`. The width equality `width = mjMINVAL` selects smoothing.

The public raw parameter domain is the project's finite `Tier0_Real` (`±1e10`).
Normalized length/velocity and standalone length-gain arguments support Tier1.
Zero or negative times, inverted/equal length ranges, negative scale/curve
parameters, and floor denominators retain the C branches; the wrapper only
requires ordered ranges for enabled limits. No parameter positivity assumption
is inserted to simplify proofs. Wider output subtypes prevent silently clipping
large intermediate forces. The stored activation is Tier0: `Step` returns
`Numeric_Limit` and preserves the state if its unclipped/limited next activation
cannot fit that domain. The computed evaluation remains available on rejection.
This rejection is a deliberate difference from C's unbounded state update.
There are no heap allocations or whole-model scans in this module.

## Formal specification

The static ghost functions describe the floating-point expressions, branches,
operation order and fallback values independently of executable kernels. Runtime
functions are specified against these models; models never call runtime bodies.
`Evaluate` fixes every output field. `Step` additionally fixes status, accepted
activation and preservation on rejection. Typed intermediates make range proofs
local without changing arithmetic order or narrowing the external domains.

These are functional properties of the rounded algorithm, not proofs of physical
accuracy, exact real identities, universal C equivalence, or the complete engine.
`Sigmoid_Value` has conservative safety bounds; no unproved positivity or
monotonicity of floating-point polynomial evaluation is assumed. All models,
runtime bodies, flow and checks must be included in accepted complete-unit
reports. There are no assumptions or skipped bodies.

## Verification and reproduction

Run from the repository root (the Python environment with MuJoCo 3.14.0 is
required for the engine fixtures):

```sh
python3 experimental/muscle-candidate/tests/prove.py --out /var/tmp/muscle-proof
/var/tmp/sparkling-movement-env/bin/python experimental/muscle-candidate/tests/check.py --out /var/tmp/muscle-check
python3 experimental/muscle-candidate/tests/benchmark.py --out /var/tmp/muscle-benchmark
```

The proof runner starts at individual ghost functions and executable subprograms,
then proves both entire units. It archives logs, raw `.spark` JSON, source hashes,
coverage, environment, commands and acceptance. Analysis uses a frozen native-filesystem
copy of the Ada sources (byte hashes checked), with only source-directory paths
adjusted in the copied project. Compiler/prover settings are preserved. Outputs and build artifacts stay
outside the source tree. The compiler/prover paths currently follow the project's
existing `/var/tmp/sparkling-matrix-recovery/toolchains` installation.

The numerical oracle extracts **verbatim** C bodies from the pinned upstream file,
with real upstream scalar types/macros. It compiles them using the same GCC 16.1,
`-O3 -march=native -flto -ffp-contract=off` semantics as the Ada release benchmark.
Numerical comparisons cover piecewise boundaries and adjacent doubles, degenerate
parameters, clipping, separate gain/bias parameters, `actearly`, rollback, and
activation feedback. Actual MuJoCo engine fixtures cover joint and fixed tendon
transmissions. Both checked (`-O2 -gnata -gnato -gnatVa`) and release Ada are tested.
Signed zeros are not distinguished by numerical equality.

The diagnostic benchmark executes repeated, stateful actuator updates for varying
length, velocity and excitation, including force and activation calculation and
Euler integration. The C workload uses the extracted kernels with the same input
sequence; Ada uses the public `Step`. Input preparation and I/O are outside timing,
checksums prevent dead-code elimination, a warmup is discarded, and run order
alternates. Raw paired samples and dispersion are retained. Host concurrency can
substantially affect these measurements. Performance parity on complete movement
workloads remains pending: transmissions, mass, force projection, dynamics and
solvers are outside this benchmark.

## Integration still required

Wire muscle kinds and parameter/calibration loading into the active model format,
allocate activation addresses with the active state manager, and supply the actual
joint/site/tendon transmission kinematics. Route scalar force through the engine's
moment/Jacobian projection and joint/tendon total-force limits. Preserve upstream
actuator disabling, plugin ordering, supported integrators, and state lifecycle.
These are engine integration responsibilities, distinct from the delivered
muscle law and scalar activation update. The candidate provides a checked API and
reproducible evidence for that integration without changing the main thread's
working sources.

## Recorded result (2026-09-30)

Both complete units pass: 400 checks, 41 subprograms, no open obligations,
no warnings or skipped/assumed bodies. Each checked/release run has 10,179 cases
and 26,523 equal-valued comparisons, including 320 actual-engine cases.
See [risultati.md](risultati.md), [summary JSON](results/summary-20260930.json),
and the [raw evidence archive](results/evidence-20260930.zip) for scope,
performance uncertainty, commands and source hashes.
