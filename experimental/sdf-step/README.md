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
- Primitive/SDF, SDF/SDF, mesh/SDF and plane/SDF; no heightfield/flex producer.
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
with zero open flow checks. Whole-scene/step proof and release verification
remain separate from these validation receipts.

## Reproduce

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
