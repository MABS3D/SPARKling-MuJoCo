# Matrix-to-quaternion optimization — 2026-09-29

The release implementation now packs the four raw-component divisions into SIMD
lanes. The dominant lane computes Pivot / 1; the other lanes retain C's ordered
0.25 * (sum or difference) / Pivot. Independent norm squares are also packed,
while the norm's scalar sum, standard square roots, branch/tie selection,
normalization thresholds and numeric-limit guard are preserved. There is no
reciprocal approximation, reassociation, FMA, new compiler flag or API change.
Only the private conversion implementation in `src/mj-quaternions.adb` changes.

The reference is stock MuJoCo 3.14.0 `mju_mat2Quat`, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, with normal C SIMD enabled. The official
latest-release endpoint was checked on 2026-09-29 and still returned 3.14.0.

## Performance

Measured on AMD Ryzen 7 9800X3D, Linux/WSL, logical CPU 12, using the same release
flags for Ada and C. Each of two final sessions uses 48 blocks per pattern.
Each block runs previous Ada, previous C, optimized Ada and optimized C in a
balanced, randomized order: all 24 permutations occur twice. Each sample aims
for 20 ms; preparation, correctness checking and warm-up are outside timing.
Each pattern uses the existing batch of 64 matrices.

The median CPU-time reduction versus C is **5.6–10.8%** across the
20 pattern/session results; versus previous Ada it is **10.8–18.5%**.
These are ranges of individual results, not a weighted workload average.

Every pattern in both sessions has an individual 95% paired-bootstrap median
ratio interval entirely below 1, against both C binaries. The table gives
optimized Ada / C in the new binary, with that interval in brackets.
Intervals are individual, not simultaneous family-wise confidence guarantees.

| Pattern | Session 1 ratio [95% interval] | Session 2 ratio [95% interval] |
|---|---:|---:|
| Identity | 0.8976 [0.8869, 0.9099] | 0.9008 [0.8912, 0.9125] |
| W dominant | 0.8924 [0.8821, 0.9102] | 0.9032 [0.8831, 0.9195] |
| X dominant | 0.9072 [0.8998, 0.9193] | 0.9115 [0.9014, 0.9385] |
| Y dominant | 0.9263 [0.9082, 0.9420] | 0.9409 [0.9177, 0.9669] |
| Z dominant | 0.9172 [0.9071, 0.9389] | 0.9326 [0.9078, 0.9681] |
| Trace / diagonal ties | 0.9153 [0.9075, 0.9263] | 0.9443 [0.9303, 0.9878] |
| Nonorthogonal matrices | 0.9070 [0.9023, 0.9136] | 0.9444 [0.9206, 0.9611] |
| Wide Tier0 inputs | 0.9147 [0.9045, 0.9314] | 0.9387 [0.9162, 0.9649] |
| Zero matrix | 0.9294 [0.9228, 0.9357] | 0.9372 [0.9224, 0.9599] |
| Mixed rotations | 0.9076 [0.8988, 0.9165] | 0.9076 [0.8938, 0.9238] |

`results.json` also retains absolute median times, MAD, p95 sample-average times,
old/new Ada ratios and the C-to-C control. The archive contains every raw sample,
wall/CPU time, context switches, order, executable hashes and host metadata.
The two standard 21-pair sessions from `check.py` are retained too; all ten
patterns were classified faster there as well. No final sessions are omitted.

These are hot, batched kernel throughput measurements on this machine, not
single-call latency, a guarantee for other CPUs or a whole-engine speedup.
The experimental smooth dynamics pipeline does not call this public API.

## Formal and numerical checks

All 17 minimal-subprogram proofs passed before complete-unit verification.
The complete-unit freshness, coverage and fully-SPARK gates then passed:

| Unit | Proof checks | Flow checks | Unproved | Warnings |
|---|---:|---:|---:|---:|
| Quaternions | 629 | 89 | 0 | 18 |
| Poses | 181 | 23 | 0 | 2 |
| Rotations | 55 | 13 | 0 | 0 |

Total: **990 proved checks, zero open obligations** across those three units.
The unit also compiles in release through the main `sparkling_mujoco.gpr`
project; this is a unit integration compile, not a full-library build or proof.
The conversion retains its Gold functional contract: the exact ordered
floating-point model, branches, bounds, normalization and failure behavior.
The public spec and ghost model are unchanged. No assumptions, suppressions,
skipped bodies or new trusted project bodies were added. Why3 solver sessions
were reused; frontend analysis, source hashes, reports and gates are fresh.
The archive records the cache origins.

The two additional warnings are the prover ignoring `Loop_Optimize (Vector)`
for the new loops; it still proves the loop bodies. Existing standard-runtime
`Sqrt` contract warnings remain. Proof is conditional on those runtime contracts
and does not establish ideal-real rotation accuracy or universal C equivalence.

Development, validation and release each pass:

| Suite | Cases | Scalar comparisons |
|---|---:|---:|
| Matrix to quaternion | 6,207 | 24,828 |
| Quaternion regression | 4,023 | 152,874 |
| Pose regression | 9,404 | 357,352 |

Every scalar matches the pinned C implementation exactly as a finite numerical
value (signed-zero bits excluded). Each profile also passes 10 orientation
anchors, 3,066 approximate matrix round trips and 5,120 timing-fixture scalar
comparisons. Maximum matrix round-trip error remains 5.551115123125783e-16.
Both checked profiles reject all 18 out-of-domain cases. Release is tested only
under its preconditions. Input preservation and all success statuses pass.

Disassembly confirms `vdivpd` for the packed division and `vmulpd` for the norm
squares, scalar ordered accumulation and native standard square roots. The
measured wrappers have no FMA, and the executable has no quaternion ghost-model
or congruence-lemma symbols.

## Reproduction and evidence

From the repository root:

```sh
python3 tests/matrix_to_quaternion/check.py --out /tmp/matquat-verified \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
python3 tests/matrix_to_quaternion/optimization_20260929/compare.py \
  --baseline /path/to/previous/release/bin/main \
  --current /tmp/matquat-verified/snapshot/tests/matrix_to_quaternion/build/release/bin/main \
  --out /tmp/matquat-comparison-1.json --session 1
```

Repeat the comparison with `--session 2` and a distinct output file. Select an
available logical CPU using `--cpu` when needed. Keep build/proof jobs out of the
measurement window; recorded host metadata makes remaining interference visible.
Use a fresh verification output directory after source changes.

`evidence.zip` contains the exact final source/test/reference closure, manifests,
commands, fresh proof and numeric logs, raw performance sessions and disassembly.
It also contains the original body (`optimization/original.adb`) and baseline
source manifest: reconstruct the previous executable in a separate copy of the
snapshot by replacing only `src/mj-quaternions.adb`, then build the same release
project. Binary hashes identify the actual executables measured in this run.
The archive includes the comparison and packaging scripts. `SHA256SUMS` checks
the deliverables; a second manifest inside the archive checks its members.
The original 2026-09-28 evidence is preserved separately in the parent directory.
