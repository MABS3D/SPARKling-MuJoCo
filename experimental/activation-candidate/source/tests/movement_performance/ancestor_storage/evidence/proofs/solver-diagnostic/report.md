# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-py4pt3_u/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Load_Ancestor_Factor` | `mj-data-inertia.adb:434` | [unproved_checks](logs/mj-data-inertia__load_ancestor_factor__adb_434.log) | 20 | 4 | 0 | 31.3 |
| `Solve_Compatible` | `mj-data-inertia.adb:320` | [unproved_checks](logs/mj-data-inertia__solve_compatible__adb_320.log) | 111 | 49 | 0 | 91.8 |

## Diagnostics

### mj-data-inertia__load_ancestor_factor__adb_434

- `mj-data-inertia.adb:439` (medium): postcondition might fail, cannot prove Stable_Ready (D) [possible fix: loop at line 448 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:439` (medium): in inlined expression function body at mj-data.ads:605
- `mj-data-inertia.adb:453` (medium): precondition might fail, cannot prove Dense'Last = Size (P) * Size (P) - 1 [possible fix: loop at line 448 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:459` (medium): pointer dereference check might fail [provers reached time limit before completing the proof]

### mj-data-inertia__solve_compatible__adb_320

- `mj-data-inertia.adb:324` (medium): postcondition might fail, cannot prove Stable_Ready (D) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:324` (medium): in inlined expression function body at mj-data.ads:605
- `mj-data-inertia.adb:341` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:354` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:354` (medium): loop invariant might fail in first iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:356` (medium): precondition might fail, cannot prove Row < Size (P) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:357` (medium): precondition might fail [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:359` (medium): range check might fail [reason for check: input value must fit in parameter type] [provers reached time limit before completing the proof]
- 41 more diagnostics in the individual log.

