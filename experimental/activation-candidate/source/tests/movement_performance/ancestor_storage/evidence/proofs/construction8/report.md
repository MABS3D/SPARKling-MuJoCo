# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-a09sntk8/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Row_Frame` | `mj-ancestor_rows.adb:50` | [completed_no_unproved](logs/mj-ancestor_rows__prove_row_frame__adb_50.log) | 84 | 0 | 0 | 8.0 |
| `Append_Row` | `mj-ancestor_rows.adb:69` | [unproved_checks](logs/mj-ancestor_rows__append_row__adb_69.log) | 160 | 2 | 0 | 33.7 |

## Diagnostics

### mj-ancestor_rows__append_row__adb_69

- `mj-ancestor_rows.adb:102` (medium): assertion might fail, cannot prove Starts (Columns (A) + 1) - Starts (Columns (A)) = A - Starts (I) + 1 [provers reached time limit before completing the proof]
- `mj-ancestor_rows.adb:106` (medium): assertion might fail, cannot prove Columns (A) = Columns (Starts (Columns (Starts (I + 1) - 2)) + A - Starts (I)) [provers reached time limit before completing the proof]

