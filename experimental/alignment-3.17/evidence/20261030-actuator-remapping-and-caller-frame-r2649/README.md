# Actuator remapping and constructor-frame diagnosis

The actual Remap_Actuators now receives the actuator array and dimension values,
not the entire Simulation. The constructor retains direct ownership of its body,
joint and other state fields across that call. A single-element helper preserves
the original ID/address/gear checks and five field updates, and the array helper
preserves the actuator order. Mechanical comparison covers those statements.
Validated immutable transmission metadata is loaded as an argument even on body
or rejected branches; the layout/index proofs make that extra read defined and
side-effect free. The array uses the owned Config range, equal to the original
D.Na after construction. Dead initial Ok:=False is removed from its coordinator;
element calls establish every error result and empty/success cases set True.
No additional record copy, runtime validation pass, assumption or trusted body
is introduced.

| Final scope | Reported checks per reference | Property |
| --- | ---: | --- |
| Remap_Input_Valid | 9 | Well-defined acceptance predicate |
| Remapped_Parameter | 14 | Well-defined exact record model |
| Remap_One_Actuator | 35 | Exact success/rejection, mapped fields and frame |
| Remap_Parameter_Array | 77 | Ordered composition, complete successful array and body-flag preservation |
| Prove_Joint_Kinds | 14 | Already validated joint types lie in0..3 |
| Model_Status | 14 | Original validator postcondition plus validated joint/actuator facts |
| Remap_Actuators | 37 | Complete model-to-array adapter contracts and safety |

All scopes close on both pinned3.17/3.14 closures under their explicit inputs
and callee contracts. Counts include informational flow checks; proof_checks and
existing reviewed warnings are separately recorded. Warnings make runner
passed=false while obligations_closed=true; successful closure checks the full
fresh report, representation, coverage and absence of open/skipped/assumed VCs.
This is not whole simulation safety or functional correctness.

The first attempt exposed an implicit Integer conversion of unconstrained array
Length and missing validated gear-prefix information. Int64 shape arithmetic
and proved prefix/rejection assertions close the single-element scope. The
initial array has52 checks closed with one invariant open. Subsequent240-second
attempts time out. The final Boolean-only acceptance predicate states its actual
dependency, separate prefix facts and model abstraction support composition,
and600-second guarded budgets allow complete reports: the final array takes
about273-287 seconds and adapters about379-490 seconds. No proof is claimed
from a watchdog or merely from a longer observation wait. A preparation-count
assertion failure and a corrected audit-loop parser are retained explicitly.

The already performed joint validation now has a proved Static projection and
validator postcondition; no new public input restriction or runtime joint scan
is added. Both whole MJ.Data flow checks have no open messages and zero proof
VCs; these are flow-only results. The selected Build_Manifold_Topology call in
Initialize closes7 checks with one precondition open: Body_Config nonnull cannot
yet be established. This locates remaining caller-frame work; it does not prove
the full constructor. Copy_Manifold_Joints currently requires a nonnull body
configuration but does not state its preservation in the postcondition. Its
frame and the activation loop's continuation invariants need their own proofs.

The suite adds parent-frame ball transmission and body transmission models,
giving17 fixtures and33 valid model/mode pairs. The body case has no active
contact and checks remapping/zero-moment behavior, not body-contact coupling.
Final candidate2622 passes528 cases per reference/profile,16 samples,100 steps,
unchanged2e-10 C tolerances. Unchanged2574 baseline binaries also pass this
expanded suite; all132 final output files equal those baselines byte-for-byte.
Fresh native objects emit none of the listed Ghost model/projection functions.

The remapping change is adopted locally. Complete Initialize/Create_Dynamics,
Reset and state/dynamics Gold, private mocap-invariant integration, full feature
and ABI alignment, and integrated C performance parity remain open. Existing
warnings/deallocators are retained. No timing, complete-port, commit or push
claim follows from this checkpoint.
