# SDF contacts in the complete constrained step

`MJ.Data.Constrained.SDF` connects compiled mesh SDFs to the owned simulation
state, contact materials, constraint Jacobians/response, PGS/CG/Newton and Euler.
Use this child entry's `Create`, setters, `Evaluate`, `Step` and `Free`.
This is an explicit experimental entry; the ordinary engine retains its own
feature admission. Production Ada does not call the C collision engine.

The reference is MuJoCo 3.14.0, stable release checked on 2026-10-02. The dispatch
follows `engine_collision_driver.c` and `engine_collision_sdf.c`: primitive/SDF
and SDF/SDF use the sampled field search; mesh/SDF uses the compiled triangle
BVH and Frank-Wolfe search; plane/SDF uses plane/convex mesh contacts, as C does.
No contact, Jacobian or solved force is imported from the oracle.

## Ownership and initialization

The MJB loader now admits plugin-free SDF geometry type 8 only with a valid mesh
reference and a nonempty octree. The scene copies octree cells, coefficients,
vertices, material metadata and applicable triangle/BVH data. It validates the
immutable assets at creation. The source Model can then be freed.

During the exclusive `in out` initialization borrow, SDF geometry is temporarily
represented by bounding boxes for the free-dynamics subengine. Body mass/inertia,
poses and all mechanical parameters are retained; geometry type, data ID and
size are restored on every exit. These proxies never supply SDF contacts.
Fluid/SDF mixtures are rejected because their fluid geometry would otherwise
depend on the temporary representation. The probe checks model restoration.

The admitted field/query entry points use static validity preconditions rather
than repeated executable octree scans. Index/range/numeric checks and finite
query-result guards remain enabled, including the optimized profile. The old
standalone SDF API retains its checked admission and default generic behavior.
Private parent stages share assembly, solve and Euler publication; their
algorithms are not copied into this child.

## Explicit limits

- Plugin-free compiled octrees; external/native plugin ABI is not supported.
- Primitive/SDF, SDF/SDF, mesh/SDF and plane/SDF in the rigid child. The
  separate `MJ.Data.Constrained.Flex` child also uses this scene for SDF/flex
  contacts. Heightfield/SDF mixtures remain rejected.
- At most 256 geometries, 200,000 octants and 100,000 vertices; each mesh BVH
  accepts at most 4,096 faces / 8,191 nodes. The parent DOF/row/contact limits
  also apply. Capacity and numerical failures do not advance the state.
- Parent feature restrictions apply. Explicit pairs/exclusions, adhesion,
  NoSlip and SDF/fluid mixtures are currently rejected rather than omitted.
- No per-step heap allocation; owned assets are released by `Free`, including
  partial initialization. Engine storage remains caller-owned.

## Verification scope

The new proxy/index kernel has exact binary64 contracts. Diagnose the smallest
subprogram first, then the complete unit. The loader, scene, new child and SDF
search composition are not declared globally Gold or Silver; their proof work
remains engineering work. Static caller obligations are not assumptions or a
proof of the full simulation. No new trusted application body or `Assume` is
introduced. Differential agreement is sampled numerical evidence only.

The numerical harness compares physical acceleration, generalized forces and
complete trajectories. Contacts retain C's geometry-type order through frame
construction, including tangent orientation and pyramid-edge ordering. The
scene loads compiled mesh polygons for plane/SDF manifolds. Each native model
runs in a separate process and its input is saved before evaluation, so a
reference abort remains a recorded failure rather than a silent skip.

Recovery validation on the frozen `sparkling-recovery-sdf3-20261002` closure
passes all 44 comparable samples (22 models, two samples each) at both 30 and
100 steps, with unchanged tolerances. A twenty-third mesh/SDF model fails in
the native reference before Ada comparison. A pure C, zero-step tetrahedron
reproducer shows the reference returning more contacts than its allocated
pair budget; source, inputs, logs and hashes are under
`evidence/20261002-recovery/native-mesh-sdf`. The aggregate run correctly fails.
Scalar kernels have eight closed checks; scene flow has 27 and step flow 29,
with zero open flow checks. Whole-scene/step proof remains open.

The newer sdf5 closure uses central r62 sparse Newton and rigid endpoint
metadata. Validation and release each pass 44/44 comparable samples at 100
steps, with identical 337-file source maps, 297 shared r62 files and identical
numerical error records. This resolves the intervening sdf4/r7 box-trajectory
failure (43/44); that failed receipt and same-C-state replay are retained.
The native mesh/SDF abort remains a failure in both profiles, not a skip or
pass. Independent upstream review and a proposed fix are recorded under
`evidence/20261003-upstream-review`; the numerical reference is unmodified.
Fresh sdf5 kernel proof closes 8 checks, scene flow 27 and step flow 29, with
zero open checks (19 warnings retained for each flow scope). These do not close
the whole-scene/step runtime-safety and functional proof obligations.

## SDF with flex and local asset admission

The shared scene now exposes `Collide_Flex`; `MJ.Flex_State` owns the same
immutable field data used by rigid/SDF contacts. Field data is admitted once,
while per-query bounds and query-result checks remain. The flex child temporarily
uses box proxies only during core admission and restores geometry metadata on
all exits. Those proxies never generate SDF contacts.

Scene admission checks the geometry and assets it actually copies. It does not
require the unrelated core restriction `Nflex = 0`, nor validate unused rendering
normals, convex graphs or octree depth metadata. Selected mesh face and static BVH
ranges are checked before reads. Imported C mesh BVHs use `BVH.Traversable`
(topology and numeric box validity) plus leaf-to-face index validity: C can pad
degenerate leaf boxes beyond their parents. The original bounds are retained;
constructed/refitted trees still carry the stronger enclosure contract.

On frozen `sparkling-recovery-flex-sdf7-20261003`, validation and release each
pass 41 adversarial loader/lifecycle checks and 46 movement samples over 23
SDF/flex models at 100 steps. The ordinary flex corpus also passes 234/234 samples
at 100 steps in both profiles; all 340 source hashes and numerical error records
match between profiles. The corpus checks Jacobians, reference acceleration, regularization,
forces and state with the existing 2e-9 tolerance. It includes midphase enabled
and disabled, free/pinned flexes, moving SDFs, multiple solver/contact dimensions
and simultaneous rigid/SDF contacts. Disabled midphase preserves C's distinction
between a missing BVH and a compiled BVH whose dynamic bounds remain zero.

These are finite tests. Fresh flow closes 60 child, 92 state, 83 elasticity and
38 SDF scene checks, with 32/10/90/21 warnings retained respectively. Whole BVH
proof on the integrated closure closes 853 checks with eight retained warnings.
This establishes its current contracts; enumeration completeness and the exact
frame-cache formula are still missing Gold properties. The geometry loader and
whole scene/step proofs remain open.

## Reproduce

The `sparkling-recovery-sdf-geom-order2-20261003` closure renews the rigid SDF
entry on central r16 and orders ordinary rigid pairs by C geometry type before
material mixing and narrowphase. Validation and release each pass 76 comparable
samples at 100 steps, including 16 mixed rigid scenes with a distant inactive
SDF, asymmetric materials, reversed geometry IDs and PGS/Newton. All 350 source
hashes, numerical records and 38 complete outputs match between profiles.
The mixed-scene Jacobian, reference acceleration and regularization arrays are
exactly equal to C in this corpus. The native `mesh_sdf` worker still aborts in
both profiles; each aggregate command correctly returns failure.

The fresh `Contact_Type` minimum closes six checks. `Generate` reaches its
180-second watchdog without a complete report, so its proof remains open;
placeholder zero counters in the original runner are not proof evidence.
Source manifests, reference library/source hashes, per-profile artifacts and
proof logs are recorded in `evidence/20261003-geom-order/stage2-*`.
This does not renew the flex child or establish whole-scene Gold or performance.

Use the existing GNAT/GNATprove toolchain and Python MuJoCo 3.14.0 environment:

```sh
python3 experimental/sdf-step/tests/build.py --out /var/tmp/sdf-checked
/var/tmp/sparkling-movement-env/bin/python /var/tmp/sdf-checked/source/experimental/sdf-step/tests/compare.py --binary /var/tmp/sdf-checked/build/validation/bin/sdf_probe --out /var/tmp/sdf-numerics --samples 4 --steps 100
python3 experimental/sdf-step/tests/build.py --out /var/tmp/sdf-release --mode release
```

The build freezes and hashes the full source closure. Concurrent dependency
changes are recorded; tests describe that exact snapshot, not later edits.
`--resume --own-only` updates this entry while retaining frozen dependencies.
Proof and performance receipts must retain their own source/compiler scopes;
integrated C performance parity is not inferred from local SDF timings.
