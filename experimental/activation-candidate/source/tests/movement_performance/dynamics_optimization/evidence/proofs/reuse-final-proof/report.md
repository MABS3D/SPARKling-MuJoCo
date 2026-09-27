# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-zsghf5tq/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prepared_Mass_Contribution` | `mj-smooth_dynamics.adb:60` | [completed_no_unproved](logs/mj-smooth_dynamics__prepared_mass_contribution__adb_60.log) | 18 | 0 | 0 | 5.6 |
| `Prepare_Mass_Columns` | `mj-smooth_dynamics.adb:164` | [completed_no_unproved](logs/mj-smooth_dynamics__prepare_mass_columns__adb_164.log) | 28 | 0 | 0 | 22.6 |
| `Scaled_Pivot_Model` | `mj-smooth_dynamics.ads:63` | [completed_no_unproved](logs/mj-smooth_dynamics__scaled_pivot_model__ads_63.log) | 3 | 0 | 0 | 3.1 |
| `Scaled_Pivot` | `mj-smooth_dynamics.adb:83` | [completed_no_unproved](logs/mj-smooth_dynamics__scaled_pivot__adb_83.log) | 5 | 0 | 0 | 3.1 |
| `Prepare_Scaled_Diagonal` | `mj-smooth_dynamics.adb:88` | [completed_no_unproved](logs/mj-smooth_dynamics__prepare_scaled_diagonal__adb_88.log) | 26 | 0 | 0 | 6.6 |

## Diagnostics

