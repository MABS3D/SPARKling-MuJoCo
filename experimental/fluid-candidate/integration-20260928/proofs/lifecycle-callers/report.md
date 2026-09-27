# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-j94xzb5l/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Initialize` | `mj-data.adb:823` | [proof_timeout](logs/mj-data__initialize__adb_823.log) | 0 | 0 | 0 | 150.1 |
| `Create` | `mj-data.adb:874` | [unproved_checks](logs/mj-data__create__adb_874.log) | 2 | 1 | 0 | 26.1 |
| `Free` | `mj-data.adb:946` | [completed_no_unproved](logs/mj-data__free__adb_946.log) | 1 | 0 | 0 | 12.9 |

## Diagnostics

### mj-data__create__adb_874

- `mj-data.ads:104` (medium): postcondition might fail [provers reached time limit before completing the proof]

