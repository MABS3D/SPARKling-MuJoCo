# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-d2es9rtz/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Integrate` | `mj-data-euler.adb:5` | [unproved_checks](logs/mj-data-euler__integrate__adb_5.log) | 51 | 1 | 0 | 91.6 |

## Diagnostics

### mj-data-euler__integrate__adb_5

- `mj-data-euler.ads:26` (medium): postcondition might fail, cannot prove Input_Values (D) = Input_Values (D)'Old [provers reached time and memory limit before completing the proof]

