# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-hi2ud29e/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Column` | `mj-data-jacobians.adb:2` | [completed_no_unproved](logs/mj-data-jacobians__column__adb_2.log) | 12 | 0 | 0 | 24.9 |
| `Store_Column` | `mj-data-jacobians.adb:17` | [unproved_checks](logs/mj-data-jacobians__store_column__adb_17.log) | 16 | 1 | 0 | 7.2 |

## Diagnostics

### mj-data-jacobians__store_column__adb_17

- `mj-data-jacobians.ads:18` (medium): overflow check might fail, cannot prove lower bound for Linear'Last - 1 [reason for check: result of subtraction must fit in a 32-bits machine integer] [possible fix: use pragma Overflow_Mode or switch -gnato13 or unit SPARK.Big_Integers] [provers reached time limit before completing the proof]

