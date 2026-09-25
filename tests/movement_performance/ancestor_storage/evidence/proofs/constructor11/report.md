# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-g1u5qcd1/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Build` | `mj-ancestor_rows.adb:146` | [analysis_error](logs/mj-ancestor_rows__build__adb_146.log) | 0 | 0 | 1 | 2.8 |

## Diagnostics

### mj-ancestor_rows__build__adb_146

- `mj-ancestor_rows.adb:158` (error): non-scalar object or object with address clause declared before loop-invariant is not yet supported

