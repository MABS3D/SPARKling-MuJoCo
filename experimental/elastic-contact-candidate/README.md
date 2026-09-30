# Elastic network self-contact and rigid-body coupling candidate

This is an isolated implementation for the existing `MJ.Elastic_Network` 1D
particle/edge model. It does **not** enable flex or contacts in the main `MJ.Data`
loader. Existing shared kernels and the main conversation's changes are untouched.

## Implemented behavior

- Edge/edge capsule self-collision, including interior crossings and the two
  contacts of parallel capsules. Shared vertices and vertices attached to the
  same body exclude a self-collision pair.
- Network contact with spheres, capsules and static planes. Rigid spheres and
  capsules can be offset from the center of mass. Their contact reactions include
  both translation and torque.
- Independent free rigid bodies with diagonal body-frame inertia, quaternion
  pose, body-frame angular velocity and gyroscopic torque. Fixed bodies receive
  reported reactions but keep their entire stored state.
- Vertices attached to body-local points. Spring/damper and external vertex
  forces transfer to the owning body with their moment arm. Attached vertices
  follow the body's position and velocity. Their particle mass and `Pinned` flag
  do not add inertia or override the attachment: the owner's mass and `Fixed`
  flag determine motion.
- One **coupled**, frictionless soft-contact solve. Rows share particle/body
  acceleration storage. Every PGS update changes the residual of other rows
  using that participant. Duplicate body terms within a row are merged before
  computing its effective inertia. This is not a series of independent contacts.
- Semi-implicit Euler advancement of particles and rigid bodies, with atomic
  rollback of particles, slide coordinates and bodies on numeric rejection, nonconvergence, invalid topology
  or contact capacity exhaustion. Contact-load outputs are zero on failure.

The caller supplies external particle forces, body wrenches in world coordinates,
gravity, contact settings and a contact workspace capacity. `Report.Count` is the
number of active rows after geometric selection. Its forces and contact-load
outputs describe the **start** of the accepted step. Angular velocity and inertia
are body-frame; reported torque is world-frame about the initial body COM.
For attached vertices their contact load is included in the owning body's output,
not counted a second time in `Particle_Contact`.

Independent particle positions use persistent Cartesian slide coordinates,
matching C's flex construction: `Position = Origin + Offset`. Initialize a
`MJ.Elastic_Coordinates.Frame_Array` with `Reset (P, Coordinates)` once, then pass
it to every `Step` alongside `P`. Keep it when saving/restoring a simulation.
Do not reconstruct the offset by subtracting the origin after each step: this
loses the rounding history that matters to contact selection. `Reset` also
explicitly rebases a manually repositioned network; otherwise inconsistent world
positions or mismatched array bounds are rejected with `Invalid_Input`.
Origins never change during `Step`; attached vertices follow their body and
their coordinate entries are preserved without being used for integration.

`Workspace_Capacity` gives a conservative raw-contact storage bound for a topology,
capped at 1024. Declare a constrained `Report` with that discriminant to avoid
initializing a maximum-sized contact workspace for every small model. The default
capacity is still available to callers. Capacity limits are explicit failures,
never silent contact truncation.

## C reference and deliberate scope

Reference: **MuJoCo 3.14.0**, release checked on 2026-09-30, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
The implementation follows:

- `engine_collision_flex.c`: `makeCapsule`, `mjc_ElemElem`, `mjc_GeomElem`,
  `mjc_PlaneFlex`;
- `engine_collision_primitive.c`: `mjraw_CapsuleCapsule` and sphere contacts;
- `engine_core_constraint.c`: `mj_elemBodyWeight`, normal-row impedance,
  reference acceleration and inverse-weight approximation;
- `engine_collision_driver.c`: `filterFlexContacts`, including its 3.14.0
  in-place swaps and tie breaking;
- `engine_solver.c`: the projected normal-force update.

Endpoint contact weights use **inverse distances from the contact point**, as C
does. The impedance regularizer uses the *linearly weighted* inverse mass,
whereas the actual row diagonal uses the merged, *squared* Jacobian coefficients.
Conflating those two quantities produces incorrect forces.
The regularizer accepts the sum for both contacting sides, including two masses
at the supported minimum of `1e-15`; a single-body inverse-mass bound would reject
that valid contact.

The contact selector retains at most 50 geometric contacts per self-contact
group and per shape/network group, before removing inactive rows. Degenerate
zero-length capsules have a defined point/sphere fallback; the corresponding
C capsule/capsule path divides by zero, so those tests are local robustness
tests rather than C equivalence claims.

This candidate supports positive `solref`, quadratic `solimp`, zero contact
margin/gap, `condim=1`, one 1D network, and independent free/fixed bodies. It does
not implement friction, restitution as a separate impulse law, CCD, triangle or
tetrahedron contacts, FEM, body articulation, rigid/rigid collisions, boxes,
meshes, heightfields, equality constraints, sleeping, warm starting, or the
discrete/implicit integrators. Stiff discrete steps may fail to converge or be
unstable, as for other explicit/soft-contact schemes; nonconvergence is reported.

The broad phase currently uses element AABBs with an all-pairs scan, not C's BVH
or sweep-and-prune. PGS uses deterministic row order and a projected fixed-point
residual criterion; C also has randomized order, momentum and different stopping
logic. Differential tests compare converged solutions with stated tolerances.
For large groups spanning multiple geoms of one body, C's BVH/group ordering can
also select a different subset of 50 contacts. That broader compatibility is
not claimed by the current per-shape grouping.

### Symmetric contact-selection regression

The former uniform 128-vertex plane divergence is corrected by the persistent
slide coordinates. Directly integrating world positions introduced tiny rounding
differences, which changed exact ties in C's 50-contact selector after a few
steps. The corrected case passes through 2000 Euler steps, with the same selected
vertices at every checked checkpoint and final maximum position difference
`2.776e-17`. No tie-breaking epsilon or relaxed tolerance was introduced.
`tests/selection_sensitivity.py` now fails on any such mismatch. Its optional
`--baseline-probe` records the old binary's divergence separately; historical
evidence is retained in `results/baseline/`. The regular differential suite also
includes a 1000-step uniform-plane case.

## Verification status

See `results/verification.json` and `results/README.md` for the recorded run.
The scalar/vector contact math has exact ordered floating-point contracts.
The coordinate integrator additionally proves its acceptance condition, exact
velocity/displacement/world-position updates and unchanged state on rejection.
`Reset` proves the origin and zero-offset relation for every vertex. These are
complete-unit gates after individual minimum-subprogram checks.
Whole-unit initialization and dependency analysis is separate from arithmetic
safety or Gold: a passing flow run must not be described as a Gold proof.

The complete contact pipeline is **not yet Gold**. Its missing arithmetic bounds,
loop invariants, geometry contracts, coupled-solver functional model and complete
step proof are open proof engineering, not documented mathematical exceptions
allowing a Silver-only completion claim. Numerical C comparisons do not discharge
these obligations. Square root/trigonometric accuracy and real-valued physical
error bounds are also separate from the ordered floating-point implementation.

## Reproduce

Run from this repository with the existing local GNAT toolchains. All build,
proof and test outputs go to the requested `/var/tmp` directory.

```sh
python3 experimental/elastic-contact-candidate/tests/build.py --out /var/tmp/elastic-contact-check
/var/tmp/sparkling-movement-env/bin/python experimental/elastic-contact-candidate/tests/compare.py --out /var/tmp/elastic-contact-check/tests --probe /var/tmp/elastic-contact-check/validation/bin/elastic_contact_probe
/var/tmp/sparkling-movement-env/bin/python experimental/elastic-contact-candidate/tests/rejections.py --out /var/tmp/elastic-contact-check/rejections --probe /var/tmp/elastic-contact-check/validation/bin/elastic_contact_probe
python3 experimental/elastic-contact-candidate/tests/prove.py --out /var/tmp/elastic-contact-proof
python3 experimental/elastic-contact-candidate/tests/prove.py --unit coordinates --out /var/tmp/elastic-coordinate-proof
python3 experimental/elastic-contact-candidate/tests/prove.py --pipeline --flow --out /var/tmp/elastic-contact-flow
python3 experimental/elastic-contact-candidate/tests/coordinate_api.py --out /var/tmp/elastic-coordinate-api
/var/tmp/sparkling-movement-env/bin/python experimental/elastic-contact-candidate/tests/selection_sensitivity.py --out /var/tmp/elastic-selection-check --probe /var/tmp/elastic-contact-check/validation/bin/elastic_contact_probe
/var/tmp/sparkling-movement-env/bin/python experimental/elastic-contact-candidate/tests/benchmark.py --out /var/tmp/elastic-contact-benchmark
```

Proofs start with individual minimum math subprograms and finish with a fresh
whole math unit gate. `prove.py --pipeline` requests the separate, currently
unfinished pipeline proof. No assumption, new trusted project body, suppressed
check or proof bypass is introduced.

The compiler warnings about contact-only flexes having no springs/equalities are
retained in the raw C logs. Runtime simulation warnings fail the comparisons.
The C oracle reprojects world-space loads at attached vertices before each step,
so torque follows a rotating attachment. A loaded 200-step trajectory covers it.
Timing cases use zero applied attachment loads and can use native bulk stepping
without a per-step application callback. The benchmark optionally accepts the
pre-fix release binary with `--baseline-probe`; it checks its common outputs too
and alternates baseline/current/C order. Benchmark results apply only to the explicitly supported standalone workloads;
they do not establish a speedup for the entire engine or main pipeline.
