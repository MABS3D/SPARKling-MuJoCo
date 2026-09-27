# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-g4l5znhj/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Invalidate` | `mj-data.adb:72` | [completed_with_warnings](logs/mj-data__invalidate__adb_72.log) | 1 | 0 | 0 | 19.1 |

## Diagnostics

### mj-data__invalidate__adb_72

- `mj-data.ads:658` (warning): unused initial value of "Cache"

