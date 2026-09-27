# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-tpv6t3d1/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Copy_Matrix` | `mj-ancestor_rows.adb:2` | [unproved_checks](logs/mj-ancestor_rows__copy_matrix__adb_2.log) | 62 | 1 | 0 | 30.8 |

## Diagnostics

### mj-ancestor_rows__copy_matrix__adb_2

- `mj-ancestor_rows.adb:13` (medium): loop invariant might not be preserved by an arbitrary iteration, cannot prove Target (A) = Dense (MJ.Smooth_Kernels.Matrix_Offset (P.N, J, P.Columns (A))) [provers reached time limit before completing the proof]

