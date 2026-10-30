# Activation borrow removal and validation proofs

The actual constructor now configures its owned actuator element through an
in-place helper. The helper receives no Simulation and never frees it. Error
cleanup runs after its element borrow ends, with no whole-record copy. A
mechanical comparison confirms the original check/copy statements and order,
allowing only the explicit result/flag handoff and erased proof invariants.
The earlier borrow error is absent from fresh whole-unit flow analysis.

Fresh final-source scopes close on both pinned 3.17/3.14 closures:

| Scope | Checks per reference | Claim |
| --- | ---: | --- |
| Configure_Activation | 153 | Safety and successful output/frame relations |
| Prove_Actuator_Dynamics | 10 | Accepted actuator implies supported dynamics code |
| Prove_Model_Geom_Layout | 3 | Valid layout implies the geometry layout component |
| Model_Status | 13 | Complete current validator contracts under its callees |

Counts include reported informational flow checks; proof_checks is separately
recorded in each receipt. Existing reviewed floating-point warnings remain;
runner passed=false from those warnings does not mean obligations_closed=false.
No assumption, suppression or new trusted body is added. New proof contracts,
projections and invariants are Static and absent from fresh native objects.

The raw helper initially lacked the independent Nout index bound required by
actuator_lengthrange. Its added internal Static bound follows from the existing
constructor's Nout=Nactuator validation; supported public inputs are unchanged.
Moving the validator's original contracts to a forward declaration caused GNAT
Storage_Error failures on both references. A64MiB stack retry did not resolve
it. Body-local Static conditions with the original contract placement avoid
that failure. An incorrectly ordered Hide_Info variant is retained as failed.

The previous baseline itself leaves Dynamics_Inputs unproved in Model_Status.
A small proved geometry-layout projection supplies the missing Boolean fact,
closing both the original validator postcondition and added Static facts.
The supported-dynamics projection also closes independently. A selected call
inside Initialize closes8 checks under its intermediate facts; that diagnostic
is not the complete caller proof. The broader activation region hits its
240-second watchdog without a fresh report and remains unfinished.

Final candidate2528 passes432 cases per reference/profile:14 models,27 valid
model/mode combinations,16 samples,100 steps,unchanged2e-10 C tolerances.
The added muscle and mixed none/integrator/filter/filterexact/muscle fixtures
exercise parameter copies and activation addresses. All108 final output files
equal the earlier binary baseline byte-for-byte. Baseline and candidate binaries
for the expanded comparison are hash-checked against their build receipts.
Earlier400-case and intermediate Static-only variants retain their exact scope.

Actual whole-unit flow still has exactly two known Arms initialization messages.
The private relaxed-initialization prototype closes flow checks, but its complete
builder safety/functional proof is not established and is not adopted. The
mocap type invariant, complete Initialize/Reset/state proof, feature completion,
latest ABI migration and integrated C performance parity remain open. No new
timing claim, commit or push follows from this checkpoint.
