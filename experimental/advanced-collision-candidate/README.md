# BVH, SDF and flex collision candidate

Native Ada/SPARK geometry candidate translated against MuJoCo **3.14.0**,
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. It is isolated from
the main thread's collision, constraint and dynamics work. Production Ada
does not link to C; C is used only as the differential-test oracle.

The numerical and timing figures below describe the initial standalone
2026-10-02 snapshot. Subsequent integrated recovery has its own source closures
and evidence: see [BVH_PROOF.md](BVH_PROOF.md#recovery-exact-frame-cache-2026-10-03)
for the exact frame-cache contracts, and
[the collision recovery journal](../../plans/2026-10-02-recovery-collision.md)
for scene, SDF and flex integration. The fresh BVH complete-unit renewal closes
969 proof/flow checks with no open obligations and eight retained warnings.
The exact cache relation is proved; universal pair enumeration remains outside
the current contract. Both profiles pass 2,429/2,429 comparisons and 3,969
containment checks on those same 350 sources, with identical output records.

## Implemented scope

| Area | Implementation |
| --- | --- |
| BVH | Deterministic median construction in preorder, imported-tree validation, dynamic refit, AABB and cached oriented-box tests, pair and self traversal. |
| SDF queries | Plane, sphere, capsule, ellipsoid, cylinder and box; sampled octrees, projection, ordered interpolation and gradients; native Ada custom providers. |
| SDF collision | Relative poses following C's quaternion path, Halton starts, Wolfe gradient descent, Frank–Wolfe triangle search, contact deduplication, geom/SDF, mesh/SDF and flex/SDF. |
| Flex narrow phase | Segments, triangles and tetrahedra; all dimension pairs; rigid primitives, convex meshes, heightfields, planes and SDF; specialized sphere/box/capsule triangle kernels and corrected normals. |
| Flex driver | Mask and shared-body filtering, active layers, internal element/vertex and tetrahedral-face contacts, narrow/BVH/SAP/auto self collision, cross-flex collision and C's farthest-point filtering. |

`MJ.Flex_Driver` and `MJ.SDF_Collisions` are generic over an Ada query provider.
`MJ.Builtin_Flex` and `MJ.Builtin_SDF` instantiate them for analytic/sampled
fields and explicitly reject unavailable custom fields. Keys, failure propagation
and non-finite provider results are exercised by `Advanced_Checks`.

The new `Flex_Element` support kind examines every element vertex. It deliberately
does not reuse the terrain-prism support callback, whose half-space optimization
is inappropriate for tetrahedra. Only three files in the local dependency copy
are extended: `mj-contact_geometry.ads`, `mj-convex_contacts.adb` and
`mj-advanced_contacts.adb`. `vendor-hashes.json` records the **initial** dependency
snapshot; the validation manifests record the final extended files.

## Validation and assurance

The checked and optimized builds each pass **2,425/2,425** deterministic
comparisons against native MuJoCo 3.14.0, plus explicit boundary/policy checks.
The comparisons include positions, normals, distances, contact counts and
provenance. Unordered groups are matched as multisets, one-to-one. BVH pair sets
are compared against exhaustive leaf tests using C's matching AABB or OBB routine.
The AABB oracle compiles `filterBox` extracted verbatim from the pinned C source.
Each build also passes 3,969 union-containment boundary cases, including
subnormals, degenerate boxes, cancellation and admitted coordinate limits.
Invalid octree cycles, singular gradients, atomic capacity failure, stale BVH
bounds, malformed topology and incomplete refits have dedicated checks.

The largest observed absolute component difference is `4.34e-7`, in a
tetrahedron/rigid convex case (accepted tolerance `2e-5`). Analytic SDF queries,
sampled SDF queries, specialized triangle contacts, SDF objectives/descent,
SDF contact generation and mesh/SDF contacts match exactly in these fixtures.
This is finite-case differential evidence, not a universal equivalence proof.

| Formal scope | Status |
| --- | --- |
| `Flex_Support.Select_Vertex`, complete unit | 35 checks proved: ordered floating dot maximum, first tie, indices, safety and termination. |
| `SDF_Fields.Product` | 6 checks proved, including exact floating product and its bounded result. |
| `SDF_Fields.Interpolate` | 35 checks proved, including the exact eight-term floating accumulation order. |
| Full flow analysis of 12 units, including both generic instances | 492 checks passed for dependencies, flow initialization and termination. |
| BVH union and scalar proof chain, plus the containment/AABB/sphere predicates | 139 checks closed across twelve minimal scopes. Both-child containment and arithmetic safety are proved for the declared domain. |
| Full BVH, SDF and flex safety/functional proofs | **Pending.** Flow success does not prove runtime checks, relaxed-initialization assertions, caller preconditions or functional contracts. |

Proof engineering is still required for BVH topology/refit/traversal invariants,
oriented-frame bounds, stack prefixes, SDF searches/candidates and flex driver
composition. No Silver-only mathematical exception is claimed for this work;
timeouts and missing invariants are not mathematical limitations. There are no
new assumptions, suppressions or trusted bodies. Existing dependency warnings
and modeled deallocation remain as copied. Compiler warnings include a possible
initialization warning at the SAP prefix invariant; its runtime/proof initialization
obligations must be distinguished from the successful flow analysis.

## Domain and integration boundaries

- Trees admit at most 4,096 leaves / 8,191 nodes. Pair work buffers admit 65,536
  pairs; overflow returns `Capacity_Limit` with no active partial result. Contact
  batches have caller-selected capacity; filtering caps each collision group at
  50 contacts, matching C. These fixed capacities require review for larger models.
- Inputs are finite and bounded under the package contracts. BVH topology is a
  contiguous preorder, as required by C's self-pair pruning. `Fits` ties imported
  trees to element/triangle geometry; callers must refit after moving vertices.
- Bounding-box unions use a small outward rounding allowance. Their internal
  bounds can differ from C's construction; tests establish candidate-pair coverage
  on the exercised fixtures, not identical tree shape or traversal order.
- Singular gradients and admitted numerical limits produce explicit rejection
  or skip the affected search candidate rather than emitting NaN contacts.
  Ellipsoid SDF sizes below `1e-10` and sampled cell widths below `1e-20` are
  rejected explicitly. This policy differs from unguarded C behavior at singularities.
- Flex/SDF supports dimension 2, as C 3.14.0 does. C's heightfield/SDF combination
  is itself unsupported. Heightfield/flex for dimensions 1, 2 and 3 is implemented.
- The public results are geometric precontacts. Main `Model/Data` ownership,
  native plugin ABI and lifecycle, final scene contact sorting, materials,
  constraint assembly and solver hookup are not performed by this candidate.
  A native Ada provider is supported; an arbitrary external C plugin is not
  automatically translated into SPARK.
- The main simulator does not yet call these packages. Integrated performance
  parity with C is **not measured**. The numerical release tests are not timing
  evidence, and no full movement-performance claim follows from them.

## Reproduce

Use GNAT 16.1, GPRbuild 26, GNATprove 16.1, Python with NumPy and MuJoCo 3.14.0,
the clean pinned MuJoCo source and its compatible libccd build. Local defaults
point to the project's recovered Linux toolchains; every path can be overridden.
Run from this candidate directory:

```sh
/var/tmp/sparkling-movement-env/bin/python tests/run.py --out /var/tmp/advanced-check-unique
/var/tmp/sparkling-movement-env/bin/python tests/prove.py --out /var/tmp/advanced-proof-unique
```

To reproduce the local union timing comparison against the preserved original
Ada implementation:

```sh
/var/tmp/sparkling-movement-env/bin/python tests/benchmark_union.py --out /var/tmp/advanced-union-timing-unique --baseline-dir results/20261002-bvh-containment/baseline-src
```

Each output directory must be new. The runners freeze sources into that directory,
write logs and reports there, and preserve source/binary/compiler hashes. The C
oracle is linked only into its own shared library. Proof runs start at the minimal
subprograms and then run complete flow scopes. Every selected scope must close;
`--scope bvh-lower` (or another listed scope) isolates diagnostics. An isolated
caller proof assumes its callees' contracts; the default run checks the full
listed helper chain. It does not prove the entire BVH unit.

The project uses `-gnata -gnato -gnatVa -O1` for validation and
`-O3 -gnatp -gnatn -march=native -flto` for release. Both use `-ffp-contract=off`.
Release callers must satisfy the documented preconditions before removing
assertion checks. Existing main candidates are not modified by these runners.

See [BVH_PROOF.md](BVH_PROOF.md) and `results/20261002-bvh-containment/` for
the current checked/release reports, proof receipts and reproducibility manifests.
`results/20261002/` retains the initial evidence, including the eight formerly
open union obligations. The union uses inline scalar helpers and C-style finite
min/max selection, with proved ghost lemmas for outward rounding. No new admission scan is introduced in the release path. A paired microbenchmark measures the original Ada
union against this implementation; see the report for timings and uncertainty.
It does not measure an integrated movement step or establish parity with C.
Only geometric feature implementation is complete in this candidate; simulator
integration, full Gold and performance acceptance remain separate work.
