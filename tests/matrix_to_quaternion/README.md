# Matrix to quaternion

The [2026-09-29 SIMD optimization](optimization_20260929/README.md) retains the
Gold functional contracts and reduces median conversion time by 5.6–10.8%
versus C across all ten patterns in two balanced sessions on the measured CPU.
The original 2026-09-28 results below are preserved as historical evidence.

`MJ.Quaternions.From_Matrix (Q, A, Result)` implements the four branches of
MuJoCo 3.14.0 `mju_mat2Quat`, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The official latest-release endpoint
was checked again on 2026-09-28 and returned 3.14.0. The existing quaternion
reference manifest pins the actual C sources and their project headers.

```ada
declare
   A : Matrix_3 := [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];
   Q : Quaternion;
   Result : Conversion_Status;
begin
   From_Matrix (Q, A, Result);
   --  Result = Success, Q = [1.0, 0.0, 0.0, 0.0].
end;
```

## API and floating-point behavior

Matrices are row-major, zero-based 3x3; quaternions are `(w,x,y,z)`. Input
components must be finite Tier0 values, [-1e10,1e10], under the existing numeric
model. Input and output objects must not overlap under SPARK aliasing rules.
The input matrix is preserved; the operation allocates no heap storage.

The implementation retains the C trace comparison, strict diagonal comparisons,
tie order, multiplication-before-division and final `normalize4` behavior. It
does not rearrange division into reciprocal multiplication. It accepts bounded
nonorthogonal, singular and reflection matrices too, matching C's formulas;
it does not validate a rotation or find the nearest proper rotation.

The selected radicand is proved in [0,4e10]. The existing standard Ada runtime
`Sqrt` contract supplies nonnegativity, positivity and the zero/one identities,
but no quantitative lower/upper bound. Before division, the implementation
checks that the rounded pivot `0.5*Sqrt(radicand)` lies in [1e-15,1e15].
Otherwise it returns `Numeric_Limit` and the identity quaternion. It neither
clips the pivot nor reports a successful identity conversion on that path.
The public postcondition specifies both outcomes exactly. This guard is about
the numeric/runtime boundary, not an orthogonality test.

On success, the raw quaternion is Tier1 and the normalized output has the
existing conservative Tier2 guarantee. The functional model specifies the
ordered normalization, including tiny-length identity and near-unit no-op.
Exact unit norm, a universal error bound, exact matrix round trips and universal
equivalence to C are separate claims. The ordinary C implementation rejected
none of the test inputs, and neither did the Ada implementation.

The `abs` before each square root is proved numerically redundant; it exposes
nonnegativity to the compiler. A private normalization helper retains C's ordered
scalar sum and threshold path. The optimized implementation packs independent
divisions and norm squares into SIMD lanes, without reciprocal approximation.
Its result is specified against the same ordered ghost model.
Ghost functions are static and are not evaluated in checked or release builds.
The existing quaternion/pose APIs, arithmetic and deallocators are unchanged.

## Reproduction

From the repository root, with Python 3 and the native GNAT toolchain:

```sh
python3 tests/matrix_to_quaternion/check.py --out /tmp/matquat-check \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
```

Use a fresh output directory when any source changes. `--phase small` diagnoses
the minimal subprograms first; `--phase proof` then proves the complete quaternion,
pose and rotation units with the existing freshness/coverage gate. `--phase
numeric` builds and compares development, validation and release. `--phase
performance` measures two sessions on `--cpu` (default 12). The default runs all
phases in that order. Build artifacts and logs stay in the output directory.

The numeric corpus covers all four branches, exact/near half turns, diagonal
ties, neighboring trace thresholds, identity, zero matrices, nonrotations,
Tier0 endpoints, subnormals and seeded random inputs. It invokes the actual C
function, checks every quaternion component for exact finite numerical equality
(zero sign bits are excluded), and checks input preservation. Independent
orientation anchors and approximate matrix round trips add separate checks.
Checked builds also reject all 18 signed out-of-domain component cases.

The benchmark uses the normal C SIMD build, matched optimization/FP flags,
21 alternating Ada/C pairs per pattern, batches of 64 matrices, CPU affinity,
warmups and checks outside the timed region. Raw samples, MAD and individual
bootstrap intervals are retained. The same typed storage is used by both
languages; initialization, IO and model construction are outside timing.
These are kernel measurements. The smooth dynamics pipeline does not yet call
this API, so they cannot establish any integrated movement speedup.

## Initial results (2026-09-28, before SIMD optimization)

The final source snapshot was checked on 2026-09-28. All **17 new minimal
subprograms** passed first, followed by fresh complete-unit runs and the
repository's source-freshness, coverage and fully-SPARK gates. Solver sessions
were reused for unchanged quaternion verification conditions; the final reports
and gates were regenerated against the final source hashes. The archive records
that cache origin. Counts below include the existing operations in these units,
not only the new conversion.

| Complete unit | Proof checks | Flow checks | Unproved | Warnings |
|---|---:|---:|---:|---:|
| `mj-quaternions` | 615 | 85 | 0 | 16 |
| `mj-poses` | 181 | 23 | 0 | 2 |
| `mj-rotations` | 55 | 13 | 0 | 0 |

The new API meets the **Gold functional contract for the ordered floating-point
algorithm**, under the existing runtime contracts. This includes exact output
relations, branches, normalization and explicit failure behavior. No assumptions,
proof suppressions, skipped bodies or new trusted project bodies were added.
The retained warnings concern the limited standard `Sqrt` contract and the
existing `Loop_Optimize` directive ignored by the prover. There are no remaining
operator-reassociation warnings in these final reports. These results do not
prove ideal-real rotation accuracy or the whole dynamics pipeline.

Development, validation and release each passed the following numerical checks:

| Suite | Cases per profile | Scalar comparisons per profile |
|---|---:|---:|
| `matrix_to_quaternion` | 6,207 | 24,828 |
| `quaternions` | 4,023 | 152,874 |
| `poses` | 9,404 | 357,352 |

Every comparison matched C exactly as a finite numerical value; signed-zero bits
are outside this claim. The new corpus also passed 10 independent orientation
anchors, 3,066 approximate rotation round trips, input-storage preservation, and
5,120 additional scalar comparisons of the timing fixtures per profile. Maximum
observed matrix round-trip error was `5.551115123125783e-16`; maximum squared-norm
error was `6.661338147750939e-16`. These are measured errors on the corpus, not
proved universal bounds. All 18 signed out-of-domain component cases were
rejected by each checked profile; they were deliberately not run in release.
No admissible corpus input returned `Numeric_Limit`.

The final unit also compiled through `sparkling_mujoco.gpr` in release mode.
The release-code audit found no FMA instructions in either measured wrapper and
no executable quaternion ghost-model or normalization-lemma symbols. This was a
unit integration compile, not a full-library proof or simulator validation.

### C performance diagnostic

Two sessions on CPU 12 used 21 alternating pairs per pattern, with a 15 ms target
per sample. Times are nanoseconds per conversion averaged over each timed batch;
the table reports session medians. Ratios are medians of paired Ada/C samples;
values above one favor C. Brackets contain each session's 95% bootstrap interval.
MAD, raw CPU/wall timings, context switches and p95 sample averages are retained
in the archive. The p95 values are not individual-call latency percentiles.

The process snapshots at the start of both sessions show no active compiler or
prover; one-minute Linux load averages were 1.71 and 1.83. CPU affinity and
pairing reduce some noise, but do not establish an otherwise idle Windows/WSL
host. Intervals crossing one are inconclusive; a small difference is not
automatically classified as a regression. These measurements do not establish
parity across hardware or an integrated movement speedup, and residual slow
cases remain open.

| Pattern | C ns, S1 / S2 | SPARK ns, S1 / S2 | Ada/C S1 [95%] | Ada/C S2 [95%] |
|---|---:|---:|---:|---:|
| Identity | 5.27 / 5.24 | 5.41 / 5.43 | 1.026 [1.019, 1.035] | 1.034 [1.029, 1.045] |
| W dominant | 5.26 / 5.25 | 5.43 / 5.43 | 1.037 [1.022, 1.048] | 1.033 [1.025, 1.058] |
| X dominant | 5.26 / 5.28 | 5.91 / 5.89 | 1.122 [1.113, 1.129] | 1.118 [1.095, 1.128] |
| Y dominant | 5.33 / 5.28 | 5.90 / 5.93 | 1.123 [1.087, 1.130] | 1.123 [1.106, 1.136] |
| Z dominant | 5.27 / 5.28 | 5.89 / 5.98 | 1.118 [1.116, 1.131] | 1.119 [1.114, 1.149] |
| Trace/diagonal tie | 5.35 / 5.28 | 5.93 / 5.99 | 1.118 [1.103, 1.121] | 1.130 [1.113, 1.147] |
| Nonorthogonal | 6.14 / 6.13 | 6.54 / 6.53 | 1.064 [1.049, 1.081] | 1.060 [1.050, 1.071] |
| Tier0 wide | 6.11 / 6.13 | 6.46 / 6.46 | 1.060 [1.050, 1.067] | 1.054 [1.050, 1.061] |
| Zero matrix | 6.22 / 6.22 | 6.85 / 6.98 | 1.101 [1.095, 1.108] | 1.105 [1.095, 1.118] |
| Mixed unit rotations | 5.25 / 5.24 | 5.62 / 5.62 | 1.066 [1.059, 1.084] | 1.064 [1.058, 1.081] |

The initial implementation used a private scalar normalization path. Earlier
diagnostics found extra dispatch and SIMD packing costly for this conversion;
the existing public `Normalize` implementation was left intact. A fully
duplicated per-branch implementation was also tried and rejected after slower
measurements. These prototype diagnostics are not used as final proof receipts
or as evidence of an integrated speedup.

See [results.json](results.json) for the structured results,
[evidence.zip](evidence.zip) for the exact source snapshot, commands, compiler
metadata, pinned C sources, proof reports, differential logs and raw timing
samples, and [SHA256SUMS](SHA256SUMS) for the archive and summary checksums. The
archive includes a separate checksum inventory of every archived file.
