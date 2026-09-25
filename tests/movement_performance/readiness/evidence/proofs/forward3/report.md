# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-p46k30q5/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Evaluate` | `mj-data-forward.adb:4` | [completed_no_unproved](logs/mj-data-forward__evaluate__adb_4.log) | 4 | 0 | 0 | 26.8 |

## Diagnostics

