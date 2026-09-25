# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-2te3w4vf/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Row_OK` | `mj-ancestor_rows.ads:51` | [completed_no_unproved](logs/mj-ancestor_rows__row_ok__ads_51.log) | 39 | 0 | 0 | 4.2 |
| `Build` | `mj-ancestor_rows.adb:2` | [unproved_checks](logs/mj-ancestor_rows__build__adb_2.log) | 99 | 8 | 0 | 45.2 |
| `Free` | `mj-ancestor_rows.adb:36` | [completed_no_unproved](logs/mj-ancestor_rows__free__adb_36.log) | 5 | 0 | 0 | 2.8 |

## Diagnostics

### mj-ancestor_rows__build__adb_2

- `mj-ancestor_rows.adb:24` (medium): range check might fail [reason for check: slice bounds must fit in the underlying array] [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:28` (medium): array index check might fail [reason for check: result of subtraction must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:29` (medium): precondition might fail, cannot prove S in 0 .. Columns'Length [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:29` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Row_OK (Starts, P.Columns.all, J) [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:32` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove P.Columns (Starts (J + 1) - 2) = Parents (J) [provers reached time limit before completing the proof]
- `mj-ancestor_rows.ads:35` (medium): invariant check might fail, cannot prove Valid (Pattern) [provers reached time limit before completing the proof]
- `mj-ancestor_rows.ads:35` (medium): in inlined invariant at mj-ancestor_rows.ads:49
- `mj-ancestor_rows.ads:35` (medium): for "P" at the end of "Build" at mj-ancestor_rows.ads:35

