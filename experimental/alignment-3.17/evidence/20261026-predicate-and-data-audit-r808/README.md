# Private predicate experiment and parent-data proof audit

The adopted runtime is still row-window r789. The private predicate experiment
changes only Within_Work in mj-data.ads to abs(X)<=Work_Limit, retaining the
exact original interval-membership relation as a proved postcondition. Its three
minimum checks close, with eight diagnostics identical to the baseline. The
scalar accumulation minimum12, packed solver minimum86 and application minimum30
close; the complete external-load unit closes42 checks without warnings.
The initial whole external-unit attempt uses per-check3s and leaves one timeout;
the historical successful strategy was per-path10s. Both attempts are retained.

The full parent Data unit stops during flow analysis on three errors: two
uninitialized Arms reports and a renamed dereference dependent on mutable D
in Initialize. A fresh actual adopted-baseline run reproduces exactly those
three errors. This is unfinished proof engineering, not a mathematical Silver
exception, not complete parent-unit Gold and not a new predicate regression.

The private nine-scenario comparison uses six copies per role and normal native
C3.17 SIMD/LTO. All endpoints pass and no slowdown is confirmed. Branches24
has about1.4-1.8% lower median time with all three intervals below one; chain24
is about1.1-1.6% lower with only two intervals below one. All free-ball intervals
include no change. No adoption or aggregate/parity claim: an independent repeat,
all30 scenarios, boundary corpus and two-reference qualification remain pending.
Static acceleration comparison sites change48 to45, a diagnostic only.

A separate private prototype starts from the actual adopted baseline, initializes
armature scratch and validates a copied actuator record before committing it.
Rejecting branches keep the same Free and status behavior. It does not include
the abs predicate. The first Initialize minimum exceeds its2.5GB group memory
cap before producing a report and is not a proof. Topology and a larger-memory
initialization attempt are active when packaged and are explicitly excluded.
Neither prototype changes the adopted source or its previously proved scopes.

Frozen source, binaries, copied reports, failures and raw samples are preserved.
Restore predicate-data-audit.zip with tools/evidence_store.py restore using its
repository-relative path. Full port, whole dynamics Gold, coordinated migration
and overall C parity remain unfinished. No new commit or push is performed.
