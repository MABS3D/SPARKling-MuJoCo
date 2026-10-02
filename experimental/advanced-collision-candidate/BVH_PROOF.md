# BVH containment and finite min/max — 2026-10-02

The eight previously open `Union_Box` obligations are closed through minimal
scalar subprograms. The finite min/max branches follow `mju_min`/`mju_max` in
MuJoCo 3.14.0 `engine_util_misc.c`, including first-operand ties. Their caller
bounds exclude non-finite inputs. This avoids the compiler's general-purpose
min/max handling without adding a release admission scan or narrowing `Union_Box`'s
existing input domain.

## Formal scope

`Minimum` and `Maximum` prove equivalence to the Ada numeric min/max on their
declared finite domain. `Lemma_Lower` and `Lemma_Upper` prove that the existing
outward padding covers endpoint reconstruction roundoff. `Lemma_Monotonic`
provides ordered floating addition/subtraction relations, and `Lemma_Transitive`
isolates composition of the resulting inequalities. These ghost procedures
have proved bodies: no assumption, suppression or new trusted body is used.

`Enclose` computes a padded interval and proves containment of its endpoints;
`Union_Axis` derives the child interval bounds; `Union_Box` composes all three
axes and proves that the resulting box contains both inputs. The ghost `Bounded`
predicate makes containment arithmetic safe even when the union exceeds tree
admission limits. `Valid` and the existing `Numeric_Limit` policy are unchanged.
The runtime helpers are inline; assertions and ghost code are absent in release.

Containment refers to the rounded endpoints `Center +/- Half` used by the BVH.
This is a functional integrity proof (Gold) for the listed union chain, not full
collision correctness or a theorem about exact real geometry. The original
outward padding remains; internal bounds need not be bitwise identical to C.

| Scope | Closed checks |
| --- | ---: |
| `bvh-min` | 3 |
| `bvh-max` | 3 |
| `bvh-lower` | 7 |
| `bvh-upper` | 7 |
| `bvh-monotonic` | 6 |
| `bvh-transitive` | 2 |
| `bvh-enclose` | 60 |
| `bvh-axis` | 23 |
| `bvh-contains` | 6 |
| `bvh-overlap` | 8 |
| `bvh-sphere` | 6 |
| `bvh-union` | 8 |

Total: **139** checks; zero unproved obligations in these 12 scopes.

The default proof runner checks these bodies, the existing 76 checks for SDF
product/interpolation and flex support, and then 12-unit flow analysis (492
checks). Full BVH topology/build/refit/traversal proofs, oriented-frame
composition, SDF searches and flex drivers remain pending. Flow analysis does
not close their runtime and functional obligations. Timeouts or missing
invariants are unfinished proof work, not Silver-only mathematical exceptions.

## Numerical evidence

- Both checked and release builds pass 2,425 native C differential cases.
- The 96 added BVH cases cover extreme scales, zero-width leaves, duplicate
  boxes and refits, compared against exhaustive native C leaf-pair sets.
- Each build passes 3,969 additional union containment boundary cases, including
  subnormal widths and cancellation. These independently check the property.
- AABB uses `filterBox` extracted verbatim from the pinned MuJoCo 3.14.0 source;
  OBB uses `mj_collideOBB`. The two formulas can round differently at extremes
  and cannot be interchanged as the numerical oracle.
- These finite tests support compatibility for the exercised cases; they do not
  prove universal numerical equivalence or the complete collision pipeline.

## Local performance measurement

| Boxes per input | Baseline ns/union | Current ns/union | Paired current/baseline ratio [95% interval] |
| ---: | ---: | ---: | ---: |
| 16 | 9.329 | 6.089 | 0.644 [0.603, 0.678] |
| 256 | 9.406 | 5.963 | 0.632 [0.612, 0.653] |
| 4,096 | 9.456 | 6.048 | 0.642 [0.625, 0.656] |


The comparison is original Ada versus current Ada, using identical release
flags/compiler and the preserved baseline BVH sources. It is not a native C
speed comparison. Each sample performs 4,000,000 unions with moving input,
consumes all six output components, and checks matching baseline/current
checksums. Setup and I/O are outside the timed region. There are 11 paired
samples per size, alternating order, after warmup, with each benchmark child
pinned to the same CPU. Ratios are paired medians; intervals are a 10,000-resample
bootstrap estimate for the median. Raw samples and quartiles are retained.

This local result does not measure full BVH traversal, a simulation step, or
performance parity with C. Integrated acceptance remains pending.

Receipts: [results/20261002-bvh-containment](results/20261002-bvh-containment/).
Source hashes bind the proof, numerical and benchmark snapshots to these files.
No main simulator integration is introduced by this change.
