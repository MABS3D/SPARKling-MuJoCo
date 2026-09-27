# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-v0doh6q_/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-data-jacobians.adb:1` | [unproved_checks](logs/mj-data-jacobians__whole_unit.log) | 101 | 2 | 0 | 66.6 |

## Diagnostics

### mj-data-jacobians__whole_unit

- `mj-data-jacobians.ads:33` (medium): range check might fail, cannot prove upper bound for Joints'Length [provers reached time limit before completing the proof]
- `mj-data-jacobians.ads:36` (medium): range check might fail, cannot prove upper bound for Joints'Length [provers reached time limit before completing the proof]

