# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-k433to5r/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `line 171` | `mj-data-inertia.adb:171` | [completed_no_proof_checks](logs/mj-data-inertia__adb_line_171.log) | 0 | 0 | 0 | 16.0 |
| `line 127` | `mj-data-forces.adb:127` | [completed_no_proof_checks](logs/mj-data-forces__adb_line_127.log) | 0 | 0 | 0 | 2.6 |

## Diagnostics

