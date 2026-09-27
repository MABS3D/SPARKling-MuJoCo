# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-z86b0kfd/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Store_Column` | `mj-data-jacobians.adb:17` | [completed_no_unproved](logs/mj-data-jacobians__store_column__adb_17.log) | 19 | 0 | 0 | 17.2 |
| `Build` | `mj-data-jacobians.adb:25` | [unproved_checks](logs/mj-data-jacobians__build__adb_25.log) | 59 | 2 | 0 | 29.6 |

## Diagnostics

### mj-data-jacobians__build__adb_25

- `mj-data-jacobians.ads:56` (medium): postcondition might fail, cannot prove Linear (I) = 0.0 [provers reached time limit before completing the proof]
- `mj-data-jacobians.ads:56` (medium): array index check might fail [reason for check: value must be a valid index into the array] [provers reached time limit before completing the proof]

