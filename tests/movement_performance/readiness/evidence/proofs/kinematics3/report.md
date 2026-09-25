# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-3wpbbmg7/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Update` | `mj-data-kinematics.adb:4` | [unproved_checks](logs/mj-data-kinematics__update__adb_4.log) | 6 | 1 | 0 | 24.6 |

## Diagnostics

### mj-data-kinematics__update__adb_4

- `mj-data-kinematics.ads:10` (medium): postcondition might fail, cannot prove Configuration (D) = Configuration (D)'Old [provers reached time limit before completing the proof]

