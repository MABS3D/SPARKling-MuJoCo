# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-wn4zodr5/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `whole unit` | `mj-activation.adb:1` | [unproved_checks](logs/mj-activation__whole_unit.log) | 25 | 1 | 0 | 18.6 |

## Diagnostics

### mj-activation__whole_unit

- `mj-activation.adb:15` (low): overflow check might fail [reason for check: value must fit in a 64-bits machine integer] [possible explanation: the check might be unprovable due to proof limitations; use --info for more information] [provers reached time limit before completing the proof]

