# Pose verification and performance evidence

Snapshot: 2026-09-24. Scope: `MJ.Poses`, widened quaternion normalization and
the value-returning quaternion product, with `MJ.Rotations` integration.
See [the contract and status report](../../../docs/poses.md).

- [Summary](summary.json): 694 proved checks, zero unproved; 1,989,822 scalar
  comparisons; performance gate **OPEN**, with 7 of 70 pose/product cases slower.
- [Minimal subprogram index](minimal.json) and
  [invocations](minimal-invocations.log): 17 successful small proof targets,
  followed by complete-unit proofs. These diagnostic logs are not substitutes
  for whole-unit receipts.
- Complete proof reports and fresh source-bound receipts:
  [quaternions](mj-quaternions.spark), [receipt](mj-quaternions-proof-receipt.json);
  [poses](mj-poses.spark), [receipt](mj-poses-proof-receipt.json);
  [rotations](mj-rotations.spark), [receipt](mj-rotations-proof-receipt.json).
  Corresponding `*-proof.log` and `*.invocation.json` files retain tool output
  and invocation details. Nine warnings remain at the documented square-root
  modeling and ignored-optimization-pragma boundaries.
- [Numerical results](numeric.json): three suites in development, validation
  and release, including source and executable hashes. Finite numerical equality
  does not assert equality of zero sign bits or universal equivalence to C.
- [Project release build](project-release.log): compilation through the main GPR.
- [Pose/product performance](performance.json): all 70 cases, raw alternating
  sample pairs, bootstrap intervals, flags, hardware and source/binary hashes.
  31 pairs per case, 25 ms target; 43 faster, 20 within noise, 7 slower.
- [Norm/Normalize performance](normalization-performance.json): all 16 requested
  cases; 7 faster, 9 within noise. The
  [focused follow-up](normalization-followup.json) records four cases rerun after
  the preceding snapshot's two small slowdown flags; none was slower there.
- [Code-generation summary](codegen.json) and [hot-loop disassembly](hot-loops.asm):
  extracted from the exact measured pose executable. SIMD arithmetic is present
  in the Ada transform, composition and product loops; no calls or FMA in the
  measured hot loops. This is evidence for this build, not every target.
- [Optimization follow-up](optimization-round2/README.md): six measured source
  candidates, two unproved prototypes and one build-only probe; none accepted.
  Focused baseline repeats and a balanced same-executable control refine the
  remaining priorities without replacing the 70-case reference. The reusable
  [build comparator](../compare_builds.py) retains direct Ada/Ada, C/C and both
  Ada/C comparisons. At the end of that investigation the production kernel
  and rebuilt binary matched this snapshot exactly.
- [Proof refresh after the transpose optimization](../../matrix_performance/evidence/README.md):
  the same 694 pose/quaternion/rotation checks pass with fresh receipts bound
  to the updated matrix sources. The historical receipts here remain unchanged;
  no new pose timing claim is made by that proof refresh.
- `*-version.txt`: native compiler, build-tool and prover version output.
- [Earlier complete snapshot](before-scalar-shortcut/summary.json): preserved
  before the scalar-quaternion shortcut, with 28 of 70 pose cases slower and
  two standalone normalization slowdown flags. Its receipts refer to its own
  source snapshot; it is historical evidence, not proof of the current body.
- [Manifest](manifest.json): SHA-256 hashes of all evidence files, including the
  historical snapshot. The manifest itself is excluded from its own digest map.

Performance pattern IDs: 0 general unit quaternion; 1 identity; 2 zero quaternion;
3 negative identity; 4 nonunit quaternion; 5 tiny quaternion; 6 Tier0 limits;
7 zero translations/point; 8 near-unit normalization threshold;
9 near-minimum normalization threshold. Pattern definitions live in the fixture
and are bound by its recorded source hash.

This snapshot does not close the matrix performance gate or claim whole-engine
verification. Every reproducible slowdown remains unfinished work.
