# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-m_msxag9/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prepared_Mass_Contribution` | `mj-smooth_dynamics.adb:60` | [completed_no_unproved](logs/mj-smooth_dynamics__prepared_mass_contribution__adb_60.log) | 18 | 0 | 0 | 6.9 |
| `Prepare_Mass_Columns` | `mj-smooth_dynamics.adb:147` | [unproved_checks](logs/mj-smooth_dynamics__prepare_mass_columns__adb_147.log) | 27 | 3 | 0 | 19.5 |

## Diagnostics

### mj-smooth_dynamics__prepare_mass_columns__adb_147

- `mj-smooth_dynamics.adb:156` (medium): "Columns" might not be initialized
- `mj-smooth_dynamics.ads:80` (medium): "Columns" might not be initialized in "Prepare_Mass_Columns" [reason for check: OUT parameter should be fully initialized on return] [possible fix: initialize "Columns" on all paths, make "Columns" an IN OUT parameter or annotate it with aspect Relaxed_Initialization]
- `mj-smooth_dynamics.ads:85` (medium): "Columns" might not be initialized

