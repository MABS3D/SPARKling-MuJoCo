# Transpose optimization evidence

Transpose now specializes one through five input rows, copies pairs for six
through fifteen rows, and uses a vector hint only for square dimensions 16 and
64. Empty axes return immediately. Other shapes retain the original general
copy core. Every path proves full initialization and the exact component
relation. The input domain and executable public component postcondition remain
in place; no preliminary clearing is required.

The overall matrix performance gate remains **OPEN**. These are warm-buffer
microbenchmarks, not an integrated engine workload or universal parity proof.
See [the current report](../../../docs/matrix-performance.md) and
[reproduction instructions](../README.md).

## Results and remaining work

[Summary](summary.json), [full run](full.json), [transpose run](transpose.json),
[general follow-up](regression-followup.json), and
[longer transpose follow-up](transpose-followup.json) retain all raw data.
The full run has 88 faster, 40 inconclusive and 100 slower cases versus C;
the remeasured baseline has 84, 36 and 108 respectively. These counts are not
weighted engine speedups or a causal count of fixed cases.

All 40 nonempty transpose cases are faster than C. The 49 cases represent
47 distinct shapes (38 nonempty); 64x16 and 64x64 repeat with different unused
nk values. Seven empty cases flag slower than C in the focused run; six repeat
in the longer follow-up. No absolute/percentage allowance is used to discard
them. Their roughly 0.1 ns timings mostly describe no-work repetition/barrier
machinery and do not establish standalone call latency.

Against previous Ada, 63x16 (+2.8%, CI [1.016,1.041]) and 128x128 (+2.0%, CI
[1.010,1.026]) repeat as slower. They still take about 47% and 75% less time than
C, respectively, but those favorable C comparisons do not erase the regressions.
65x16 is inconclusive in the follow-up. Eight of the nine general-run Ada/Ada
slowdown flags do not recur in their separate follow-up; the remaining one is
the empty transpose case. All flags and C/C controls remain in the reports.

An [isolated Inline_Always probe](inline-probe/README.md) passes its dispatcher
proof and numeric checks but is rejected for promotion: improvements in 3x3
come with roughly 20–24% regressions in 5x32 and 4x4 against the retained version.

## Final measurement protocol

The primary comparison uses separate executables, each containing one Ada
version plus normal MuJoCo 3.14.0 C SIMD. The immutable Ada baseline is commit
`2c26e49b`. [Baseline build](build-baseline.json) and
[current build](build-current.json) bind sources, generated files, compiler and
recipe to the actual binaries. The comparator checks executable hashes before
and after timing and retains paired Ada/Ada, C/C and both Ada/C ratios.

Four-treatment Williams blocks balance positions and directed adjacent pairs
exactly in each group of four. All samples are retained, with CPU/wall clocks,
MAD, bootstrap intervals, order strata, checksums and involuntary thread
context-switch counts around the timed region. Preparation and checksum are
outside both clocks. Repetitions are identical for all four slots; calibration
is bounded to 1,000–50,000,000 and both requested/actual counts are recorded.
Target durations are not a guarantee of actual sample duration.

The full run uses 228 original cases, 16 blocks and a 15 ms target. The focused
run uses 49 transpose cases, 32 blocks and a 25 ms target with another seed.
CPU 12 on Ryzen 7 9800X3D, x86-64 Linux/WSL; GNAT/GCC/GNATprove 16.1 and GPRbuild
26. The two follow-ups use 32 blocks, with 25 ms (general flags) and 100 ms
(transpose flags) targets. No proof, compilation or test suite runs concurrently with final timing.

Intervals are individual within-session estimates without multiplicity
correction; they do not capture all between-session drift. An interval containing
one is inconclusive, not proof of equivalence. C/C makes reference drift and
layout effects visible. Empty shapes mostly measure repetition/barrier overhead;
CopyRows also selects zero rows when the row count is one. Favorable cases do
not cancel slower cases, and no production-workload weighting is assumed.

## Formal and numerical verification

[Proof summary](proof-summary.json): five complete numeric units pass **3,504
checks, zero unproved, 71 reviewed warnings**. Matrix code contributes 2,397,
matrix models 307, matrix types 51, BLAS 607, vector models 142. The six additional
warnings versus the published baseline concern ignored transpose loop hints.
Existing reviewed warnings and the deallocation/modeling boundaries remain.
There is no new assumption, suppression or application trusted body. Gold refers
to the specified floating-point algorithm, not ideal real-algebra identities or
quantitative numerical-error bounds.

[Small diagnostics](minimal/summary.json) pass all nine transpose helper/public
targets first; the runner also checks the unchanged `Transposed_Sweep`.
[Complete numeric proof log](proof/full-numeric-proof.log), the `proof/*.spark`
reports and original `proof/*.invocation.json` receipts retain actual full-unit
coverage. The receipts were checked against current source and report hashes.
The proof process-group cap remains 4,000 MB.

The pose-family refresh adds **694 proved checks, zero unproved and nine
reviewed warnings**: quaternions 422, poses 204, rotations 68. Fresh reports and
receipts bind unchanged pose code to the new global matrix source snapshot.
Historical pose receipts remain unchanged. No new pose timing claim is made.

[Numerical summary](numeric.json): development, validation and release each
pass **1,097 Ada assertions**, **72 Python tests**, and **1,438,490 C comparisons
over 4,218 cases**. Matrix coverage is 535 full-operation cases / 544,872 scalar
comparisons plus 40 transpose-only large/boundary cases / 151,125 comparisons.
The release probe additionally passes those 695,997 matrix comparisons against
actual native SIMD C; its [build metadata](native-reference-build.json) records
the compiler command and reference hashes. Finite values are compared exactly; signed-zero bits and
NaN payloads are not compared. This is empirical compatibility evidence, not a
universal C-equivalence proof.

The full-operation corpus preserves the historical 451-case prefix and adds
84 dispatch cases. Large cases exercise 32, 48, 64, 65 and 128 dimensions,
including distinct component values that expose wrong permutations. A checksum
sum alone cannot validate a transpose. `tests-*.log`, `native-numeric.log` and
the numerical summary retain the final outcomes and hashes.

## Generated code and historical experiments

[Code-generation audit](standalone-codegen.json) covers 40 timing wrappers per
binary (20 Ada and 20 C) and their resolved direct targets. No FMA or executable
ghost/secondary-stack symbol occurs in that scope. Disassembly is preserved for
[baseline](standalone-baseline-hot-loops.asm) and
[current](standalone-current-hot-loops.asm). After normalizing relocation,
alignment and branch labels, 19 of 20 Ada wrappers and all 20 C wrappers have
the same instruction text across versions. Only Transpose changes. This does
not establish identical code placement or instruction-cache behavior in an
integrated caller. The transpose timing wrapper grows from 875 to 2,800 bytes.

The [preceding candidate](before-boundary-fix/README.md) retains source files,
complete proofs, numerical results, the 228/44-case shared-executable runs, a
separate-build confirmation, and the earlier exploration archive. Its broad
16–64 vector path regressed at 63×63, and five-row pair copies remained slower
than C. The final candidate narrows that dispatch and adds a five-row helper.
The [boundary-fix pilot](boundary-fixed-comparison.json) was run only after the
new smallest-helper/dispatcher proofs and release numerical checks passed;
final acceptance figures come from the subsequent full and focused runs.

The shared-executable experiment links both Ada versions and one C reference.
It removes between-binary C-code variation but changes LTO inlining elsewhere:
unchanged Ada kernels gain out-of-line calls absent from the normal one-version
builds. Its whole-run counts are not interchangeable with primary results.
Those unfavorable data are retained rather than attributed to the transpose
source change or silently discarded. Historical switch-scope metadata is
corrected by an explicit erratum, preserving all original raw measurements.

`collect_numeric.py` and `audit_standalone.py` record collection in the original
workspace and retain its absolute paths. Reusable build, comparison and proof
tools live in the parent fixture. The [manifest](manifest.json) hashes all
current and historical evidence files except itself.
