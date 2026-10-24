# Integer structural kernels, 24 October 2026

On immutable 3.17 types, all 29 Model_Structures minima close 315 checks. The
fresh complete-unit proof independently closes the same 315 checks with every
function selected, no skipped checks or assumptions. Four recursive-model
warnings remain explicit (`obligations_closed=true`, strict `passed=false`).
Do not add the minimum and whole-unit counts together.

The functional scope includes CSR admission and the first bad row, sorted
subset search, row equality, bounded welded-body/DOF ancestor counts, and the
mass-row/ancestor relation. Preconditions specify valid spans, sorted rows or
acyclic links as appropriate. Scalar predicate scopes establish their expression
safety and termination; flow-only predicates are not presented as new functional
postconditions. Model_Admission and complete model/engine validity remain open.

The initial Shape predicate could convert an array length of 2**31 to Integer
before comparing it with Integer Last. The renewed expression compares Int64
values. No public precondition was narrowed. The boundary is covered by the
universal proof; the runtime suite does not allocate such a large array.

Runtime validation and release each pass 1230 deterministic cases: 1222 compare
against the exact unchanged validateSparse function extracted from pinned C
3.17 engine_io.c; seven exercise owned-array shape guards absent from C's raw
pointer interface; one checks the deliberate duplicate-tendon correction. That
case accepts a nonstrict width-two row [0,0] with nv=1, which the new C row-width
cap rejects. The actual helper, C headers, binary hashes, inputs, expectations
and command logs are retained. This is an isolated helper comparison, not
execution of the full C validator or a simulation.

The archive preserves every fresh scope/source receipt and the failed driver,
Shape and directory-creation attempts. Driver revisions are retained separately.
Prover caches and build objects are excluded; all runtime probe binaries are
included. Both measured source units are byte-identical across the final minima,
whole-unit proof, runtime tests and current candidate. The regenerated overlay
contains the correction but has not yet been admitted into the full foundation.

Reproduce with check_structures.py against an extracted verified foundation r5,
first --subprogram and then --whole. Run test_structures.py using the official
pinned source checkout and a Python environment containing MuJoCo3.17.0. These
drivers freeze sources, use j1 and bounded watchdogs, and reject incomplete
reports or changed inputs. Extracted receipt paths are the actual run paths;
adapt them to the reproduction location. Exact tool versions and hashes are
listed in the accompanying receipts.
