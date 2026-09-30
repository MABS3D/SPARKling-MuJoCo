# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-uraineco/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Exact_Factor` | `mj-activation.adb:3` | [unproved_checks](logs/mj-activation__exact_factor__adb_3.log) | 7 | 1 | 0 | 15.1 |
| `Next_Value` | `mj-activation.adb:20` | [completed_no_unproved](logs/mj-activation__next_value__adb_20.log) | 2 | 0 | 0 | 8.9 |
| `Prepare` | `mj-activation.adb:28` | [completed_no_unproved](logs/mj-activation__prepare__adb_28.log) | 5 | 0 | 0 | 7.3 |
| `Derivative` | `mj-activation.ads:14` | [completed_no_unproved](logs/mj-activation__derivative__ads_14.log) | 4 | 0 | 0 | 8.2 |
| `Raw_Next` | `mj-activation.ads:17` | [completed_no_unproved](logs/mj-activation__raw_next__ads_17.log) | 7 | 0 | 0 | 6.5 |

## Diagnostics

### mj-activation__exact_factor__adb_3

- `mj-activation.adb:15` (low): overflow check might fail [reason for check: value must fit in a 64-bits machine integer] [possible explanation: the check might be unprovable due to proof limitations; use --info for more information] [provers reached time limit before completing the proof]

