# Vectorized solver rows and bounds scans

2026-09-24. This follows [independent Jacobian validity](jacobian-validity-performance.md).
The supported smooth Euler workload is faster, but parity with native SIMD MuJoCo
3.14.0 is still pending. The final implementation preserves the six readiness
checks per step and their accepted numeric domain.

## What changed

C's `mj_factorI` updates each ancestor row with `mju_addToScl`, then scales the
pivot row. The Ada compatible solver now uses proved `Add_Row` and `Scale_Row`
kernels for those independent entries and for the reverse triangular solve.
Every output uses the same rounded multiplication and addition as before;
reductions with dependent floating-point sums retain their original order.
Neither FMA nor floating-point reassociation was enabled.

Each row counts values outside `Work_Real`, without a branch after each element.
Callers return `Numeric_Limit` before consuming a rejected row. All intermediate
arithmetic is within the kernels' wider proved finite ranges. A failed row can
now contain out-of-work values in disposable scratch; this storage is not a valid
factor and must not be reused. The next solve reloads it from the mass matrix.
Physical state, inputs, warning/clamp semantics and the strict solver algorithm
are preserved. No deallocator, suppression, assumption or trusted body was added.

`Array_Bounded` checks a one-element buffer directly. Larger/empty buffers use
`Bounds_Kernels.All_Within`, whose integer rejection count equals the former
universal predicate, including both boundary values. This speeds existing scans;
it does not remove readiness checks or replace them with an unproved flag.
Disassembly confirms vector arithmetic, comparisons and integer accumulation
in the final release binary (eight doubles per main vector iteration, plus tails).
The implementation is ordinary SPARK; it contains no target-specific intrinsics.

## Integrated measurements

Frozen baseline: the preceding Jacobian-validity implementation, 30 experimental
Ada files. Current: build7, 32 experimental files. Both use identical release
flags and the same native SIMD C oracle and runtime libraries, verified by hash.
Each of two separate sessions runs 15 model/state cases, 24 balanced blocks,
1,080 processes, four measured 100-step trajectories per process after two
warmups, on CPU 12. Timing ran without concurrent builds, proofs or validation.

The compact table uses the median of three initial-state medians for each model;
the ranges span the two sessions. These are separate workloads, not a weighted
overall simulation score. Ratios use paired block medians, so they need not equal
the quotient of the displayed latency medians.

| Workload | Previous µs/step | Current µs/step | Paired time reduction | Current / C |
| --- | ---: | ---: | ---: | ---: |
| 1 DOF hinge/motor | 0.665 | 0.623–0.624 | 6.3% | 1.43–1.44× |
| 5 DOF branched | 1.926–1.929 | 1.893 | 1.6–1.7% | 1.89× |
| 12 DOF chain | 4.834–4.855 | 4.644–4.653 | 4.0–4.6% | 2.21–2.26× |
| 6 DOF without damping | 2.326–2.329 | 2.292–2.294 | 1.4–1.5% | 2.39–2.40× |
| 24 DOF chain | 11.401–11.534 | 10.338–10.365 | 9.4–9.8% | 2.19–2.20× |

Paired bootstrap 95% confidence intervals are below one for all three states of
1, 6, 12 and 24 DOF in both sessions. For the 5 DOF workload, one first-session
interval includes parity; all three second-session intervals are below one.
The small effects are reported with this uncertainty, not classified using a
fixed “noise threshold.” Intervals are within-session and not corrected for
multiple comparisons. Full case timings, MAD, trajectory p95 and interval bounds
are retained in the evidence; p95 is not a distribution of individual-step tails.

All timed Ada trajectories match the frozen baseline exactly. Maximum absolute
error against C is 2.2537527399890678e-14. A preliminary version without the
single-element specialization regressed 1 DOF by about 2.6%; it was not accepted.
A general short-buffer specialization also worsened multiple full-step workloads
and was discarded. The final table uses only the retained implementation.

## Correctness and proof scope

- Compatible and Strict: 480 scenarios and 78,720 numerical comparisons each,
  with the existing lifecycle, normalization and rejection checks. All 34 output
  files per policy are byte-identical to the preceding implementation.
- Inertia boundary suite: 85 cases, 170 scenarios, including sticky clamp
  diagnostics and atomic failures at time, position, velocity and acceleration
  limits. Existing C special-case qualifications in [inertia policy](inertia-policy.md)
  still apply.
- Kernel adversarial probe: 66,306 cases in each of checked and release builds,
  lengths 0–256, nonzero lower bounds, every rejected lane, vector tails,
  inclusive/adjacent limits and extreme allowed operands.
- Test-only private solver probe: synthetic bounded symmetric matrices force a
  factor-row failure at each possible position of the first updated row in the
  multi-DOF fixtures. It checks `Numeric_Limit`, unchanged physical state/inputs,
  unpublished acceleration, preserved clamp diagnostics and successful retry
  after poisoned scratch. Its 480-scenario differential run also passes.

Proofs started with individual helpers, followed by full units:

| Scope | Closed / emitted checks | Established properties |
| --- | ---: | --- |
| `Solver_Kernels`, full unit | 64 / 64 | Scalar laws; exact rounded per-entry row results; exact rejection result; bounds, indices, initialization, termination |
| `Bounds_Kernels`, full unit | 7 / 7 | Exact universal bounds predicate, empty arrays and safe rejection count |
| `Array_Bounded`, final single-element wrapper | 8 / 8 | Exact old null-aware predicate, including the direct scalar branch |
| Readiness compatibility / Jacobian readiness lemmas | 1 / 1 each | Predicate implications under their stated assumptions |
| `Ensure_Jacobians`, final caller proof | 12 / 12 | Ready/cache/state/configuration frame preservation under the builder contract |
| Public Forward / Kinematics wrappers | 4 / 4 and 10 / 10 | Contract composition under called-unit contracts |

`Add_Row` and `Scale_Row` specifically prove all entries, on both accepted and
rejected rows; their meaningful functional contracts are stronger than absence
of runtime errors. Checks include the count bounds, so the reduction introduces
no possible integer overflow for the array index type.

The compound `Solve_Compatible` proof is still open: the latest bounded diagnostic
emitted 101 checks, with 47 unproved (including readiness/frame preservation,
loop storage/index facts and call preconditions). An earlier attempt timed out.
Neither is a pass. These are pending proof-engineering obligations, not a
mathematical justification for stopping at Silver. The complete factorization
refinement, dynamics and state lifecycle are not claimed Gold-complete. The
existing pending physical-Jacobian refinement also remains open.

## Compiler regression caught by release testing

The first fused Boolean reduction proved at source level and passed the checked
probe, but optimized GNAT/GCC 16.1 emitted an incorrect result at complete SIMD
blocks in the adversarial probe. It could report `Ok=False` although all computed
entries were in range. An inlined Boolean bounds function also exhibited this
failure; merely moving the Boolean into a local variable or separating the two
loops was insufficient. The archived failing source passes when compiled with
`-fno-tree-vectorize`, with the other flags unchanged.

The retained implementation counts rejections using `Int64`. Its safety and exact
zero-count predicate are proved, and all adversarial cases pass with the normal
SIMD release flags. The failing reproducer, scalar control and disassembly are
archived for toolchain investigation. This is why source proofs and executable
checks remain separate evidence; a SPARK proof does not prove the compiler.

## Evidence and remaining work

Reproduction commands and immutable evidence are in
[solver_rows](../tests/movement_performance/solver_rows/README.md).
The archive includes source/binary/library hashes, frozen baseline, raw timings,
validation outputs, unsuccessful proof attempts and the compiler reproducer.
No exploratory or instrumented timings substitute for the two release sessions.

A separate instrumented run (120 processes, exact release outputs) confirms six
readiness calls per step, zero Jacobian builds on the multi-DOF fast path and the
same one/two physical solves. At 24 DOF its nested timers attribute roughly 32%
to readiness scans, 24% to poses and 16% to factor preparation/factorization.
Clock overhead and instrumentation affect these fractions; they diagnose the
remaining work and are not additional release speed measurements.

The factorization still visits a dense lower triangle; it does not yet use C's
compressed ancestor sparsity. Full readiness checks still repeat stable
configuration and valid-cache scans. Pose work and repeated topology preparation
also remain. These must be reduced with corresponding contracts and measured on
the complete movement workload; this change does not establish performance parity.
