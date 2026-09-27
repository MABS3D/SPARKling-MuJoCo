# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-wejw2yuj/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Scaled_Pivot_Model` | `mj-smooth_dynamics.ads:63` | [completed_no_unproved](logs/mj-smooth_dynamics__scaled_pivot_model__ads_63.log) | 3 | 0 | 0 | 2.1 |
| `Scaled_Pivot` | `mj-smooth_dynamics.adb:83` | [completed_no_unproved](logs/mj-smooth_dynamics__scaled_pivot__adb_83.log) | 5 | 0 | 0 | 3.1 |
| `Prepare_Scaled_Diagonal` | `mj-smooth_dynamics.adb:88` | [completed_no_unproved](logs/mj-smooth_dynamics__prepare_scaled_diagonal__adb_88.log) | 26 | 0 | 0 | 6.4 |

## Diagnostics

