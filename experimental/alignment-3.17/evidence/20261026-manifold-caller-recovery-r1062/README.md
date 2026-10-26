# Manifold caller progress and interrupted initialization proofs

The C3.14 Copy_Manifold_Joints minimum closes97 semantic checks, repeating the
C3.17 closure in1035. Remap_Spans_For_Constructor closes8 and Model_Status21 on
the exact same private C3.14 source1030. Six inherited warnings remain. These
are minimum scopes under called contracts, not complete Data/Initialize proof.

Selected Initialize region1659..1680 in1034 now proves the manifold-call
precondition, its body-pointer dereference and subsequent call checks except
one Fluid_Phase.Initialize precondition, which reaches prover limits. Summary
separates proof checks from whole-unit flow information; counts are not additive.
A later split into nine explicit static precondition cuts1039 was interrupted;
partial Why3 reports are retained without a completion claim.

The direct-owned-element variant1023 passes reviewed whole Data FLOW and the
existing432 activation plus1152 integration scenarios per reference/profile.
Its full30 six-replica movement run finds roughly1.1-1.3% hinge slowdown; the
independent three-state repeat has wide intervals and is inconclusive. It stays
private. The range-only1040 variant still has two Arms initialization diagnostics
and is discarded before new build/numerical qualification.

Variant1049 uses Relaxed_Initialization, an explicit initialized-prefix invariant
and a whole-array initialization assertion instead of adding a runtime zeroing
pass. It passes reviewed FLOW under the same five spec-only deallocators and
unchanged warning multiset, plus all C3.14/C3.17 numeric controls. This does not
prove initialization: the invariant initialization/preservation, final assertion
and consuming-read checks still require completed proof reports on both references.
The original1052/1053/1058/1059 jobs and fluid-cut1048 have no final reports and
no live processes at recovery. They are interrupted, not successes or failures.
Their copied partial sessions and original runners remain. The cause of process
loss is not inferred. A fresh minimum retry1061 is outside this checkpoint.

The actual runtime remains893, published as e956729c3. No candidate in this
checkpoint is adopted or newly published. Restore manifold-caller-recovery.zip
with tools/evidence_store.py. Full port, coordinated migration, whole-dynamics
Gold and overall C parity remain unfinished.
