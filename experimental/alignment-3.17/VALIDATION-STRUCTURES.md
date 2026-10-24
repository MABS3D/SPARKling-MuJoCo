# Structural validation candidate: work in progress

This candidate adds the remaining C3.17 admission checks through a separate
`overlays/validation-structures.patch`, applied **after** `validation.patch`.
It is not enabled by the foundation builder or production project. Production
3.14 files and the live FLEX/performance units are unchanged.

The canonical new source files are in `src/`: `MJ.Model_Structures` contains
small CSR row/matrix, sorted-subset, ancestor-count, row-equivalence and diagonal
models/kernels; `MJ.Model_Admission` maps the checks to typed model diagnostics.
The patch installs those sources into an isolated foundation's `src/`, extends
its validity/diagnostic clauses and applies the two C3.17 mesh guards. Regenerate
only this patch with `python3 experimental/alignment-3.17/tests/make_structures_overlay.py`.
The source receipt records the required base overlay and helper hashes.

**Status at publication:** source preparation only. No compiler or SPARK proof
has run on these new units. Dedicated projects, executable tests, malformed-model
mutations and a separate FLEX-admission overlay remain to be written. Do not
interpret the contracts as closed Gold results or the patch as completed migration.
The previous packed Cholesky proof minima concern different units/snapshots.

Coverage implemented in source: flexedge/flexvert/efm0 CSR and efm0 DOF IDs;
B root row, parent subset and welded-ancestor count; D/B row equality and D
ancestor-relative diagonal offset; unconditional mesh face-normal checks and
texcoord checks when a coordinate address exists, including zero-count cases.
The CSR helper intentionally accepts C's per-row padding/gap domain; existing
compact M/B/D policy remains separately named in the base validator. Fixed-tendon
duplicate columns remain admissible: the private regression demonstrates the
unconditional C3.17 row-width cap rejects compiler-produced Nv1 duplicates.
No trust boundary, assumption, suppression, public precondition narrowing or
unverified production replacement is introduced by this candidate.

Next: revise and compile the kernels, prove the smallest scalar/row helpers
before callers, add the planned two CSR/B/D mutations and mesh-zero-count
cases, integrate an isolated FLEX-admission overlay, then verify whole admission
and both reference-version regressions. Preserve failed attempts and warnings.
