# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-goo8ro2k/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Apply` | `mj-smooth_math.adb:36` | [completed_no_unproved](logs/mj-smooth_math__apply__adb_36.log) | 119 | 0 | 0 | 32.0 |
| `Apply_Transpose` | `mj-smooth_math.adb:79` | [completed_no_unproved](logs/mj-smooth_math__apply_transpose__adb_79.log) | 119 | 0 | 0 | 30.4 |

## Diagnostics

