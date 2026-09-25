# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-i_5lh1um/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Copy_Matrix` | `mj-ancestor_rows.adb:2` | [analysis_error](logs/mj-ancestor_rows__copy_matrix__adb_2.log) | 0 | 0 | 1 | 2.1 |

## Diagnostics

### mj-ancestor_rows__copy_matrix__adb_2

- `mj-ancestor_rows.adb:7` (error): "Within_Work" is undefined (more references follow)

