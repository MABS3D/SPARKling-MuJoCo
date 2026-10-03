# Ray casting integrated with Model/Data

Native Ada/SPARK ray queries, following MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, `src/engine/engine_ray.c`.
The official latest-stable release was checked on 2026-10-02 and remains 3.14.0.
The C library is used only by differential tests and the benchmark oracle.

`MJ.Rays.Initialize` copies geometry, rendering/filter metadata, compiled mesh
vertices/faces/BVH and heightfield elevations into caller-owned storage.
`MJ.Data.Rays.Synchronize` obtains current body poses from the actual smooth
simulation and composes geometry-local positions and rotations. No pose, contact
or ray result from C enters the Ada implementation. The source model may be
freed after scene and simulation creation, as the probes do.

The project is opt-in (`rays.gpr`) so this side task does not edit the shared
smooth/constrained project files or their proof gates. It is a query integration,
not a separate physics implementation. Existing physics sources are dependencies.

## Implemented behavior

- Single-ray intersections with plane, sphere, capsule, ellipsoid, cylinder,
  box, compiled triangle mesh and heightfield. Distance is the nonnegative ray
  parameter, **not** Euclidean distance when the direction is not unit length.
- Global-frame normals, including exits from an interior origin, cap/side
  selection, one-sided finite rendered planes, triangle winding and terrain
  side/base intersections. Collision masks do not suppress rendered ray targets.
- C's body exclusion, weld-based static exclusion, invisible material/geometry
  filtering and six geometry groups. An assigned material's alpha takes precedence
  over geometry alpha. Strict comparison retains the first geometry on a tie.
- Mesh traversal uses the compiled C BVH, child order and triangle face indices;
  no exhaustive replacement of the BVH. Parallel slab axes are handled explicitly
  without relying on infinities. Terrain traversal bounds the padded cell range
  by the segment through the top box and also checks its viable sides/base.
- Scene body-to-geometry links are cached at creation. Pose refresh is linear in
  bodies/geometries; queries allocate no heap storage. Synchronization validates
  all body positions before publishing geometry poses.
- `Cast_Many` accepts arbitrary array origins, initializes all outputs and uses
  C's squared-norm gate for empty/very short directions. Unsupported numerical
  inputs fail atomically. This batch API repeats scene queries; C's angular
  aperture preparation and per-geometry cutoff culling are not yet ported.

Example sequence (scene storage should be allocated once, e.g. on the heap):

```ada
MJ.Rays.Initialize (Model, Scene, Ray_Status);
MJ.Data.Create (Model, Simulation, Data_Status);
MJ.Models.Free (Model);
MJ.Data.Kinematics.Update (Simulation, Data_Status);
MJ.Data.Rays.Synchronize (Simulation, Scene, Data_Status);
MJ.Rays.Cast (Scene, Origin, Direction, Hit, Ray_Status);
```

The simulation and scene must originate from the same model, as C's model/data
pair must. Check every returned status. `Ready` means model data were copied;
`Poses_Ready` also requires poses for all bodies. `Synchronize` rejects stale
simulation poses. A scene is an explicit pose snapshot: synchronize again after
changing position or stepping. Queries do not advance time or change inputs.

## Domains and remaining scope

Storage: 4,096 bodies/geometries, 1,024 mesh/terrain assets, 65,536 mesh vertices
and faces, 131,072 static BVH nodes, 262,144 height samples and C's 50-slot mesh
traversal stack. Exceeding a capacity rejects initialization. Assets are copied
after the existing full Model validity boundary.

Point/direction components and input body/local positions are bounded by 1e10;
directions below C's `mjMINVAL` norm are rejected for single queries. Ellipsoid
radii and heightfield dimensions are at least 1e-10. Computed roots above 1e100
are rejected with a numerical status rather than published. Model rotations
and manually supplied body rotations must be proper rotation matrices.
The `Cutoff` option limits the returned ray parameter; it is not C multiRay's
bounding-sphere/center cutoff semantics.

Plugin SDF ray marching, deformable flex/skin picking, rendering `bvh_active`
markers and C's multi-ray angular acceleration remain outside this entry.
The current Model/Data engine does not own deformable/plugin state, so these
are explicit remaining integrations, not silently ignored geometry kinds.
SDF geometries reject initialization.

## Verification

See `evidence/recovery-20261002` for source-linked receipts. Fresh recovery validation passed 1,440 primitive and 6,480 scene-ray comparisons against C 3.14.0. The complete kernel has 72 proved checks and zero open checks; lifecycle, stale-pose, invalid-input and atomic batch tests passed. These receipts concern the frozen dependency closure in the source manifest. Proof diagnosis starts
with each minimal kernel and then the complete kernel unit. Exact binary64
products, ordered dot/rotation/map components, ray-point updates, nearest-hit
selection and all filter branches have functional contracts. No assumptions,
skipped proof bodies, suppression or new trusted application implementation are
used. Runtime checks remain enabled in both build profiles.

Complete ray geometry, loader/BVH/terrain traversal and Model/Data composition
proofs remain engineering work. Passing C comparisons and kernel contracts do
not establish Gold or even full runtime-safety proof for that entire composition.
Runtime square root is the existing standard Ada runtime boundary; there is no
new real-arithmetic accuracy theorem. No Silver completion exception is claimed.

The benchmark measures equivalent cached-pose **scene ray queries**, including
filters, broad phase, intersections, normal calculation and nearest-hit selection.
Model loading, pose refresh, I/O and movement are outside timing in both languages.
It cannot establish full-movement performance parity or multiRay throughput.

Reproduction, using the project's existing GNAT toolchain and MuJoCo environment:

```sh
python3 experimental/ray-casting/tests/check.py --out /var/tmp/rays-repro --action build
python3 experimental/ray-casting/tests/check.py --out /var/tmp/rays-repro --resume --mode release --action build
/var/tmp/sparkling-movement-env/bin/python experimental/ray-casting/tests/differential.py --binary /var/tmp/rays-repro/build/validation/bin/ray_probe --out /var/tmp/rays-checked-comparison
/var/tmp/sparkling-movement-env/bin/python experimental/ray-casting/tests/differential.py --binary /var/tmp/rays-repro/build/release/bin/ray_probe --out /var/tmp/rays-release-comparison
python3 experimental/ray-casting/tests/check.py --out /var/tmp/rays-small --action small
python3 experimental/ray-casting/tests/check.py --out /var/tmp/rays-small --resume --action whole
/var/tmp/sparkling-movement-env/bin/python experimental/ray-casting/tests/benchmark.py --binary /var/tmp/rays-repro/build/release/bin/ray_bench --out /var/tmp/rays-timings
```

Each fresh build freezes the complete dependency closure outside the repository.
`--resume` preserves it; `--refresh` additionally refreshes only this task's ray
sources/tests/project. Evidence applies to the frozen hashes, not later changes
in concurrently developed physics units.
