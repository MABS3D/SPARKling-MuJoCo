# Local row-update investigation r324 — 25 October 2026

No commits or pushes. HEAD remains `398c2dde5299ec46cfb00bffd91e7660a852907a`.

## Decision

Neither variant is promoted. The direct variant improves the 24-DOF chain about 9% but repeatedly regresses ball/free about 10% and spatial_ball 14–17%. Retaining the original helper for rows shorter than 8 reduces those losses, but the chain gain falls to 3–4% and several small-model slowdowns of 1–2% remain repeatable. Without an established representative workload weighting or performance parity, these are insufficient grounds for a general replacement. The active Solver_Kernels body is restored byte-for-byte to its pre-experiment state; both proved variants, all raw sessions and the diagnostic tools are retained locally. No earlier project changes were reverted.

## Diagnostic profile

A strict O3/gnatn/native/ffp-contract=off movement build was copied unchanged and
instrumented with pg/g. On a 24-DOF chain, the compatible factor/solve symbol
contains 403/1011 main-image samples (39.86%). DWARF maps 251/1011 samples to the
inlined disjoint row update. On 24-DOF branches, the corresponding symbol has
100/494 samples (20.24%). Free has only 44 samples: its percentages are too
coarse to rank small costs reliably. Full-process sampling includes setup, reset
and I/O, and can omit shared-library time; instrumentation changes layout and
call overhead. These are diagnostic self costs, not exclusive phase attribution
of the C gap. Release timings below are separate.

The actual C3.17 mj_factorI uses the same descending packed-row algorithm and
scaled row updates. Both implementations also factor a damping-adjusted metric
for implicit Euler when damping is present; that second solve is not itself an
extra Ada algorithm. Ada's strict release assembly repeats scalar operand subtype
checks in the row helper. The direct expression removes those repeated helper
checks without suppressions, stronger preconditions or a different FP order.
The original output-domain rejection remains. The long-row variant retains the
original helper for Count<8. The dispatch threshold is experimental, not a
mathematical input restriction.

## Functional proofs and numeric checks

Direct row: minimum 39 checks (37 proof/2 flow), whole Solver_Kernels 115
(101 proof/14 flow). Long row: minimum 46 (44 proof/2 flow), whole unit 122
(108 proof/14 flow). All obligations are closed on SPARK-covered unchanged
snapshots; minima are warning-free. Each whole-unit report records five integer
operator-reassociation warnings on existing expressions: obligations_closed=true,
strict passed=false. No assumptions, skips or warning suppression were added.
Contracts specify exact rounded entry expressions, rejection and the complete
untouched frame; this is distinct from accuracy relative to real arithmetic.
Proofs ran with one worker, 2500 MiB aggregate, 240 seconds, and 3 seconds/650 MiB
per prover. Whole/min counts are separate scopes, not additive totals.

Both variants pass all 14,905 disjoint-row corpus cases in validation and strict
release, including each rejected SIMD lane, lengths 1..256, nonzero origins,
untouched slots, extreme values and high array indices. The direct variant also
passes C3.17/C3.14 validation/release mass/derivative/boundary gates; the exact
runtime scopes of each variant are in summary.json. All 329 formal Ada sources
match the direct C3.17 runtime closure. An exact hash reconstruction preserves
the earlier validation manifest after a Python-only diagnostic driver was added;
the manifests, earlier provider and receipt are retained. Ada sources did not
change between those profiles.

## Integrated movement

Two sessions per variant each cover ten models/three states, 24 balanced blocks,
four samples, 100 evolving steps and two warmup trajectories, CPU 12. Baseline and
candidate use the same strict flags, with no gnatp or unsafe FP. Setup/reset/I/O
remain outside release timing. Every Ada output is exactly equal to baseline;
all endpoints agree with C at the existing atol/rtol 2e-10. Per-scenario medians,
MAD, trajectory-mean p95 and paired bootstrap intervals are retained. Intervals
are within-session without multiple-comparison correction; no unweighted average
of model speedups is a performance acceptance result.

Ratios below span all three initial states in both sessions; lower is faster.
The complete confidence intervals and raw outputs remain in the archive.

| Model | Direct row current/baseline | Long-row current/baseline |
|---|---:|---:|
| hinge_motor | 0.988–0.999 | 1.014–1.019 |
| affine_chain | 1.049–1.105 | 0.999–1.052 |
| branched | 1.072–1.127 | 1.012–1.054 |
| ball | 1.093–1.105 | 1.015–1.025 |
| free | 1.094–1.099 | 0.994–1.011 |
| free_ball | 0.964–0.994 | 1.004–1.029 |
| fixed_tendon | 1.066–1.089 | 0.968–1.030 |
| spatial_ball | 1.136–1.170 | 1.009–1.018 |
| chain_24 | 0.903–0.912 | 0.960–0.967 |
| branches_24 | 0.976–0.992 | 1.012–1.020 |

The direct variant improves the chain around 9% but repeatedly regresses small
models, including ball/free around 10% and spatial_ball about 14–17%; it is not
accepted as a general improvement. Official C3.17 wheel library build flags are
unknown. Movement remains materially behind C; these comparisons cannot certify
matched-build performance parity, full MuJoCo alignment or full-port completion.
Contacts/constraints, sensors, rendering and activation-state models are outside
this smooth Euler workload. Global compiler flags were not changed.

## Evidence and omissions

The ZIP contains frozen source manifests/closures, actual proof drivers/reports,
strict row corpus/builds, numerical gates, two paired release sessions per
variant, instrumented profile/bin and raw histogram/line mapping, release
assembly comparisons and actual execution recipes. Earlier r316/r317 sampler
attempts are retained as failed diagnostics: their watchdog stdout contaminated
the numeric frames and per-trajectory sampling produced no useful histogram.
The corrected r318 runner isolates watchdog output and samples continuously.
All archive members are hashed and reread. Compiler object caches, prover task
caches, external toolchains and the external C shared library are omitted;
binary/library hashes, compiler versions, flags and exact pins remain recorded.
No new global Gold, physical binding, shared-step support or performance parity
claim is made. Complete 3.17 migration and the full port goal remain open.
