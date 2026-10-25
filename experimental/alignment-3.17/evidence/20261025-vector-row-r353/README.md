# Local SIMD row and caller proofs r353 — 25 October 2026

All work remains local. No commits or pushes; HEAD stays
`398c2dde5299ec46cfb00bffd91e7660a852907a`.

## Retained change

Retain the separately compiled long-row helper (r349) as local work in progress. Compared with the previously retained bit kernel, the integrated chain takes about 0.7–2.7% less time, and tendon cases generally improve about 0.4–1.7%; some confidence intervals remain uncertain. Hinge and some ball cases are still slower, with central hinge losses around 0.9–1.9%, retained explicitly. No blanket aggregate improvement or final C parity is claimed. The native unpartitioned wide-index build has small chain gains but repeated branch regressions. The local 128-bit preference repeatedly regresses small movement cases and is not adopted; 256-bit was inspected only. The retained row/helper contracts close all 156 checks, and the actual solver caller separately closes 86 obligations under the unchanged callee contracts. All retained C 3.17/C 3.14 validation/release gates pass. The working source has no machine-width attribute, global compiler-flag change, suppressed check, stronger public input condition, assumption or new trusted body.

## Actual compiler evidence

The earlier no-vectype message was not the complete explanation. A fresh detailed
dump for the real caller reaches unsupported REALPART_EXPR in checked 32-bit
index-overflow arithmetic. Widening the source-index calculation to Int64 removes
that blocker on this GNAT target (Natural has 31 value bits), while the final
Natural conversion and array accesses remain checked. Same public precondition,
rounded scalar expression, rejection and untouched-frame contracts are retained.
No suppression, unsafe FP, assumption or skipped body was introduced.

The actual updated loop becomes vectorized with native 64-byte vectors, VF16 and
profitability thresholds 16/24. C3.17 mju_addToScl_avx uses explicit four-double
blocks and a scalar tail. Function-local vector preferences were investigated:
256-bit gives VF8 with thresholds 8/12;128-bit gives VF4 with thresholds 7/9. The
128-bit preference repeatedly slows small movement cases and is not adopted.
256-bit was compiled/inspected only, with no performance acceptance claim. The
initial attribute attempts failed because a representation item followed an
already frozen Ada body; corrected experiments retain the same contract on a
forward declaration. No such attribute or global flag change is in the working
source. A first dump build reused an object and produced no dump; the fresh
copied-object rebuilds and failed attempt are retained.

The retained variant keeps the previous scalar bit row for Count<16. Longer
rows call a separately compiled helper with the same exact contract. Its public
input domain is unchanged;16 is an implementation dispatch threshold, not an
input restriction. No copy or alternate floating-point association is introduced.
The private helper has actual vector multiply/add and bit operations. The caller
has a direct helper call and three existing vector operations, keeping vector
setup out of its short-row body. A direct unpartitioned SIMD build and local
128-bit preference remain experiments, not universally faster implementations.

## Proof scope

Wide row minimum: 38 checks (36 proof/2 flow); whole Solver_Kernels 116
(101 proof/15 flow), with four existing integer-expression warnings.
Retained long-helper minimum: 38; wrapper minimum 40; complete unit 156
(139 proof/17 flow), with six integer-expression warnings including duplicated
private row expressions. All obligations are closed; warnings are recorded,
not suppressed, so whole-unit strict passed=false. Minimum reports are clean.
Counts across scopes are not added as a whole-program proof.

The real Solve_Compatible_Buffers minimum separately closes 86 checks
(80 proof/6 flow), including every called-row precondition, successful output
bounds, indexing/initialization and preservation of an existing clamped diagnostic.
Ten inherited recursive-contract/numeric-variant warnings remain. The exact
current inertia body and unchanged callee interfaces connect that scoped proof
to the retained, separately proved row implementation. This does not establish
the complete floating-point factorization model, real-arithmetic accuracy,
physical simulation correctness, or whole inertia/data/workspace Gold.
Those models and composition remain work, not mathematical research exceptions.
Proofs use one worker, 2500 MiB/240 seconds aggregate, and 3 seconds/650 MiB per
prover. No assumptions, skips, stronger public input constraints or new trusted
bodies were added. Reviewed deallocator behavior is unchanged.

## Numerical gates and performance

All three measured variants pass 14,905 row boundary cases in validation and
strict release. The 128-bit corpus uses matching vector-width compiler preference.
The retained helper passes C3.17 and C3.14 full gates in both profiles: respectively
288/132 raw mass states, 960 derivative samples, and 960 additional reordered
samples for C3.17. Invalid-model, reader-shape and composite bounds/order controls
also pass. All 329 formal Ada files match the final C3.17 runtime closure. The
reordered oracle retains the prior checked permutation limitation; it is not a
claim that the known direct C reordered-storage crash has disappeared.

Each variant has two separate sessions, ten models/three states, 24 balanced
blocks, four samples, 100 evolving Euler steps and two warmup trajectories, CPU 12.
The baseline is the previously retained r326 bit kernel in every session.
Every Ada endpoint is exactly equal to baseline; C agrees at the existing
atol/rtol 2e-10. Setup/reset/I/O remain outside timing. Flags are strict O3,
gnatn, native architecture, ffp-contract=off; no gnatp or unsafe FP. All raw values,
commands, medians/MAD, trajectory-mean p95 and paired bootstrap intervals remain.
Intervals are within-session without multiple-comparison correction. Ratios span
all states/sessions below; lower is faster. No unweighted model average or
arbitrary allowance is used to dismiss a regression.

| Model | Wide/native | Local 128-bit preference | Separate long helper |
|---|---:|---:|---:|
| hinge_motor | 1.015–1.027 | 1.143–1.146 | 1.009–1.019 |
| affine_chain | 0.999–1.013 | 1.043–1.089 | 0.987–1.035 |
| branched | 1.000–1.026 | 1.053–1.064 | 1.013–1.022 |
| ball | 1.001–1.025 | 1.070–1.085 | 1.004–1.029 |
| free | 0.976–1.007 | 0.990–1.062 | 0.979–1.028 |
| free_ball | 0.996–1.027 | 1.007–1.038 | 0.968–1.001 |
| fixed_tendon | 0.974–1.002 | 1.015–1.060 | 0.983–0.994 |
| spatial_ball | 0.998–1.003 | 1.058–1.082 | 0.989–0.996 |
| chain_24 | 0.982–0.998 | 0.978–0.990 | 0.973–0.993 |
| branches_24 | 1.011–1.022 | 1.015–1.026 | 0.993–1.005 |

Some retained-variant cases remain uncertain, and repeatable small-model losses
are explicit in the raw intervals and decision. The official C3.17 wheel has
unknown library compiler flags; movement still trails C materially. These are
supported smooth Euler workloads, excluding contacts/constraints, sensors,
rendering and activation-state models, not final matched-build parity evidence.
Complete current-version migration, functional dynamics composition, shared stepping
and the full-port/performance objective remain open.

## Artifacts

The ZIP contains all source closures, actual scoped and whole-unit proof reports,
strict row corpora,three paired build families with raw sessions,actual vectorizer
dumps/assembly, failed representation/dump experiments, and full retained runtime
gates. Compiler/prover object/task caches, external toolchains and the external
C shared library are omitted; exact hashes, pins, flags and recipes remain.
Every member is hashed/reread and prior inventory entries are preserved.
