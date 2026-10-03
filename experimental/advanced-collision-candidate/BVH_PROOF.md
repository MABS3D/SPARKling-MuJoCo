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

## Recovery: exact frame cache, 2026-10-03

The integrated SDF7 snapshot subsequently closed the complete BVH unit with
853 checks and no open obligations, retaining eight warnings. Its exact source
closure and reports are in `evidence/20261003-recovery/sdf7-bvh-*`; the earlier
standalone numerical and timing evidence above is not automatically renewed.

The new `Cache_Matches` contract specifies the 36 rotation products and 12
projected origins using the implementation's floating-point evaluation order.
`Model_Cache`, component-equality lemmas, and prefix invariants are Static ghost
code with proved bodies. The operational loops and arithmetic assignments are
unchanged. Both the existing bound and the new functional postcondition are
Static; this proof does not assert exact real orthogonality.

The immutable cache11 closure refreshes only `mj-bvh.ads` and `mj-bvh.adb` over
the 350-source SDF stage2 closure. All twelve minimal scopes have complete
reports with 141 proof checks and 19 flow checks closed, zero open obligations
and zero warnings. In particular, `Prepare_Bounded` closes 65 proof checks and
one flow check. The complete-unit renewal reached its 900-second watchdog with
no final report (exit99, peak group RSS 507 MB). Its proof count is unknown;
the successful minima do not close the complete unit. Source manifest SHA256:
`12ae9ad4b4bf296e8717a19d775cbaa420dba2d81dd74cb0ac424028e3d63c50`.
The serial runner is `tests/prove_frame_cache.py`; receipts are retained in
`evidence/20261003-frame-cache/`, including all preceding failed attempts.

The fresh cache12 renewal uses all 350 identical source hashes and an explicit
1,200-second total limit. It completes in 1,027 seconds: 857 proof checks and
109 flow checks close, with eight warnings and two open initialization checks
in the `Traverse` pair-prefix invariant. The prover reports memory limits for
those two checks, not counterexamples. This is a complete report with open
obligations, distinct from the report-less cache11 watchdog. Cache13 makes
per-element initialization explicit in that invariant; its minimal traversal
proof is pending. No operational traversal statement was changed.

Cache13's traversal minimum subsequently closes 93 proof and 8 flow checks,
with zero open obligations or warnings. The fresh complete cache14 unit then
closes **860 proof + 109 flow checks, zero open**, in 974.4 seconds (499 MB peak
group RSS). The 350-source manifest SHA256 is
`28eeaf9ff52e00643bec20bd3bf57a15c0b5950cf31935a7b4f271686381c698`.
Eight warnings remain: five existing operator-reassociation diagnostics outside
the new cache formulas and three array-initialization-analysis diagnostics whose
runtime obligations are proved. This is not a warning-free build or a universal
C-equivalence proof. Validation/release numerical renewal uses these same
frozen sources and is pending separately.

The numerical renewal is now complete: **2,429/2,429** native-C comparisons
and all **3,969** containment cases pass in each profile. All 350 runtime-source
hashes match the proof snapshot, and the two complete outputs are byte-identical.
`cache14-composition.json` records the linkage. The first harness attempt hit
its default stack limit; the identical binary passed with an explicit 128 MiB stack,
then both complete profiles were rebuilt and tested under that recorded limit.
The failed attempt and separate replay remain in the evidence directory. No
performance measurement was made.

Universal pair enumeration remains open. A future contract must distinguish
the exact stack/pruning algorithm from an exhaustive geometric leaf test:
the self-pair pruning requires contiguous preorder topology, imported C bounds
may not enclose padded leaves, and rounded oriented projections do not imply
exact real geometry. `Topology_Valid` checks reachability and preorder at
runtime, but its current postcondition exposes only shaped nodes and unique
leaf identifiers. Those topology facts need their own proved model before a
modular completeness claim can use them. No assumption or stronger admission
restriction has been introduced to bypass this work.
