# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-6040qwic/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Pack_Inertia` | `mj-spatial_kernels.adb:31` | [completed_no_unproved](logs/mj-spatial_kernels__pack_inertia__adb_31.log) | 2 | 0 | 0 | 3.8 |
| `Make_Inertia` | `mj-spatial_kernels.adb:36` | [completed_no_unproved](logs/mj-spatial_kernels__make_inertia__adb_36.log) | 62 | 0 | 0 | 44.9 |

## Diagnostics

