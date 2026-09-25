# Historical transpose candidate before boundary fixes

**Historical candidate; not the final accepted implementation.** Complete
proof and numerical results below belong to the included matrix source files.
The 44-case shared run exposed a 63×63 regression of about 18% against baseline
and slower-than-C five-row cases. A separate-build boundary confirmation
repeated those findings. They motivated a dedicated five-row helper and a
narrower vector-hint dispatch in the next candidate.

The shared executable also changes LTO inlining in unchanged non-transpose
kernels: whole-run performance classification counts are specific to that
artificial dual-version context. Separate-build measurements are required
before judging the normal one-version build. The raw shared data are retained.
See [current evidence](../README.md).

The candidate transpose specializes one through four input rows, copies pairs for
five through fifteen rows, and uses a vector hint for square dimensions 16–64.
Empty axes return immediately. Other shapes use the original general copy core.
All paths retain the exact component relation and prove full initialization.
The public domain and executable component postcondition are preserved.

The performance gate remains **OPEN**. These measurements are warm-buffer
microbenchmarks, not an integrated engine workload or a universal parity claim.
See [the current report](../../../../docs/matrix-performance.md) and
[reproduction instructions](../../README.md).

## Measurement protocol

The immutable baseline is commit `2c26e49b`. Both Ada versions and one normal
MuJoCo 3.14.0 C SIMD implementation are linked in the same executable. The
comparison uses four-treatment Williams blocks with equal repetitions, separate
CPU/wall clocks, context-switch counts, checksums, order strata and bootstrap
95% intervals. All samples are retained. Each group of four blocks balances
positions and directed adjacent-treatment pairs exactly.

The full run uses 228 original cases, 16 blocks and a 15 ms target; the focused
run uses 44 transpose cases, 32 blocks and a 25 ms target with another seed.
The calibration bounds repetitions to 1,000–50,000,000; raw reports record both
requested and actual repetitions and whether the bound was reached. Actual
sample duration may therefore differ from the target. CPU 12 on the Ryzen 7
9800X3D, x86-64 Linux/WSL; GNAT/GCC/GNATprove 16.1, GPRbuild 26. No compilation,
proof run or test suite runs concurrently with timing.

Individual intervals have no multiplicity correction and capture only their
session. An interval containing one is inconclusive, not proof of equivalence.
C/C is a same-code control; its fluctuations remain visible. Empty-shape results
mostly time the surviving repetition/barrier machinery. Faster cases are not
weighted into a claimed engine speedup and do not cancel slower cases.

[Build metadata](build.json) binds the source snapshots, generated baseline,
compiler and recipe to the measured executable. The comparator records binary
hashes before and after each run. Timing checksums detect mismatched workloads
but cannot detect every wrong permutation; the numerical probes compare every
output component separately.

## Formal and numerical verification

[Proof summary](proof-summary.json): five complete numeric units pass **3,472
checks, zero unproved, 70 reviewed warnings**. The matrix package contributes
2,365 checks; matrix models 307, matrix types 51, BLAS 607, vector models 142.
The five new warnings concern ignored transpose loop-optimization hints.
No new assumption, suppression, application trusted body or deallocator change
was introduced. Gold describes the specified floating-point algorithm, not
ideal real-algebra identities or quantitative numerical-error bounds.

[Small diagnostics](minimal/summary.json) first pass all eight transpose helper/
public targets; the runner also includes the unchanged `Transposed_Sweep`.
The diagnostic logs are retained but do not substitute for complete-unit proof.
[Full numeric proof log](proof/full-numeric-proof.log), each `proof/*.spark`, and
each original `proof/*.invocation.json` retain the real source-bound evidence.
The eight receipts were checked against the production sources at this historical snapshot and report
hashes. The proof process-group memory cap remains 4,000 MB.

The pose-family proof refresh contributes another **694 checks, zero unproved,
nine reviewed warnings**: quaternions 422, poses 204, rotations 68. These fresh
reports and receipts bind unchanged pose code to the updated global matrix
source snapshot. Old pose evidence is preserved; this refresh makes no new pose
performance claim.

[Numerical summary](final-numeric.json): development, validation and release
pass 1,097 Ada assertions and 72 Python tests each. After extending the probes,
the matrix comparisons were rebuilt and rerun in each profile and all 72 Python
tests were repeated. Each profile has 523 full matrix cases / 543,296 scalar
comparisons, plus 30 transpose-only large/boundary cases / 134,485 comparisons.
Together with unchanged vector/BLAS checks, coverage is 4,196 cases /
1,420,274 comparisons per profile. The release probe also passes both matrix
corpora against the actual native SIMD C reference (677,781 comparisons).
Finite values are compared exactly; signed-zero bits and NaN payloads are not.
This is empirical compatibility evidence, not a universal C-equivalence proof.

The first attempt to run all matrix operations at dimension 128 exceeded the
60-second development-probe timeout, with expensive unrelated Gram runtime
contracts active. Its log is retained. Large cases were then isolated to
Transpose using `--transpose-only` in both probes; all final runs pass.
The original 451-case full-operation prefix is preserved, with 72 appended
transpose dispatch cases and the separate 30-case large corpus.

## Generated code and experimental history

[Code-generation audit](final-codegen.json) and
[disassembly](final-hot-loops.asm) cover all 60 timing wrappers (20 operations
for current Ada, baseline Ada and C) and their resolved direct callees/targets.
No FMA or executable ghost/secondary-stack symbol appears in that scope.
Packed double arithmetic is present. After normalizing addresses, alignment,
branch labels and package names, 19 of 20 Ada wrappers have identical
instruction text; only Transpose changes. This does not make caller layout or
microarchitectural effects irrelevant. The transpose wrapper grows from 200 to
670 decoded instructions in this build; integrated instruction-cache effects
remain unmeasured.

[Exploration archive](exploration.zip) preserves measured and rejected source
variants, small proof logs, numerical reports and timing data, with its own
manifest. Source-first traversal, broad vector hints and forced paired loads
were not promoted. The lanes prototype was proved and inspected but not timed.
The retained square-vector pilot is historical evidence; acceptance figures
come from the final rebuilt executable, not a selected pilot run.
Separate executable experiments showed C-reference drift, which motivated the
shared C control. The archive retains those measurements rather than hiding
unfavorable outcomes. Historical diagnostic logs are not complete-unit receipts.

`collect_numeric.py` and `normalize_wrappers.py` are records of collection in the
original workspace; their absolute paths document that run. The reusable build,
comparison and proof tools live in the parent fixture. The
[manifest](manifest.json) hashes all evidence files except itself.

Metadata erratum: the historical comparator described switch counts as including
preparation/checksum. The C driver actually reads involuntary thread switches
around the timed kernel and clock calls, excluding preparation and checksum.
The current comparator corrects that description; the raw historical counts and
timing data are unchanged. Its exact old script is preserved as compare_builds.py.
