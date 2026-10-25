# Local integer-bit row reduction r329 — 25 October 2026

No commits or pushes. HEAD remains `398c2dde5299ec46cfb00bffd91e7660a852907a`.

## Decision

Retain the functionally proved r326 integer-bit variant as local work in progress. Two integrated sessions show about 9–10% less time on the 24-DOF chain and 2.5–6% on free+ball, with central gains around 1–3% on branches and some uncertain intervals. Spatial-tendon movement is about 2% slower with repeatable intervals above 1; fixed-tendon medians are 1.2–6.2% higher with wider, mixed intervals. These remain explicit regressions to resolve. All C 3.17/C 3.14 validation/release mass, derivative and boundary gates pass on the exact variant. Final C parity is pending: the wheel compiler flags are unknown and movement still trails C materially. No runtime checks or warnings were suppressed, and no public input restriction was added. The slice-view experiment is not retained: it added no SIMD, lost the chain gain and still has two open invariants.

## Algorithm and proof

The disjoint packed-row update retains the same scalar floating-point order,
output-domain rejection and untouched frame. Direct arithmetic avoids redundant
scalar helper operand checks. An unsigned 64-bit OR reduction replaces the
checked integer rejection count; its value is proved to remain zero or one.
No runtime check suppression, unsafe FP flag, stronger public precondition,
assumption or unproved trusted body was introduced.

The initial r325 minimum left one preservation obligation open: mixing bitwise
arithmetic with the quantified array invariant exceeded the per-check limits.
The r326 Flag_Rejection helper proves the exact OR expression, zero/one bound
and equivalence between zero output and no rejected entry. It closes two checks.
The row minimum then closes 39 checks (37 proof/2 flow), without warnings. Whole
Solver_Kernels closes 117 (102 proof/15 flow), retaining four integer-expression
reassociation warnings: obligations_closed=true, strict passed=false. Scopes are
separate, not additive. The previously counted loop bound no longer exists; its
warning is removed by that actual code change, not by suppression. Proofs use
one worker, 2500 MiB/240 seconds aggregate, and 3 seconds/650 MiB per prover.
The claim is exact rounded algorithm/frame/rejection behavior under the existing
input contract, not exact real arithmetic or full-engine Gold.

The actual C3.17 mj_factorI uses the same descending packed-row scaled updates.
C has no matching defensive result-domain reduction. The C wheel remains the
normal SIMD-enabled reference; its library build flags are unknown. The release
assembly comparison is recorded separately from instrumented profile data; a
source-level OR does not by itself establish vectorization or performance parity.

## Numerical and integrated evidence

The strict validation and release row corpus passes all 14,905 cases: lengths
1..256, each rejected SIMD lane, nonzero origins, untouched slots, extreme finite
values and high array indices. Complete C3.17/C3.14 runtime gates pass in both profiles: C3.17 has 288 raw
mass states, 960 derivative and 960 reordered derivative cases; C3.14 has 132 raw
states and 960 derivative cases. Invalid-model, reader-shape and composite
boundaries also pass. All 329 formal Ada sources match the C3.17 runtime closure;
no result is borrowed from a prior variant.

Two separate sessions each cover ten models/three states, 24 balanced blocks,
four samples, 100 evolving steps and two warmup trajectories, CPU 12. Identical
strict O3/gnatn/native/ffp-contract=off flags are used for baseline and candidate;
no gnatp or unsafe FP is present. Every timed Ada output is exactly equal to
baseline, and all endpoints match C within the existing atol/rtol 2e-10. Setup,
reset and I/O are outside release timing. All measured states and raw outputs,
MAD, trajectory-mean p95 and paired bootstrap intervals are retained. Intervals
are within-session without multiple-comparison correction. There is no unweighted
mean of model speedups used as acceptance evidence.

Ratios span three initial states and both sessions; lower is faster. Exact
confidence intervals and regression cases remain in the raw JSON.

| Model | Current/baseline range |
|---|---:|
| hinge_motor | 0.984–0.988 |
| affine_chain | 0.955–1.008 |
| branched | 0.996–1.006 |
| ball | 0.989–0.995 |
| free | 0.961–1.017 |
| free_ball | 0.940–0.975 |
| fixed_tendon | 1.012–1.062 |
| spatial_ball | 1.014–1.023 |
| chain_24 | 0.900–0.910 |
| branches_24 | 0.972–0.989 |

These supported smooth trajectories exclude contacts/constraints, sensors,
rendering and activation-state models. The unknown wheel compiler flags leave
matched-build C performance acceptance open. Full 3.17 migration, physical
pattern/cache binding, shared derivative stepping and full-port completion remain
open. Global compiler flags were not changed.

## Artifacts

The ZIP includes the failed r325 and final r326 source closures, actual minimal
and whole-unit proof drivers/logs/reports, the strict corpus and builds, paired
release builds/sessions/raw trajectories, assembly inspection and executed
recipes. Runtime gates are included only if executed on this exact variant.
Every archive member is hashed and reread; all prior inventory entries are
preserved. Compiler/prover object/task caches, external toolchain binaries and
the external C shared library are omitted. Exact pins, versions, flags and hashes
remain recorded. The preceding r324 checkpoint retains the baseline raw profile
and the two rejected direct/long-row experiments.
