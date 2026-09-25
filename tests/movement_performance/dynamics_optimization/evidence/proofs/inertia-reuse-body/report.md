# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-odyjxyp4/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prepare_Mass_Columns` | `mj-smooth_dynamics.adb:147` | [completed_no_unproved](logs/mj-smooth_dynamics__prepare_mass_columns__adb_147.log) | 28 | 0 | 0 | 21.5 |
| `Add_Mass_Body` | `mj-smooth_dynamics.adb:162` | [proof_timeout](logs/mj-smooth_dynamics__add_mass_body__adb_162.log) | 0 | 0 | 0 | 20.3 |

## Diagnostics

