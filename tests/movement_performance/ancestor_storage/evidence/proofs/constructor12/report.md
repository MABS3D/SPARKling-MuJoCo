# Smooth dynamics: fragmented GNATprove results

Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.
A completed row is limited to the emitted obligations and their contracts;
it is not a proof of physical correctness or of the complete simulator.
An unproved check is not, by itself, a demonstrated runtime failure.
Timeouts and jobs not yet run must not be counted as passes.

Source snapshot: `/tmp/sparkling-smooth-fragments-63qkbtbz/source`

| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| `Build` | `mj-ancestor_rows.adb:146` | [analysis_error](logs/mj-ancestor_rows__build__adb_146.log) | 0 | 0 | 3 | 2.9 |

## Diagnostics

### mj-ancestor_rows__build__adb_146

- `mj-ancestor_rows.adb:157` (error): subtype constraint cannot depend on variable input "P" [E0007]
- `mj-ancestor_rows.adb:157` (error): use instead a constant initialized to the expression with variable input
- `mj-ancestor_rows.adb:157` (error): launch "gnatprove --explain=E0007" for more information

