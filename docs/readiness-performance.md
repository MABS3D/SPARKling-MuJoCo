# Validated entry reuse and deferred Jacobians

2026-09-24. Continuation of [inertia policy](inertia-policy.md), measured against
MuJoCo 3.14.0 with the same native SIMD C reference and supported unconstrained
scalar-joint Euler workloads. This is not complete MuJoCo performance parity.

## Implementation

The private `MJ.Data.Pipeline` separates `Update_Poses`, `Ensure_Jacobians`, and
`Evaluate_Ready`. `Euler.Step` establishes `Is_Ready`, checks next time without
modifying the simulation, and calls the private entry point. It no longer
repeats the same entry scan in kinematics. Six full phase guards remain per
successful step. The public `Forward.Evaluate` and `Kinematics.Update` retain
entry validation; the public kinematics operation still constructs Jacobians.
There is no public Boolean parameter for bypassing validation.

CRB and recursive forces consume body/joint poses directly. Their successful
paths no longer construct COM Jacobians. Each dense fallback calls
`Ensure_Jacobians`; the second consumer reuses the materialized arrays.
`Jacobian_Valid` is cleared by the existing cache invalidation routine, including
state changes, integration, reset and new pose updates. Control and applied
force setters preserve it. Physical state and the existing solver policies,
numerical domain checks and atomic state failure behavior are retained.

Both Jacobian arrays are still zeroed at pose update. This intentionally keeps
`Kinematic_Bounded` unchanged when `Pose_Valid` becomes true; `Is_Ready` does not
establish bounds for an invalid pose cache on entry. Removing zeroing or omitting
bounds scans of unmaterialized Jacobians needs a separately established invariant.
The matrices also still occupy their original storage.

`Is_Ready` is factored into storage/layout, immutable configuration, input and
cache predicates. `Original_Ready` retains the original expression as a ghost
reference; their equality is proved. The runtime predicate has not been replaced
with the historical `Ready_Flag` shortcut. The configuration equality lemma now
requires equality of `Solver_Policy`, a field added by the preceding change.

## Whole-step measurements

Two independent sessions; each uses 15 model/state cases, 24 balanced blocks of
three binaries, four measured trajectories per process, 100 steps per trajectory,
two warmups and CPU 12. Each session records 1,080 processes. Compilation and
proof jobs finished before timing. Release settings, reference library hashes,
compiler versions, raw timings, MAD, p95, paired bootstrap intervals and source
hashes are archived in
[`readiness/evidence`](../tests/movement_performance/readiness/evidence).

The values below are the range of the two session summaries. Each session
summary is the median of the three state-specific medians. Improvement is the
median paired current/baseline ratio, so it need not equal a ratio of the displayed
independently aggregated times.

| Workload | Before, µs/step | Current, µs/step | Time reduction | Current/C |
| --- | ---: | ---: | ---: | ---: |
| Hinge motor, 1 DOF | 0.675–0.678 | 0.668 | 1.0–1.2% | 1.54× |
| Branched multijoint, 5 DOF | 2.288–2.291 | 1.974–1.978 | 13.8–13.9% | 1.97–1.99× |
| Chain, 12 DOF | 7.381–7.446 | 5.193–5.215 | 30.1% | 2.48–2.51× |
| No damping, 6 DOF | 3.008–3.012 | 2.418–2.436 | 18.6–19.1% | 2.54–2.58× |
| Chain, 24 DOF | 20.963–20.986 | 12.627–12.675 | 39.8% | 2.65–2.66× |

Every multi-DOF state-specific 95% interval lies below 1 in both sessions. The
small 1-DOF change is not conclusive in every case: state 2 in the first session
has a ratio interval of 0.981–1.007. There is no arbitrary noise allowance and no
multiple-comparison correction. Current p95 trajectory-average step costs span
0.834–0.842, 2.350–2.517, 5.724–5.808, 2.839–3.136 and 13.455–13.842 µs respectively
for the displayed workload order; these are not individual-step latency tails.
No claim of parity is supported by these measurements.

The 120 separate instrumented runs confirm exactly six readiness checks per
step, no condition estimation in Compatible, unchanged physical solve counts,
zero Jacobian construction in the four multi-DOF benchmarks, and one construction
per one-DOF step shared by both fallback consumers. Their final physical outputs
exactly match the release build. In the instrumented current build, readiness
occupies approximately 38%, 38% and 35% of total time at 5/12/24 DOF. At 24 DOF,
kinematics and factor preparation each account for about 20% of instrumented
runtime, and physical solves about 6%. Nested timers include clock overhead and
must not be summed with their parent phases.

These gains belong to the combined refactor: predicate factoring, entry reuse,
private composition and deferred Jacobians also affect generated code. The old
profile's Jacobian percentage alone is not a causal explanation of the total
speedup; this run is not an ablation of each change.

## Verification scope

The final checked build passes:

- Compatible and Strict: 480 scenarios and 78,720 oracle comparisons each,
  including wide-domain dense fallback, multiple roots and branched models.
- All 34 emitted output files in each policy are byte-identical to the preceding
  policy build, including statuses, clamping diagnostics and rejected cases.
- 85 targeted policy boundary cases, 170 scenarios including reset/retry; the
  fixture qualifications in [inertia policy](inertia-policy.md) still apply.
- A separate checked cache probe repeats the 480-scenario suite. It compares
  eager/lazy Jacobian values exactly, exact mass/gravity/bias/passive values,
  repeated materialization, preservation of other valid caches, control/force
  setter behavior, physical state preservation and state invalidation.
- All timed trajectories agree exactly between the two Ada builds. The maximum
  absolute C trajectory difference is 2.254e-14.

Proofs began at individual helpers. Closed obligations on the recorded source:

- Readiness decomposition: 1 proof check, exact predicate equivalence.
- `Invalidate`: 1 functional postcondition, all six flags false; the existing
  unused-initial-value warning is recorded, not suppressed.
- Corrected configuration equality, its transitivity helper and input equality
  are also closed on the final source snapshot.
- `Forward` and `Kinematics` wrappers: 4 and 10 checks, respectively, also closed
  as complete unit invocations. They establish contract composition under the
  contracts of their callees, not the bodies of those callees.
- `Euler.Step` line 78: its private-entry precondition is proved directly. This
  is the specific obligation supporting reuse of the entry validation, not a
  proof of the entire step.

Still open, explicitly not Gold or Silver completion claims:

- `Evaluate_Ready`: 1 of 41 checks remains open in the longer bounded run,
  preservation of `State_Values` in its postcondition. The intermediate equality
  checks close; the remaining timeout is unfinished proof engineering.
- `Ensure_Jacobians`: 10 of 36 checks remain open in the short diagnostic run,
  including loop/frame information needed for pointer/index safety and its
  preservation postcondition. Tests do not discharge them.
- Body/joint kinematics, CRB/RNE composition, solver and full state lifecycle
  preservation retain their previously documented open proof scope. Preliminary
  `Integrate` and actuation runs exhausted their 120-second budget without a
  usable obligation summary; zero reported checks is not success.

The proof harness now includes all Data child units in its shared dependency
project. Public wrappers are no longer necessarily dependencies of `Euler`, so
the earlier Euler-root-only source list omitted them. Initial tool-error evidence
and bounded diagnostic attempts are retained along with successful runs.

## Remaining work toward parity

Close preservation of stable configuration, layout and cache validity across
each minimal mutator, then use those proofs to remove additional runtime scans.
The six remaining guards are still real work. Separate materialized Jacobians
from pose validity with a proved invariant before dropping zeroing/bounds scans.
Then replace dense factor/solve traversal and dense storage with the C-style
DOF ancestor/sparse structure where it applies, preserving Compatible pivot
clamping, Strict behavior and numeric limits. Re-measure complete trajectories
after each justified change; a fast microkernel alone does not establish parity.

Follow-up: [independent Jacobian validity](jacobian-validity-performance.md)
records removal of stale-array scans/clearing and the subsequent proof and timing results.
