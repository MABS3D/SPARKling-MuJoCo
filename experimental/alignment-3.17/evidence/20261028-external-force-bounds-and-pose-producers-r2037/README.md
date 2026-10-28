# External-force bounds and pose producers: private proof checkpoint

These private prototypes establish the local arithmetic needed to remove
redundant numerical checks from external-force projection. Production sources
still match the previously adopted r1855/r1890 math and dynamics receipts.
No new runtime change is adopted, no global scan is removed, and no new
integrated performance measurement is claimed.

Work_Rounding closes 34 checks on each reference. External_Force_Bounds closes
25 on each reference, proving column and wrench-contribution bounds while
preserving the exact floating-point evaluation order. The monotonic-addition
lemma is the existing reviewed SPARK Long_Float_Arithmetic boundary; this work
introduces no new trusted port body, assumption or suppression and does not
claim a new Coq replay. Matching math subtraction27 and Cross98 scopes close.

New unwired bounded leaves close Column_Bounded15 and
Accumulate_Bounded_Column14 on each reference, with exact output/frame
properties. An actual-leaf comparison passes 20,768 exact-input-bit cases in
each of four profile/reference builds, including signed zeros, subnormals,
extreme admitted geometry/wrenches and high nonzero array lower bounds.
These are unit composition tests, not a complete simulation comparison.

The private pose chain closes Pose_Frames53, Pose_Growth31, Fixed_Position15,
Fixed_Frame31, Finalize_Body_Frame14 and Apply_One_Joint45 on both references.
Build_One_Body closes all113 obligations on both references in the final r2038
source, including position/center growth, joint anchors and previous default
contracts. Its nine existing warnings remain visible. Pose_Bounds172 closes
on both references before the final Transfer_Cover4 addition; that addition is
proved separately. Do not interpret these scopes as a fresh whole176 report.
Pose_Rounding34 has fresh whole results on both references. Existing inherited
math warnings and the integer reassociation warning in Pose_Bounds are retained.
Separate scoped counts must not be summed into whole-program assurance.

The archive retains initial compile errors, unsupported-loop variants, watchdog
outcomes and the partial r2034 body report (105 closed/five open) that led to
the final successful repair. Source manifests and every archive member are
hashed before/after packaging. Cache exclusions retain relevant copied proof
receipts and standalone generated SMT diagnostics.

Remaining work includes propagation through the complete body tree, the
free/ball manifold paths, mocap and state lifecycle contracts, storage/cache
publication and all external-force caller preconditions. The bounded leaves
remain unwired until those obligations close. Full state/dynamics/factorization
Gold, complete feature coverage, coordinated latest ABI migration and parity
with native C remain open. This checkpoint is local; no extra commit or push.
Restore the exact ZIP with tools/evidence_store.py.
