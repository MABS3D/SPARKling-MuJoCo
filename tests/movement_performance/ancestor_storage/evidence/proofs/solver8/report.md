# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-a_fhuutn/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Load_Ancestor_Factor` | `mj-data-inertia.adb:436` | [unproved_checks](logs/mj-data-inertia__load_ancestor_factor__adb_436.log) | 17 | 5 | 0 | 28.2 |
| `Solve_Compatible` | `mj-data-inertia.adb:320` | [unproved_checks](logs/mj-data-inertia__solve_compatible__adb_320.log) | 112 | 50 | 0 | 93.7 |

## Diagnostics

### mj-data-inertia__load_ancestor_factor__adb_436

- `mj-data-inertia.adb:441` (medium): postcondition might fail, cannot prove Stable_Ready (D) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:441` (medium): in inlined expression function body at mj-data.ads:605
- `mj-data-inertia.adb:450` (medium): precondition might fail, cannot prove Dense'Last = Size (P) * Size (P) - 1 [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:456` (medium): array index check might fail [reason for check: value must be a valid index into the array] [possible fix: loop at line 452 should mention D in a loop invariant] [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:458` (medium): pointer dereference check might fail [possible fix: loop at line 452 should mention D in a loop invariant] [provers reached time limit before completing the proof]

### mj-data-inertia__solve_compatible__adb_320

- `mj-data-inertia.adb:324` (medium): postcondition might fail, cannot prove Stable_Ready (D) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:324` (medium): in inlined expression function body at mj-data.ads:605
- `mj-data-inertia.adb:341` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:354` (medium): loop invariant might fail in first iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:354` (medium): loop invariant might not be preserved by an arbitrary iteration [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:356` (medium): precondition might fail, cannot prove Row < Size (P) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:358` (medium): precondition might fail, cannot prove Row < Size (P) [provers reached time limit before completing the proof]
- `mj-data-inertia.adb:359` (medium): precondition might fail [provers reached time limit before completing the proof]
- 42 more diagnostics in the individual log.

