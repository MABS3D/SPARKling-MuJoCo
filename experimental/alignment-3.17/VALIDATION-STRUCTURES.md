# Structural validation candidate: kernel checkpoint

The separate `overlays/validation-structures.patch` applies after
`validation.patch`. It is not enabled by the foundation builder or production
project. Production 3.14 files and the FLEX performance path remain unchanged.

`MJ.Model_Structures` now has a fresh complete-unit closure: 315 checks after
all 29 diagnostic minima, without open obligations or assumptions. Four
recursive-model warnings remain visible (`obligations_closed=true`, strict
`passed=false`). These are the same checks viewed minimally and as one unit,
not 630 distinct checks. Functional properties cover CSR admission/first bad
row, sorted subset search, row equality, ancestor counts and the mass-row
relation under their stated span/order/link preconditions. Scalar expression
scopes establish expression safety and termination.

Validation and release each pass 1230 isolated runtime cases: 1222 comparisons
with the unchanged `validateSparse` extracted from actual pinned C3.17, seven
owned-array shape cases, and one deliberate duplicate-tendon correction.
Unused storage, row gaps and shared spans retain the C helper domain.
The C3.17 unconditional width cap rejects a nonstrict width-two `[0,0]` row
with Nv1; the documented Ada correction keeps it admissible.

The first `Shape` proof found a real integer-width issue: checking Length
against Integer Last could first convert a length of 2**31 to Integer. The
renewed predicate compares Int64 values. All final minima, whole-unit proof
and runtime tests use the corrected byte-identical source files. No public
precondition was narrowed.

[Evidence, sources, tool versions and retained failures](evidence/20261024-structural-kernels-r150/README.md)
include the initial flow-only predicate driver rejection, failed Shape proof
and runtime project directory-creation failure. No timeout or missing model is
classified as a mathematical Silver exception.

`MJ.Model_Admission`, typed model diagnostics and the complete validator have
not yet been compiled/proved with this overlay. The generator's `compiled=false`
and `proved=false` describe that complete patch, not the isolated kernel unit.
The old source comments describing proof objectives predate these kernel
receipts; the evidence above specifies their verified scope.

Source coverage prepared for composition: flexedge/flexvert/efm0 CSR and efm0
DOF IDs; B root row, parent subset and welded-ancestor count; D/B row equality
and D ancestor-relative diagonal offset; unconditional mesh face-normal checks
and texcoord checks when a coordinate address exists, including zero counts.
Existing compact M/B/D policy remains separately named in the base validator.

Next: compile the isolated complete admission overlay; prove CSR_Error and
the Check_Flex/Check_Bodies/Check_Dofs minima before their callers; add actual
malformed-model B/D and mesh mutations; integrate FLEX admission; then renew
the full foundation gates and both historical version regressions. Kernel
closure alone does not establish complete validation or engine alignment.

Regenerate only this patch with
`python3 experimental/alignment-3.17/tests/make_structures_overlay.py`.
The source receipt records the required base overlay and exact helper hashes.
Use `tests/check_structures.py --subprogram NAME` and then `--whole` for proof
renewal. `tests/test_structures.py` runs the real C-helper comparison in both
profiles; each driver requires explicit foundation/output paths.
