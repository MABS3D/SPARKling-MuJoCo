# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-29hwvj4r/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Copy_Matrix` | `mj-ancestor_rows.adb:2` | [completed_no_unproved](logs/mj-ancestor_rows__copy_matrix__adb_2.log) | 62 | 0 | 0 | 27.1 |
| `Build` | `mj-ancestor_rows.adb:141` | [completed_no_unproved](logs/mj-ancestor_rows__build__adb_141.log) | 44 | 0 | 0 | 14.8 |

## Diagnostics

