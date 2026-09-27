# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-dy8oscig/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Prove_Readiness_Compatibility` | `mj-data.adb:24` | [completed_no_unproved](logs/mj-data__prove_readiness_compatibility__adb_24.log) | 1 | 0 | 0 | 24.9 |
| `Prove_Jacobian_Readiness` | `mj-data.adb:25` | [completed_no_unproved](logs/mj-data__prove_jacobian_readiness__adb_25.log) | 1 | 0 | 0 | 6.8 |
| `Invalidate` | `mj-data.adb:73` | [completed_with_warnings](logs/mj-data__invalidate__adb_73.log) | 1 | 0 | 0 | 6.7 |

## Diagnostics

### mj-data__invalidate__adb_73

- `mj-data.ads:683` (warning): unused initial value of "Cache"

