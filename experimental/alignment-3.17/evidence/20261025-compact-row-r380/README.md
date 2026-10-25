# Direct compact CRB row construction r380 — 25 October 2026

Local work only: no commits or pushes. The retained r349 solver is unchanged.
The new row constructors are not yet called by the stepping pipeline.

## C structure and exact contract

The inspected official C3.17 mj_crb computes the composite-body product once per
nonsimple DOF, projects it in descending ancestor order, adds armature only on the
diagonal, and uses the fixed inertia for simple DOFs. Assemble_Row now follows
that structure directly into an ancestor row. Simple rows have exact zero
prefixes and the fixed diagonal. The wrapper Assemble_Into_Row writes directly
into one shared compact slab and preserves every cell outside that row.

Contracts specify bounded accepted/partially rejected scratch, exact ordered
floating-point results on success, and a failing projected entry on rejection.
The simple branch avoids computing unused products. Existing input domains and
old projection helper interfaces are preserved; no suppressions, assumptions, skipped
bodies, trusted C implementation or unsafe FP are introduced. A caller must bind
the row pattern and composite/motion inputs to its physical model; these local
contracts do not establish that binding for the complete simulation.

The first minimum leaves one expanded Work_Array postcondition open. The
constructor body hides only that expression's expansion, reusing the already proved callee predicate; the same public contract
then closes all 37 checks (35 proof, 2 flow), with no warnings. The slab minimum
closes all 42 checks, including its complete untouched frame, also warning-free.
Each minimum runs alone before the complete-unit verification. Counts are scoped,
not additive or a complete dynamics proof.

Complete Compact_Inertia unit: obligations_closed=True, strict passed=False, checks=367 (341 proof, 26 flow), open entries=0, warnings=6.

The first complete unit attempt proves 282 checks and leaves two invariants
open in existing Project_Row and Expand. All diagnostic attempts are preserved.
Hiding row-index implementation details does not close the projection. Reusing
proved Store separates the bounded-domain predicate but still leaves the exact
processed tail open. Rewriting the invariant over actual buffer indices alone
also does not close it.

The final proof structure isolates pure quantifier composition. Join_Expanded_Rows
closes 15 checks and the Expand minimum closes 66. Join_Projected_Entries closes
29 checks; the final Project_Row minimum closes 70 checks. Full-unit results are recorded in
summary.json. Both lemmas are proved bodies, not assumptions. Explicit assertions
separate the unchanged region from the just-written row/entry before joining them.
Their calls and assertions are Static ghost code, so they add no runtime work.
The Project_Row attempt at r378 reaches the 240-second aggregate watchdog; its
repeat r379 permits 600 seconds total with the same three-second/650 MiB prover
limits and unchanged sources. The final complete unit permits 900 seconds total
for the larger collection of checks, with the same prover limits and 2500 MiB
group cap. These are recorded resource budgets, not weakened obligations.
The arithmetic, descending order and public contracts are unchanged. Store is an
Inline_Always assignment primitive. Existing diagnostics are recorded separately;
parentheses avoid a new reassociation diagnostic in the added wrapper.

## Independent numerical checks

The test calls C3.17 mj_forward then mj_crb. C supplies crb, cdof and an independent
full matrix obtained through mj_fullM. Tendon armature additions are deliberately
excluded from this CRB-only oracle; their integration remains separate work.
Every row of the selected scalar, multi-DOF, chain and branch fixtures is checked
at three states, including a 256-DOF chain. The same inputs test both a separate
row and the shared-slab wrapper, with explicit checks for untouched cells.

Analytic controls exercise large input bounds, failure on the diagonal and on
earlier ancestors after an accepted diagonal, fixed-inertia bypass, and array
origins near Natural'Last. Rejected scratch must stay within Work_Real. Test code
uses explicit checks in release as well as validation assertions. Source/binary
hashes, actual flags, raw cases, expected C values and outputs are retained.

Validation/release corpus: 1026 rows per profile; C-reference rows=1011; simple C
rows=42. Each profile compares 100236 values. The maximum observed absolute
difference from C is 0.0 in both profiles; this observation is not universal
bitwise equivalence.

The new constructor has no measured integrated performance benefit yet: it is
not on the timed path. The existing simulation still builds/publishes dense mass
and packs it for solving. Completing the change requires coordinated canonical
compact storage/cache publication, compatible/strict solve paths, tendon mass
couplings, inverse multiplication and raw/public readers. Dense expansion should
then remain at APIs that request it. Proofs of the caller/model binding and full
numerical/integrated movement gates remain required before adoption.

This is useful functional proof of the rounded algorithm, not exact physical
identities or complete port/current-release/performance alignment. The C reference
pin remains 800a109a4bdd02cb60404d565db4ae16fb04a53b (3.17.0).

## Artifacts

The ZIP retains the first/final full source closures, minimum/whole proof drivers
and reports, exact numerical driver and probe, all C cases and outputs, actual
build commands and binary hashes. Object/prover task caches, external toolchain
binaries and the external C library are excluded; their hashes/pins/flags remain.
All members are hashed and reread; all 82 prior inventory hashes are preserved.
No full step, composite accumulation, tendon, shared-reader or timing claim is
inherited from the row checks.
