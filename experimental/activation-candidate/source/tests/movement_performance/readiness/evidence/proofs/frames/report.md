# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-_aisz99p/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Configuration_Equality` | `mj-data.adb:38` | [completed_no_unproved](logs/mj-data__prove_configuration_equality__adb_38.log) | 22 | 0 | 0 | 26.4 |
| `Equal_Configurations` | `mj-data.adb:54` | [completed_no_unproved](logs/mj-data__equal_configurations__adb_54.log) | 22 | 0 | 0 | 15.8 |
| `Equal_Input_Images` | `mj-data.adb:37` | [completed_no_unproved](logs/mj-data__equal_input_images__adb_37.log) | 7 | 0 | 0 | 7.7 |

## Diagnostics

