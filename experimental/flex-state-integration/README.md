# Owned flex state and Model/Data collision bridge

`MJ.Flex_State` copies flex topology, local vertex coordinates, vertex/body
associations, internal pairs, collision masks/layers, primitive geometry and
contact materials from a real MuJoCo 3.14.0 `MJ.Models.Model`. The source model
may be freed immediately. `MJ.Data.Flex_Adapter.Update` supplies poses from
the existing owned Ada `MJ.Data.Simulation`; C supplies no body poses, contacts,
Jacobians or solved forces to the implementation.

This is an opt-in **state/geometry integration**, not a flex dynamics step.
The ordinary model validator and `MJ.Data.Create` still reject flex. Until that
admission and the mechanical phases are composed, `Simulation` must be created
from a compatible rigid kinematic view with the same body/joint ordering and
configuration. The differential probe compiles that view by removing only the
explicit `<deformable>` topology from the same XML, keeping every body, joint,
inertial parameter and rigid geom. It does not convert deformable vertices into
independent collision spheres. The full flex model uses `MJB.Parse_Raw` followed
by this adapter's explicit layout, index and bounded-domain admission, rather
than claiming that the current global model validator accepts it.

## Behavior

1. Create owned metadata using `Flex_State.Create`; duplicate creation is rejected.
2. Update `Data.Kinematics`, then call `Data.Flex_Adapter.Update`. Vertex positions
   follow C's centered/zero-offset branch or ordered binary64 `xpos + xmat*local`.
   Geom poses are composed from the same body poses. Trees are built once and
   refitted on subsequent updates, rather than rebuilt every frame.
3. `Flex_State.Detect` collects geom/flex, self/internal and cross-flex contacts,
   including element/vertex provenance, mixed material coefficients and separate
   include/detection margins. Collision masks and disabled contact/midphase flags
   are respected. The existing C-style farthest-point filter limits each group
   to 50 contacts. Contacts are compared as one-to-one multisets; this adapter
   does not reproduce the final global C contact sort.
4. Rejected updates preserve all published vertices and invalidate cache currency.
   Detection rejects stale caches. A rejected collection publishes length zero;
   suffix storage is not part of the result. Logical release is idempotent.

`State` contains reusable fixed buffers and does not allocate during update or
detection. It is large and should be allocated once on the heap by its caller.
`Free` invalidates the caller-owned object; it does not deallocate that object.

The integration fixes two composition gaps without modifying the shared candidate:
self collision is gated by `contype & conaffinity`, as in C; distinct rigid flexes
still collide. The isolated candidate's both-rigid pair rejection is therefore
replaced with a dedicated cross-pair traversal using its existing element kernels.

## Supported domain and pending integration

- Explicit, non-interpolated flex vertices (`flex_interp=0`), dimensions 1/2/3,
  centered/non-centered and pinned/body-attached vertices; self modes
  none/narrow/BVH/SAP/auto, internal pairs and active tetrahedral layers.
- Rigid plane/sphere/capsule/ellipsoid/cylinder/box versus flex, and flex/flex.
  Contact dimensions 1/3/4/6 and material mixing are preserved as metadata.
- At most 16 flexes; each admits 4,096 vertices/elements/internal pairs;
  256 rigid geometries, 4,096 bodies and 4,096 collected contacts.
- Finite local/world coordinates bounded by 1e10. An affine transform or AABB
  outside the declared domain is rejected before publishing new positions.
- Interpolated nodal/shell flexes, mesh/heightfield/SDF geometry, plugin/mocap,
  explicit pair/exclusion tables, option overrides and adhesion are rejected.
  Their separate candidates are not silently enabled by this adapter.
- Elastic/bending forces, edge equalities, flex interpolation Jacobians, contact
  Jacobian weighting, constraints/solver and Euler coupling are **not implemented
  here**. Adding this bridge does not make the full simulator flex-capable.

## Evidence and reproduction

The reference is official MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; the latest release API was checked on
2026-10-02. See `evidence/2026-10-02/` for the final source-linked receipts.
Numerical tests and formal proofs are distinct. The transformation kernels have
functional contracts for exact floating evaluation order, both copy branches
and matrix composition. Whole adapter/collision composition and its caller
preconditions remain proof engineering work, with no Silver exception, added
assumption, skipped body or new trusted application body. No C performance-parity
claim is made; this geometry bridge cannot substitute for a complete movement test.

All build profiles keep runtime checks; release uses O3/native with FP contraction
disabled. Freeze the full dependency closure outside the shared checkout:

```sh
python3 experimental/flex-state-integration/tests/build.py --out /var/tmp/flex-state-checked
/var/tmp/sparkling-movement-env/bin/python experimental/flex-state-integration/tests/compare.py --binary /var/tmp/flex-state-checked/build/validation/bin/flex_state_probe --out /var/tmp/flex-state-comparison --samples 8
/var/tmp/sparkling-movement-env/bin/python experimental/flex-state-integration/tests/policy.py --binary /var/tmp/flex-state-checked/build/validation/bin/flex_state_probe --fixtures /var/tmp/flex-state-comparison --out /var/tmp/flex-state-policy
python3 experimental/flex-state-integration/tests/build.py --out /var/tmp/flex-state-checked --resume --mode release
python3 experimental/flex-state-integration/tests/prove.py --out /var/tmp/flex-state-proof
```

Repeat comparison/policy checks with the release executable. `--resume` preserves
frozen shared dependencies and refreshes only this adapter's files; it is for
building another profile or local development, not evidence that shared sources
remain unchanged. Run minimal proof scopes first; `--only Point` (or another
helper/whole/flow scope) isolates diagnostics. Flow does not establish safety
or functional correctness. Preserve source manifests when evaluating results.

### Recovery receipt, 2026-10-02

`evidence/20261002-recovery/` records a fresh validation closure: **312/312**
geometry/contact samples and **8/8** policy cases. The four transformation
helpers followed by the complete kernel unit close **59 proof checks**, zero
open. Compose spells out the nine fixed entries and their identical input
bounds/component relations; no arithmetic order or admitted domain changed.
The complete state/adapter flow closes **66 checks**, zero open, with 15
warnings retained. Material mixing is evaluated before Append to remove an
alias between the input material and the state being updated.

These receipts establish kernel functional properties and adapter flow, not
full adapter runtime safety, functional composition, flex contact response or
performance parity. The kernel runner accepts `--build` to reuse and verify a
frozen closure, and returns failure for open or timed-out selected scopes.
