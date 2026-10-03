# Owned flex state and Model/Data collision bridge

`MJ.Flex_State` copies flex topology, local vertex coordinates, vertex/body
associations, internal pairs, collision masks/layers, geometry and
contact materials from a real MuJoCo 3.14.0 `MJ.Models.Model`. The source model
may be freed immediately. `MJ.Data.Flex_Adapter.Update` supplies poses from
the existing owned Ada `MJ.Data.Simulation`; C supplies no body poses, contacts,
Jacobians or solved forces to the implementation.

This is an opt-in **state/geometry integration**, not a flex dynamics step.
The separate `MJ.Data.Constrained.Flex` entry now composes this state with
elasticity, contact response and Euler; see
`../flex-elasticity-integration/INTEGRATED-CONTACTS.md` for its source-specific
movement receipts. The following historical geometry receipts do not establish
that larger composition.
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
   Geom poses are composed from the same body poses. The compiled BVH topology
   is copied at creation and its bounds are refitted on updates, preserving the
   active leaves and traversal order used by C. Models without a BVH retain the
   linear collision path.
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
The mesh/heightfield extension also owns immutable asset arrays loaded at
creation and released by `Free`. It passes the separate integrated element5
movement corpus (234/234 in each profile); the older standalone geometry and
flow receipts below do not automatically extend to it.

The integration fixes two composition gaps without modifying the shared candidate:
self collision is gated by `contype & conaffinity`, as in C; distinct rigid flexes
still collide. The isolated candidate's both-rigid pair rejection is therefore
replaced with a dedicated cross-pair traversal using its existing element kernels.

## Supported domain and pending integration

- Explicit flex vertices (`flex_interp=0`), dimensions 1/2/3, and positive
  nodal interpolation orders 1/2. Centered/non-centered and pinned/body-attached
  vertices are supported; the new nodal corpus covers volumetric grids. Self modes
  none/narrow/BVH/SAP/auto, internal pairs and active tetrahedral layers.
- Rigid plane/sphere/capsule/ellipsoid/cylinder/box/mesh/heightfield versus flex,
  and flex/flex. Mesh graphs and heightfields retain compiled asset offsets.
  Contact dimensions 1/3/4/6 and material mixing are preserved as metadata.
- At most 16 flexes; each admits 4,096 vertices/elements/internal pairs;
  256 rigid geometries, 4,096 bodies and 4,096 collected contacts.
- Local inputs and published vertex coordinates are bounded by 1e10; the
  transform kernel bounds intermediate nodal positions by 5e10. A resulting
  vertex or AABB outside the declared domain is rejected before publication.
- Sampled SDF fields use the owned SDF scene. Triangle/SDF collision follows
  the C dimension-2 path; dimensions 1 and 3 emit no SDF contacts. See the
  SDF7 movement/admission receipts in the separate integrated flex candidate.
- Shell interpolation (negative order), plugin/mocap,
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

### Interpolated geometry recovery, 2026-10-03 (acceptance pending)

The current source admits positive interpolation orders 1 and 2. It owns nodal
body references and local/world positions, maps each vertex's compiled parametric
coordinate to its cell, and accumulates the C basis in node order. Negative shell
orders and interpolation orders above 2 are rejected. The constrained flex child
and elasticity integration have not yet enabled this interpolated domain.

The isolated interpolation kernel compares **228/228 bitwise** against the official
C cell lookup, basis array and interpolation functions in validation and release.
The fresh kernel9 whole proof closes **321 proof obligations and 34 flow
obligations**, with zero open and seven retained warnings. The contracts cover
cell lookup, ordered basis evaluation and the exact floating-point accumulation
model. Receipts are in `evidence/20261003-interpolation`. They do not establish
universal binary equivalence to C, an error bound against real arithmetic, or
the full state/collision caller proof.

The first geometry closure passed 360 admitted interpolated samples and 312
ordinary samples. Nine additional fixtures exceeded the core's 256-DOF capacity;
those failures remain recorded. Replacement fixtures have distinct names and pin
enough of their 125 nodes to admit 252 or 249 DOF. That corpus initially passed
393/432 samples: the 39 differences were in the selected 50-contact manifold,
with vertex error at most 1.12e-16. Importing the compiled active-element BVH
topology resolves all 39 differences on the exact saved input/oracle replay.
The state3 closure now passes **432/432 interpolated and 312/312 ordinary**
samples, plus **21/21 admission controls**, in validation and release. All 285
source hashes and all 54 interpolated output files match across profiles.
This is geometry evidence; earlier movement receipts do not automatically extend
to this new topology import.

`Interpolation_Order`, `Node_Count`, `Node_Body` and `Node_Position` expose the
owned nodal state for later integration. A rejected update leaves published node
and vertex positions unchanged and marks the state stale. The state3 corpus checks
these nodal APIs and rejected-update atomicity. Full state proof obligations
remain separate from the isolated kernel. The state3 flow closes 101 checks across both units, with zero open and 18
retained warnings. Its seven kernel dependency hashes match the complete kernel9
proof. Full caller runtime-safety and functional composition remain open.
No integrated interpolation dynamics or performance parity is claimed.

### Positive nodal contact endpoints, 2026-10-03

`MJ.Flex_Node_Weights` has its own 27-body endpoint, separate from the four
contact-vertex coefficients. It preserves the C first-weight sign, ordered
absolute-weight coordinate, basis cutoff below `1e-5`, first-occurrence body
order and duplicate accumulation. It does not renormalize the surviving basis.
Shell/TFI expansion is outside this positive-order API.

The weights5 immutable closure passes **1548/1548 bitwise C comparisons** in
validation and release, including more than four output bodies, duplicates,
world pins, zero, signs and cutoff boundaries. The private C function is
extracted unchanged from the pinned reference and its dependencies are hashed.
The fresh whole closes **116 proof and 18 flow obligations**, zero open, with one
retained warning. Exact component/frame contracts and a proved ghost fold model
specify the floating-point algorithm; no exact real partition-of-unity or
universal C binary-equivalence claim follows from those results. Receipts are
in `evidence/20261003-node-weights`.

`MJ.Flex_State.Nodal_Contacts.Weights` is the dedicated owned-state adapter.
It reads parametric vertices and nodal body references without retaining model
pointers. The nodal API explicitly refuses an ordinary flex and returns an empty
endpoint on errors. A higher-level mixed simulation must continue to process
ordinary flexes through their existing producer. This API does not admit nodal
elasticity or interpolated equalities, and does not by itself enable dynamics.
Its caller proof and integrated movement validation are separate checkpoints.

The endpoint3 closure passes **816/816 bitwise cases per profile** on 12 mixed
compiled models. Its complete child proof closes **49 proof and 9 flow
obligations**, zero open, with four retained warnings. The child contract covers
failure output and valid body references, under the called contracts; it does
not prove all FS state invariants or dynamics. Its nine runtime kernel dependency
hashes match the complete weights5 proof. The integration contract and compiled
zero-elasticity admission fields are documented in `NODAL-ENDPOINTS.md`.
