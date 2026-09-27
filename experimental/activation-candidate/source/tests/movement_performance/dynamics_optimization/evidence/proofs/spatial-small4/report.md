# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-vipl3h6h/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Make_Inertia` | `mj-spatial_kernels.adb:31` | [unproved_checks](logs/mj-spatial_kernels__make_inertia__adb_31.log) | 44 | 29 | 0 | 109.8 |
| `Multiply` | `mj-spatial_kernels.adb:80` | [unproved_checks](logs/mj-spatial_kernels__multiply__adb_80.log) | 100 | 1 | 0 | 11.8 |
| `Joint_Motion` | `mj-spatial_kernels.adb:105` | [completed_no_unproved](logs/mj-spatial_kernels__joint_motion__adb_105.log) | 22 | 0 | 0 | 19.8 |

## Diagnostics

### mj-spatial_kernels__make_inertia__adb_31

- `mj-spatial_kernels.adb:39` (medium): precondition might fail, cannot prove A in -1.0e12 .. 1.0e12 [provers reached memory limit before completing the proof]
- `mj-spatial_kernels.adb:40` (medium): precondition might fail, cannot prove A in -1.0e12 .. 1.0e12 [provers reached memory limit before completing the proof]
- `mj-spatial_kernels.adb:40` (medium): precondition might fail, cannot prove R (0, 0) in -Limit .. Limit [provers reached memory limit before completing the proof]
- `mj-spatial_kernels.adb:40` (medium): in inlined expression function body at mj-smooth_math.ads:28
- `mj-spatial_kernels.adb:41` (medium): precondition might fail, cannot prove A in -1.0e12 .. 1.0e12 [provers reached memory limit before completing the proof]
- `mj-spatial_kernels.adb:41` (medium): precondition might fail, cannot prove R (0, 0) in -Limit .. Limit [provers reached memory limit before completing the proof]
- `mj-spatial_kernels.adb:41` (medium): in inlined expression function body at mj-smooth_math.ads:28
- `mj-spatial_kernels.adb:42` (medium): precondition might fail, cannot prove A in -1.0e12 .. 1.0e12 [provers reached memory limit before completing the proof]
- 21 more diagnostics in the individual log.

### mj-spatial_kernels__multiply__adb_80

- `mj-spatial_kernels.ads:77` (medium): postcondition might fail, cannot prove Multiply'Result = [Angular_Component (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False), Angular_Component (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True), Angular_Component (I (4), I (5), I (2), I (7... [provers reached memory limit before completing the proof]

