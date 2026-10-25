# Reduction unit closure and qualified bottleneck diagnosis

The actual working reduction unit now closes **837 checks: 748 proof and 89
flow**, independently on the production C3.14 and candidate C3.17 dependency
closures. Both complete reports have full coverage, unchanged frozen sources,
no skipped/assumed obligations and no open check. Twenty existing diagnostics
(recursive contracts/variants and integer operator reassociation) are preserved;
strict warning-free `passed` remains false. This is scoped floating-point
functional/safety proof under the called contracts, not whole dynamics Gold,
ideal-real accuracy, complete engine migration or C performance parity.

## Adopted proof changes

The lane model delegates its identical rounded addition to the already specified
Accumulate function. The tail model delegates each ordered addition to a fully
proved scalar helper, retaining its original 5e125 bound and strengthening it with
a per-tail bound. Empty models, small rows, empty-prefix acceptance and tail
unfolding are proved through explicit base/unfold facts. Prove_Small_Row keeps
its full original postcondition, as do Forward_Value and all runtime operations.
A proved cut before tail processing retains the complete base value, dimensions,
validity and rejection count while discarding irrelevant proof history.

No narrower public input domain, assumed fact, suppressed check or new trusted
production body is introduced. Existing modeled deallocators are unchanged.
The direct arithmetic and fused compiler-boundary experiments remain private;
the adopted runtime keeps the published arithmetic, dispatch and rejection rules.

`source-binding.json` and exact source snapshots in the archive bind the two
successful whole proofs to the actual working owners. The 3.14 closure matches
completely; the actual 3.17 preparation adds only the two explicitly recorded,
unused reduction-test providers to the earlier frozen proof closure. The default
production GPR release build and normal shared movement builder are rebuilt.
All four reference/profile reduction corpora pass **36,079 cases each**, and the
actual movement executables pass all 30 original endpoint scenarios with exact
Ada baseline/current values and the recorded C tolerance.

Full-program disassembly differs in just **eight source-line immediates passed
to GNAT range/overflow failure routines**. Instruction locations/lengths and all
other instruction bytes match. Read-only and writable data sections are identical.
This demonstrates unchanged successful-path machine work; no speedup is claimed
for a proof-only edit. Original mathematical evaluation order is retained.

## Preserved incomplete diagnostics

The archive retains the intermediate 874/three-open and 821/two-open unit
reports, the later one-open attempts, minimum successes and their actual effort
settings. A scoped success is never substituted for an incomplete unit report.
The final 3.17 r595 and 3.14 r597 reports are the completed acceptance evidence.
The initial 3.14 metadata validation used a wrong JSON key; the source overlay
had completed, the same live proof continued, and a subsequent explicit
`reference == 3.14.0`/hash validation is recorded. No proof/source was silently
restarted or changed to hide that preparation error.

## Sampling diagnosis

The system gprofng 2.42 collector reports that its interval timer changed to zero
at both requested intervals. Its CPU totals are inconsistent with execution
length; its phase percentages are quarantined. The bundled 2.46.1 collector
cannot start because its collection shared library is absent. Neither supplies
accepted bottleneck evidence. The failed .er trees are excluded from the portable
bundle because they may contain environment dumps; explicit safe outputs and
qualification records remain.

A test-only Linux/x86-64 sampler uses an independent POSIX per-main-thread CPU
timer and a real-time signal, recording interrupted instruction pointers, CPU
timestamps, overruns, handler/timer invariance and executable maps. It does not
modify the subject binaries or provide a production/proof premise. A control
runs known one-/two-second CPU phases while deliberately disabling ITIMER_PROF:
804 PC samples cover 3.00014 CPU seconds, with 2,997 accounted ticks for about
3,000 nominal ticks; the second phase has about twice the first's samples. Raw
control data and source are retained. Signal delivery is coarser than the nominal
one-millisecond period; overruns and observed gaps remain explicit.

With own compiler/prover/archive jobs idle, chain24 state 0 is run for 5,000
repeated 100-step trajectories on CPU 12, including normal initialization/output.
Every endpoint passes its numerical oracle. Ada contributes 2,309 samples over
8.60269 CPU seconds; C contributes 993 over 3.69947. Both handlers and timer
periods stay unchanged. These profiled durations include sampler overhead and
are **not** the replicated performance acceptance measurements.

The Ada flat sample shares are approximately:

| Function | Samples | Share of all samples |
| --- | ---: | ---: |
| Solve_Compatible_Buffers | 591 | 25.60% |
| Solve_Acceleration, including inlined helpers | 361 | 15.63% |
| Compact_Assembly.Fill | 226 | 9.79% |
| Smooth_Math.Cross | 184 | 7.97% |
| Forces_Phase.Try_Recursive | 132 | 5.72% |
| Solver_Reductions.Dot_Four | 106 | 4.59% |

These are flat sampled proportions, not additive inclusive phase timings or
causal savings estimates. C's corresponding flat leaders include mju_addToScl,
mj_factorI and mj_solveLD. Raw PCs and hot instruction locations are retained.
On the sampled Ada factorization, hot instructions belong to the short scalar
row-update loop, with per-entry bounds/rejection work. The reviewed C3.17 AVX
row update enters its vector loop at four elements; the published Ada dispatch
selects the long-row backend from 16. A threshold-eight re-evaluation is a new
private experiment on the current baseline; its proof/corpus/timing acceptance
is separate and it is not adopted here.

## Portable evidence

`reduction-closure.zip` retains completed frozen sources, copied SPARK reports,
logs, binaries, numerical outputs and custom sampling records. Compiler/prover
caches are excluded. Toolchains, reference shared libraries and historical input
fixtures are identified by hashes or prior exact r556/r503 bundles. Restore ZIP
bytes through `tools/evidence_store.py restore` before extraction; no archive is
recompressed by restoration. Original inventory entries remain unchanged.

All changes after the requested GitHub push remain local.
