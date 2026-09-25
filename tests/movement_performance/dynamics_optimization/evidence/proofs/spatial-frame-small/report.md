# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-to6if2ve/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Frame_Offset` | `mj-spatial_kernels.adb:2` | [completed_no_unproved](logs/mj-spatial_kernels__frame_offset__adb_2.log) | 10 | 0 | 0 | 4.4 |
| `Mass_Moment` | `mj-spatial_kernels.adb:6` | [completed_no_unproved](logs/mj-spatial_kernels__mass_moment__adb_6.log) | 9 | 0 | 0 | 4.7 |

## Diagnostics

