# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-aagzwbmz/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Ensure_Jacobians` | `mj-data-pipeline.adb:143` | [unproved_checks](logs/mj-data-pipeline__ensure_jacobians__adb_143.log) | 36 | 10 | 0 | 28.9 |

## Diagnostics

### mj-data-pipeline__ensure_jacobians__adb_143

- `mj-data-pipeline.adb:161` (medium): array index check might fail [reason for check: value must be a valid index into the array] [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:173` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [possible fix: loop at line 163 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:173` (medium): in inlined expression function body at mj-smooth_math.ads:19
- `mj-data-pipeline.adb:173` (medium): precondition might fail, cannot prove V (0) in -Limit .. Limit [possible fix: loop at line 163 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:173` (medium): in inlined expression function body at mj-smooth_math.ads:19
- `mj-data-pipeline.adb:181` (medium): precondition might fail, cannot prove Offset >= A'First [possible fix: loop at line 163 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:181` (medium): pointer dereference check might fail [possible fix: loop at line 163 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-pipeline.adb:182` (medium): precondition might fail, cannot prove Offset >= A'First [possible fix: loop at line 163 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- 2 more diagnostics in the individual log.

