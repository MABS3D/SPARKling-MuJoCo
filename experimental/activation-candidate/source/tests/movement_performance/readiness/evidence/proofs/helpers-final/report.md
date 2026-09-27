# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-82ug85v4/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Readiness_Decomposition` | `mj-data.adb:24` | [completed_no_unproved](logs/mj-data__prove_readiness_decomposition__adb_24.log) | 1 | 0 | 0 | 23.1 |
| `Prove_Configuration_Equality` | `mj-data.adb:40` | [completed_no_unproved](logs/mj-data__prove_configuration_equality__adb_40.log) | 22 | 0 | 0 | 10.2 |
| `Equal_Configurations` | `mj-data.adb:56` | [completed_no_unproved](logs/mj-data__equal_configurations__adb_56.log) | 22 | 0 | 0 | 12.6 |
| `Equal_Input_Images` | `mj-data.adb:39` | [completed_no_unproved](logs/mj-data__equal_input_images__adb_39.log) | 7 | 0 | 0 | 7.0 |
| `Invalidate` | `mj-data.adb:72` | [completed_with_warnings](logs/mj-data__invalidate__adb_72.log) | 1 | 0 | 0 | 6.9 |

## Diagnostics

### mj-data__invalidate__adb_72

- `mj-data.ads:658` (warning): unused initial value of "Cache"

