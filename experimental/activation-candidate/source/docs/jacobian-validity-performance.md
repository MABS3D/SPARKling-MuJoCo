# Independent Jacobian validity: proofs and whole-step cost

2026-09-24. Continuation of [validated entry reuse](readiness-performance.md),
against the same MuJoCo 3.14.0 native SIMD reference and supported unconstrained
scalar-joint Euler models. The complete simulator is still experimental and the
measurements do not establish performance parity with C.

## Implementation and validation boundary

`Is_Ready` still validates storage/layout, configuration, inputs and all valid
caches. It now distinguishes `Poses_Bounded` from `Jacobians_Bounded`:

- `Pose_Valid` requires bounded body/joint poses.
- `Jacobian_Valid` requires current poses and bounded Jacobian arrays.
- An invalid Jacobian cache has no value-bounds obligation; its storage must
  still have the correct non-null layout.

`Update_Poses` invalidates caches without clearing either Jacobian array.
Successful CRB/RNE paths neither construct nor read those arrays. Both fallback
consumers call `Ensure_Jacobians` before reading them, and return immediately on
failure. The public `Kinematics.Update` still materializes them.

The private `MJ.Data.Jacobians` package isolates the rounded hinge/slide column
formulas, exact column stores with preservation of all other entries, and the
ancestor traversal. `Build` first overwrites both arrays completely with zeros,
then stores only accepted bounded columns. On failure all stored values remain
bounded but the cache flag stays false. `Ensure_Jacobians` publishes validity
only after success and preserves physical state, inputs, configuration and other
cache flags. The diagnostic warning/deallocation boundaries and Compatible/Strict
solver behavior are unchanged.

This deliberately changes what readiness means for *invalid* derived storage.
It is not claimed equivalent to the old predicate for arbitrary stale arrays.
`Original_Ready` now uses the frozen `Prior_Caches_Bounded` expression. The
compatibility lemma proves both relevant implications: old readiness implies
new readiness with coherent flags; new readiness plus the old pose-dependent
Jacobian bounds implies old readiness. The separate Jacobian readiness lemma
proves that a valid cache under new readiness provides all historical kinematic
bounds. The old `Ready_Flag` shortcut remains unused.

The configuration equality lemma's array premises are expressed element by
element. Equal snapshot dimensions make these equivalent to the previous whole
array equality premises. This closes the materialization wrapper's configuration
frame proof without changing the runtime or weakening the required equality.

## Measured result

Each of two separate sessions has 15 model/state cases, 24 balanced blocks of
three binaries, four measured 100-step trajectories per process and two warmups,
on CPU 12: 1,080 process runs per session. No build or prover jobs ran during
timing. Compiler flags, environment, source/binary/reference hashes, raw runs,
MAD, trajectory-average p95 and paired bootstrap intervals are archived in
[`jacobian_validity/evidence`](../tests/movement_performance/jacobian_validity/evidence).

Each displayed session value aggregates the three state-specific medians;
ranges cover the two sessions. The improvement column aggregates paired ratios,
so it need not equal a ratio of independently aggregated time columns.

| Workload | Before, µs/step | Current, µs/step | Further time reduction | Current/C |
| --- | ---: | ---: | ---: | ---: |
| Hinge motor, 1 DOF | 0.670 | 0.662–0.666 | 0.9% | 1.51× |
| Branched multijoint, 5 DOF | 1.987–2.000 | 1.923–1.924 | 3.4–3.6% | 1.92–1.93× |
| Chain, 12 DOF | 5.201–5.207 | 4.840–4.920 | 5.9–6.1% | 2.34–2.37× |
| No damping, 6 DOF | 2.423–2.428 | 2.324–2.325 | 3.5–4.3% | 2.45–2.46× |
| Chain, 24 DOF | 12.621–12.730 | 11.423–11.452 | 9.3–9.7% | 2.41–2.42× |

Every multi-DOF case has a paired 95% current/baseline interval below 1 in both
sessions. At 1 DOF several intervals include/touch 1: this is not a uniformly
resolved improvement. There is no arbitrary noise threshold or multiple-comparison
correction. Current p95 trajectory-average step costs, in table order, are
0.790–0.836, 2.417–2.672, 5.428–5.546, 2.580–2.720 and 12.040–12.401 µs. These are
not individual-step latency tails.

All timed Ada trajectories are exactly equal to the baseline. The maximum
absolute difference from C is 2.254e-14. Gains describe the combined validity,
materialization and code-generation change; they are not an ablation of each edit.

The separate 120-run profile has exact release-equivalent physical outputs and
still records six readiness calls per successful step. It constructs no Jacobians
on the four fast multi-DOF benchmarks; the one-DOF fallback constructs them once
and reuses them. At 5/12/24 DOF, readiness occupies approximately 37.6/35.6/29.9%
of instrumented time. At 24 DOF, kinematics is about 22%, factor preparation
22% and physical solves 7%. Nested clocks and compilation perturbation mean
these percentages are diagnostic, not release timing attribution.

## Proofs and tests

Final complete-unit runs close all 102 checks in `MJ.Data.Jacobians`, and all
4/10 checks in the public Forward/Kinematics wrappers. The materialization
wrapper `Ensure_Jacobians` closes all 12 selected checks. The compatibility and
valid-Jacobian readiness lemmas each close their check. The component-wise
configuration lemma closes 28 checks; invalidation closes its functional check
with the existing unused-initial-value warning retained.

These claims have distinct scopes:

- `Column` and `Store_Column` prove exact rounded formulas, success/bounds
  correspondence, exact writes and preservation of other entries.
- `Build` proves initialization, bounds, indexing/termination safety and zero
  world-body columns, including early numerical failure. Its full refinement
  against a mathematical/topological model of every Jacobian entry is still
  pending proof engineering; it is not a documented mathematical impossibility
  or a completed Gold claim for the entire physical Jacobian.
- `Ensure_Jacobians` proves readiness/frame preservation and that a successful
  result exposes a valid cache, using the proved `Build` contract.
- Wrapper proofs compose callee contracts. Pose update, CRB/RNE composition,
  solver, full lifecycle and overall pipeline proofs retain their documented
  open scope. No whole-simulator Gold or Silver claim follows from these runs.

Line-limited attempts at the two fallback reader boundaries reported zero proof
checks, including the corrected source locations. They are retained as
non-evidence, not counted as successful caller proofs. The guards and calls are
present in source and covered by the checked failure tests; the closed callee
and readiness proofs above are the reported formal results.

The final checked executables pass:

- Compatible and Strict: 480 scenarios / 78,720 oracle comparisons each, with
  all 34 output files per mode byte-identical to the prior readiness build.
- 85 solver-policy boundary cases / 170 reset/retry scenarios, retaining the
  fixture qualifications documented in [inertia policy](inertia-policy.md).
- A separate 480-scenario checked cache suite, including eager/deferred exact
  comparison and cache lifecycle tests. It injects ±1e100 into stale Jacobians:
  pose updates must not clear them, fast paths must ignore them, materialization
  must replace them with the exact eager values, and valid flags must reject
  nonempty out-of-domain arrays. Incoherent pose/Jacobian flags are rejected
  also in zero-DOF models. Hinge fixtures force a materialization Numeric_Limit,
  verify that partial results stay invalid and other caches/state are preserved,
  then retry after fresh poses.

Early diagnostics exposed a nullable-array precondition arithmetic issue and an
unbounded length conversion in the new topology predicate; both are corrected
and included in the final complete-unit proof. Joint-pose lengths are compared
rather than imposing an unnecessary identical upper bound on empty arrays.
All bounded attempts and their exact source snapshots are retained.

## Remaining parity work

Six checks still traverse configuration, input and valid pose/dynamics state.
Prove their immutable/frame portions across minimal mutators before avoiding
those repeated reads. On the larger chains, dense factor preparation is now
comparable to kinematics; specialize factor/solve traversal using DOF ancestry
and sparsity where C uses it, while preserving policy behavior and numerical
limits. Validate each change against complete equivalent trajectories.


Follow-up: [vectorized solver rows and bounds scans](solver-rows-performance.md).
