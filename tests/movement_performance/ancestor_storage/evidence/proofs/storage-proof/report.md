# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-f4czppey/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Ancestor_Storage_Ready` | `mj-data.ads:565` | [completed_no_proof_checks](logs/mj-data__ancestor_storage_ready__ads_565.log) | 0 | 0 | 0 | 20.2 |
| `Allocate_Scratch` | `mj-data.adb:432` | [completed_no_unproved](logs/mj-data__allocate_scratch__adb_432.log) | 24 | 0 | 0 | 8.2 |
| `Free_Scratch` | `mj-data.adb:794` | [completed_no_unproved](logs/mj-data__free_scratch__adb_794.log) | 1 | 0 | 0 | 6.7 |
| `Clear_Scratch` | `mj-data.adb:914` | [completed_no_unproved](logs/mj-data__clear_scratch__adb_914.log) | 85 | 0 | 0 | 15.5 |
| `Prove_Readiness_Compatibility` | `mj-data.adb:24` | [completed_no_unproved](logs/mj-data__prove_readiness_compatibility__adb_24.log) | 1 | 0 | 0 | 18.0 |

## Diagnostics

