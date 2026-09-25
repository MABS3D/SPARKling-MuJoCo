# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-c09ai2r5/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Solve_Compatible` | `mj-data-inertia.adb:314` | [analysis_error](logs/mj-data-inertia__solve_compatible__adb_314.log) | 0 | 0 | 4 | 2.1 |

## Diagnostics

### mj-data-inertia__solve_compatible__adb_314

- `mj-data-inertia.adb:319` (error): prefix of attribute "OLD" that is potentially unevaluated must statically name an entity or be eligible for conditional evaluation (RM 6.1.1 (27))
- `mj-data-inertia.adb:319` (error): using pragma Unevaluated_Use_Of_Old (Allow) will make this legal
- `mj-data-inertia.adb:320` (error): prefix of attribute "OLD" that is potentially unevaluated must statically name an entity or be eligible for conditional evaluation (RM 6.1.1 (27))
- `mj-data-inertia.adb:320` (error): using pragma Unevaluated_Use_Of_Old (Allow) will make this legal

