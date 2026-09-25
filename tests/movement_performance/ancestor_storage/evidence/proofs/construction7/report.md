# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-8y14pium/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Row_Frame` | `mj-ancestor_rows.adb:50` | [unproved_checks](logs/mj-ancestor_rows__prove_row_frame__adb_50.log) | 12 | 1 | 0 | 11.7 |
| `Append_Row` | `mj-ancestor_rows.adb:63` | [unproved_checks](logs/mj-ancestor_rows__append_row__adb_63.log) | 88 | 1 | 0 | 20.8 |

## Diagnostics

### mj-ancestor_rows__prove_row_frame__adb_50

- `mj-ancestor_rows.adb:57` (medium): postcondition might fail [provers reached time limit before completing the proof]

### mj-ancestor_rows__append_row__adb_63

- `mj-ancestor_rows.adb:94` (medium): assertion might fail [provers reached time limit before completing the proof]

