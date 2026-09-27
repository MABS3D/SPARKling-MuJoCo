# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-v0nvjpq8/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Copy_Row` | `mj-ancestor_rows.adb:2` | [completed_no_unproved](logs/mj-ancestor_rows__copy_row__adb_2.log) | 41 | 0 | 0 | 7.7 |
| `Append_Row` | `mj-ancestor_rows.adb:50` | [unproved_checks](logs/mj-ancestor_rows__append_row__adb_50.log) | 62 | 2 | 0 | 22.6 |
| `Build` | `mj-ancestor_rows.adb:78` | [completed_no_unproved](logs/mj-ancestor_rows__build__adb_78.log) | 44 | 0 | 0 | 14.5 |

## Diagnostics

### mj-ancestor_rows__append_row__adb_50

- `mj-ancestor_rows.adb:61` (medium): postcondition might fail, cannot prove Row_OK (Starts, Columns, J) [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:75` (medium): assertion might fail [provers reached time limit before completing the proof]

