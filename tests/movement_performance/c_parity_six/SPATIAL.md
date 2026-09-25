# Shared spatial preparation and scalar-joint RNE

The experimental simulator now follows the structure of MuJoCo 3.14.0
`mj_comPos`, `mj_comVel` and `mj_rne` in
`mujoco/src/engine/engine_core_smooth.c` (reference commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`). This concerns the supported scalar
hinge/slide pipeline; ball/free joints and the other unsupported engine
features are unchanged.

`MJ.Data.Spatial.Prepare` computes each root subtree COM from the current body
positions and the immutable subtree masses. It then prepares the body inertias
and joint motion axes in that common frame. The cache uses separate contiguous
real arrays, `10 * Nb` inertia entries and `6 * Nj` motion entries, matching the
cinert/cdof arrangement in C. CRB and RNE reuse these same arrays. Body and joint
pose records retain their previous size. Public dense mass storage and the
strict solver's dense factor storage are retained.

For each body, the scalar-joint velocity pass starts from its parent's spatial
velocity. Before adding the current DOF velocity, it computes the motion cross
product with that DOF's axis, as C does. The bias acceleration accumulates these
axis derivatives multiplied by qvel. The body bias wrench is then
`I * bias_acceleration + velocity cross_force (I * velocity)`. A backward body
pass accumulates wrenches, and projection onto the cached DOF axes produces the
generalized forces. Gravity remains a separate public positive physical force;
a specialized kernel forms its wrench from the cached mass and first moments,
omitting products with the zero angular acceleration.

The integrated fast path builds poses without also calculating the old
Cartesian velocity/bias representation. The public kinematics entry requests
that representation in its initial pose pass. When shared preparation or RNE
exceeds its checked fast-domain bounds, the existing Jacobian path remains
available. Its Cartesian motion is rebuilt into temporary storage and copied
back only after success; published geometry, shared inertias/axes and the mass
matrix are preserved. `Pose_Valid` alone does not certify Cartesian motion:
consumers require `Cartesian_Motion_Valid` or materialize it explicitly. Both
spatial validity flags are cleared when state changes or a step commits.

## Formal evidence

The completed arithmetic and storage unit proofs establish rounded floating
point component formulas, bounds, exact array layout and preservation outside
a written record. They do not establish exact real arithmetic identities or
universal bitwise equality with C.

| Scope | Result | Recorded artifact |
| --- | --- | --- |
| `MJ.Spatial_Dynamics`, entire final unit, including gravity specialization | 341 obligations, none open | `/var/tmp/sparkling-spatial-dynamics-unit1` |
| `MJ.Spatial_Storage`, entire unit | 94 obligations, none open | `/var/tmp/sparkling-spatial-storage-unit1` |
| Pipeline pose/cartesian storage preservation: builder array-shape post, early returns, copying-loop initialization/preservation, successful exits | 15 selected obligations, none open | `/var/tmp/sparkling-spatial-pipeline-frames13` |
| Ghost matrix bound-widening lemma | 3 obligations, none open | `/var/tmp/sparkling-spatial-widen-rotation2` |
| Minimal gravity helpers, before the complete unit check | All closed | `/var/tmp/sparkling-spatial-gravity1` |
| Minimal packing/loading helpers, before the complete unit check | All closed | `/var/tmp/sparkling-spatial-storage1` |

Whole-pipeline proof remains distinct from these completed kernel proofs.
The position builder, spatial cache construction, RNE caller contracts and
configuration/storage preservation checks have their own proof obligations.
At the time of this note, selected integration assertions still required proof
engineering; solver timeouts are not mathematical exceptions and are not
reported as Gold or as an accepted Silver-only limitation. The final local diagnostic leaves four `Storage_Ready` frame obligations in
`Spatial.Prepare` open (the nested joint loop initialization/preservation,
outer body-loop preservation, and successful exit), after the first three
preparation loops and outer-loop initialization close. The evidence is
`/var/tmp/sparkling-spatial-preparation-frames12` (11 emitted checks, four open).
A later expanded diagnostic split the array-layout clauses and did not close
them; those auxiliary diagnostics were removed, retaining the original stable
frame invariants and contract. It is not proof evidence of success.

`Fixed_Position` also remains pending: 21 emitted checks, one open
normalization-cut assertion (`/var/tmp/sparkling-spatial-fixed-position7`).
This final attempt retains only the parent position and rotation bounds in
the cut. Both that narrowing and the earlier stronger isolated retry in
`/var/tmp/sparkling-spatial-fixed-position-cut1` leave the cut assertion open.
The functional postcondition closes only under that still-unproved cut, so
this helper is not reported as Gold. These are unfinished proof-engineering
obligations, not mathematical exceptions. The root task's final proof
inventory records the complete integration result.

Earlier frame attempts produced no selected obligations because GNATprove had
skipped the unit following a flow error hidden from `--limit-line` console
output. These runs are not passes. The proof harness now also checks the
unfiltered `.spark` flow diagnostics. Final accepted proofs must have actual
emitted checks and no hidden fatal analysis errors.

## Behavioral checks

`check_spatial.py` builds a checked differential probe with the private test
unit `MJ.Data.Spatial_Checks`. Its 12-DOF serial-chain case verifies:

- ordinary RNE reuses prepared spatial data without materializing Cartesian
  motion;
- qvel of `1e8`, still within the accepted state type, triggers the RNE-only
  fallback after spatial preparation has succeeded;
- successful fallback preserves positions, orientations, inertial rotations,
  packed inertias/axes, mass, physical state and inputs;
- restoring the ordinary state invalidates both representations and returns
  the next force computation to the spatial fast path.

The current flat-storage probe passed the C differential driver on 23 models
and 6,548 comparisons with one sampled state per model, including the fallback
and retry assertions above. Evidence is in `/var/tmp/sparkling-spatial-probe2`
and `/var/tmp/sparkling-spatial-fallback2`, using the exact checked source
snapshot `/var/tmp/sparkling-spatial-build8`. The root task's larger final
numerical and benchmark sessions supersede this targeted check for aggregate
claims. Timing results must come from those sessions; kernel proofs and this
probe do not establish performance parity.
