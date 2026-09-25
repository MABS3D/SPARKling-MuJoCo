# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-ttjpzgzo/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Ensure_Jacobians` | `mj-data-pipeline.adb:143` | [unproved_checks](logs/mj-data-pipeline__ensure_jacobians__adb_143.log) | 8 | 2 | 0 | 35.0 |

## Diagnostics

### mj-data-pipeline__ensure_jacobians__adb_143

- `mj-data-pipeline.adb:150` (medium): precondition might fail, cannot prove Joint_Poses'Last = Joints'Last [provers reached time limit before completing the proof]
- `mj-data-pipeline.ads:18` (medium): postcondition might fail [provers reached time limit before completing the proof]

