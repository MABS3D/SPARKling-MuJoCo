# Pose tree budgets and manifold leaves: private checkpoint

Build_Bodies closes all110 obligations on both reference closures. The scalar
body tree now carries absolute position/center/anchor bounds from the already
proved local Build_One_Body growth relation. Parent indices precede children;
the per-body budget is2*Max_Dofs+2, and every accumulated cap stays below1e22.
Store_Body_Pose closes32 checks on each reference, including explicit Static
preservation of each earlier body's geometric bound. Its runtime assignment is
unchanged. Bound_Anchor_Geometry34 also closes on each reference; its loop is
Ghost Static, so it adds no runtime scan. Public contracts/domains are unchanged.

The private scalar builder exposes mocap layout and typed-input bounds as new
Static preconditions. These are obligations for the caller/lifecycle proof,
not an assertion that the existing Is_Ready predicate already establishes them.
No extra runtime mocap scan is added. The complete manifold/free/ball traversal,
its group-layout/axis properties, mocap lifecycle, cache publication and actual
external-force caller obligations remain open. The scalar proof must not be
presented as closure of those paths or of full simulation dynamics.

Pose_Bounds closes a fresh complete203 checks on both references, including
Apply_Cover12, First_Cap5 and Start_Cover10. Pose_Rounding closes a fresh complete
48 on both references, including Subtract_Work4 and Subtract_Vector10. The
reviewed vendor floating-point arithmetic contract boundary is copied with
hashes/licenses; no new Coq replay or trusted port body is claimed.
Pose_Frames closes complete67 on both references after Relocate_Position14.
The later Free_Position addition closes13 on each reference and is used by the
private manifold branch; there is no fresh whole80 claim. All exact floating
point relations and original failure paths of the addressed scopes remain
explicit. Existing9/14/Sqrt warnings and the Pose_Bounds integer reassociation
warning stay visible; counts describe separate scopes and are not added up.

The final private2090 source passes existing activation432 and integration1152
scenarios in every one of the four reference/profile builds. Models, inputs,
forces and tolerances are unchanged. The exact unchanged adopted1860 baseline
receipts are reused only after complete source/provider hashes match; every
new candidate binary is freshly built/tested. All30 integrated100-step movement
endpoints equal actual adopted1860 Ada exactly and satisfy the existing pinned
native C3.17 oracle at unchanged2e-10 tolerances. Internal elapsed outputs are
ignored because these were numerical checks with other proof work active.

An initial anchor lemma omitted a span bound and leaves two overflow obligations;
the corrected34-check scope closes. Initial scalar-tree attempts retain their
actual121/109 closed checks and remaining obligations. The final storage frame
contract closes the missing prefix-preservation obligation. These failures and
all source-bound receipts are preserved, rather than relabeled as successes.
The movement build's inherited snapshot labels are corrected in build.json,
with its initial metadata digest retained, before endpoint diagnosis. Binary,
commands, actual source and C reference remain unchanged by that metadata fix.

Read-only pinned C excerpts record the free qpos copy, mocap composition,
ball/hinge anchor correction and external-wrench zero shortcuts. C intermediate
quaternion-vector rotation and the current Ada matrix/intermediate-normalization
path differ; the audit is not a universal bit-equivalence claim. Original C
license and reviewed SPARK vendor boundary provenance are retained.

No newly prototyped body/force path is adopted into production. Production math
and dynamics still match r1855/r1890; bounded external-force leaves remain
unwired. Whole state/dynamics/factorization Gold, full features, coordinated
latest ABI migration and C parity remain open. Work is local, with no further
commit or push. Restore the exact ZIP with tools/evidence_store.py.
