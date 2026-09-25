# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-gs2504_x/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Build_Offsets` | `mj-ancestor_rows.adb:9` | [unproved_checks](logs/mj-ancestor_rows__build_offsets__adb_9.log) | 63 | 1 | 0 | 14.3 |
| `Append_Row` | `mj-ancestor_rows.adb:35` | [unproved_checks](logs/mj-ancestor_rows__append_row__adb_35.log) | 47 | 2 | 0 | 12.1 |
| `Build` | `mj-ancestor_rows.adb:57` | [unproved_checks](logs/mj-ancestor_rows__build__adb_57.log) | 44 | 1 | 0 | 13.6 |

## Diagnostics

### mj-ancestor_rows__build_offsets__adb_9

- `mj-ancestor_rows.adb:28` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Starts (J) <= Starts (K) [provers reached time limit before completing the proof]

### mj-ancestor_rows__append_row__adb_35

- `mj-ancestor_rows.adb:40` (medium): range check might fail, cannot prove upper bound for Columns'Length [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:44` (medium): postcondition might fail, cannot prove Row_OK (Starts, Columns, J) [provers reached time limit before completing the proof]

### mj-ancestor_rows__build__adb_57

- `mj-ancestor_rows.adb:70` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove P.Columns (Starts (J + 1) - 2) = Parents (J) [provers reached time limit before completing the proof]

