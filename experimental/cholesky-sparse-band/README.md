# Sparse and band-dense Cholesky candidate

This addition implements the missing sparse and band-dense algorithms in a
separate build. It does not change the existing dense Cholesky candidate or the
smooth dynamics pipeline. It is not yet an integrated, fully proved Gold kernel.

The reference is [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0),
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The official latest-stable
release was checked again on 2026-09-30. See [NOTICE](NOTICE) for attribution.

## Operations

| SPARK operation | MuJoCo reference | Behavior |
| --- | --- | --- |
| `MJ.Cholesky_Band.Factor` | `mju_cholFactorBand` | Forward `A = L Lᵀ`, band plus final dense rows, diagonal additions/scaling |
| `MJ.Cholesky_Band.Solve` | `mju_cholSolveBand` | Forward/back substitutions using band storage |
| `To_Dense`, `From_Dense` | `mju_band2Dense`, `mju_dense2Band` | Lower triangle and optional symmetry; preserve unused band padding on packing |
| `Multiply` | `mju_bandMulMatVec` | One or more contiguous vectors, optionally symmetric matrix |
| `Diagonal` | `mju_bandDiag` | Address of the diagonal in hybrid storage |
| `MJ.Cholesky_Sparse.Symbolic_Count` | First `mju_cholFactorSymbolic` pass | Reverse elimination tree, counts and row addresses from the upper pattern |
| `Symbolic_Fill` | Second symbolic pass | Lower CSR, transpose and direct map into the lower values |
| `Factor` | `mju_cholFactorSparse` | Reverse `A = Lᵀ L`, sorted sparse merging with fill in preallocated row capacities |
| `Numeric` | `mju_cholFactorNumeric` | Reuse the fixed symbolic pattern, sparse scatter and ancestor contributions |
| `Solve` | `mju_cholSolveSparse` | Reverse/forward substitutions; four-lane sparse dot reduction |
| `Update` | `mju_cholUpdateSparse` | Fixed-pattern rank-one update or downdate, reverse Givens rotations |

No operation converts a sparse matrix to dense in order to factor or solve it.
Symbolic work arrays, numeric workspace and merge scratch occupy O(n) space.
The stored factor itself can become dense when the graph requires fill.

## Storage and use

Arrays start at zero. `Size` is 0..4096. `Values` stores binary64 scalars;
`Indices` stores natural offsets. All buffers belong to the caller. SPARK's
usual non-aliasing rules apply; solve receives distinct RHS and output buffers.

For band storage, the first `n - dense` rows have `band` entries each, with
the diagonal at the right end. The final `dense` rows have `n` entries each.
Only their lower triangle is data. The array length is
`(n - dense) * band + dense * n`. `band = 0` is valid for an all-dense or empty
matrix. Bands wider than the dimension are supported and retain their padding.

For sparse storage, each row has sorted, unique columns; the diagonal is last.
`Count` is the active length. Capacity runs from `Adr(r)` to `Adr(r+1)` or the
end of the buffer. Call `Symbolic_Count`, allocate the returned total number of
entries, then call `Symbolic_Fill`. For repeated systems with the same graph,
reuse those arrays with `Numeric`; its source matrix is lower CSR and may omit
zero diagonals or have empty rows. The symbolic
input is upper CSR. Transpose rows start with the diagonal; remaining entries
keep C's elimination discovery order and must not be sorted independently of
their map.

`Update` requires `Update_Closed`: all lower active update columns must be
present in each affected factor row, including those propagated by rotations.
This is a conservative structural condition. It can require extra structural
entries even when particular values are zero or would cancel them. No new fill
is added by update, matching C's contract.

## Numeric behavior and explicit differences

The dense and sparse reductions use C's four lanes, combine `(s0+s2)+(s1+s3)`,
then use the respective dense or sparse tail order. FMA contraction is disabled.
All successful scalar operations have exact binary64 expression contracts.

The supported scalar domain is ±1e100, including work entries and results.
Products and divisions are evaluated in binary64 with safe intermediate bounds;
an intermediate outside the work domain returns `Numeric_Limit`. This is a
documented restriction beyond C's unguarded floating-point API, not an accuracy
or stability guarantee. It can reject systems that C completes using larger
intermediates. Inputs outside the domain, NaNs and infinities are not admitted.

Sparse factorization clamps Schur pivots below `Minimum` (at least `1e-15`)
and reports the number of unclamped pivots as `Rank`. Direct `Factor` retains
scaled off-diagonals on a clamp; `Numeric` zeros them. Both reproduce their
different C routines. Sparse downdate clamps at `1e-15` and reduces `Rank`.

Band factorization rejects a pivot below `1e-15`, returns
`Not_Positive_Definite` and sets `Min_Pivot` to zero. On success, `Min_Pivot`
is the minimum Schur pivot **before** its square root. An empty matrix succeeds
with `Min_Pivot = -1`, matching C. Unlike C's symbolic n=0 out-of-bounds path,
the sparse symbolic API handles the empty matrix explicitly.

`Numeric` preserves inactive factor padding and initializes workspace to zero.
The reference tests give C a zero workspace: although its header says initial
contents are ignored, the pinned implementation scatters and accumulates into
scratch without an initial full zero. This candidate honors the stated scratch
contract for any initial contents. Reusing an already zero workspace without
that initialization will require a separately proved caller contract.

`Insufficient_Capacity`, `Missing_Fill` and `Invalid_Pattern` reject unsafe
storage or incompatible metadata where C requires caller guarantees. Structural
preconditions remain the caller's responsibility in release builds. Failure
may leave a computed prefix and changed workspace; it is not transactional.
Do not solve from a failed or partially updated factor. Sparse success with a
reduced rank denotes C-style regularization, not positive definiteness of the
original matrix or an exact solve for its original unregularized coefficients.

## Verification and remaining work

The checked and release builds are compared with the stock MuJoCo library.
Sparse solve is not exported by that library, so the harness extracts its exact
body from the pinned source and compiles it with the original AVX header.
Residual and reconstruction checks against NumPy cover the C results; agreement
with SPARK is checked separately. Tests exercise empty and diagonal matrices,
random sparse graphs with fill, dense patterns, hybrid bands, wide padding,
multiple RHS vectors, regularization, downdates and storage rejection paths.
These tests are neither universal equivalence proofs nor performance evidence.

GNATprove starts at a minimal scalar subprogram and then analyzes all three
complete units. The scalar equations, pivot clamp/root composition and copy
with preservation have functional contracts. Array safety, ordered reduction
models, structural preservation and composition must remain separate claims.
The whole matrix algorithms still have open proof obligations; do not label
them Gold or treat solver timeouts as mathematical Silver exceptions. The three
implementation packages remain in SPARK; no assumptions or suppressed checks
are used. The I/O test driver is outside the proof scope. Runtime elementary
square root is the standard library contract boundary; a numerical error or
stability bound relative to ideal real arithmetic is not proved here.

See [verification-results.md](verification-results.md) and the source-hashed
JSON evidence for the exact current counts and remaining obligations.

Remaining integration work: close the listed obligations, add ordered reduction
and factor/solve composition models, prove preconditions at actual dynamics or
solver callers, then benchmark equivalent integrated movement against C's
normal SIMD paths. These new routines are not on the measured smooth call path;
this addition establishes no improvement or parity for that pipeline.

## Reproduce

Use GNAT/GNATprove 16.1 and gprbuild 26, with the tools on `PATH`.
Python tests require NumPy and the MuJoCo 3.14.0 package plus a C compiler.

```sh
gprbuild -P checks.gpr -j2
gprbuild -P checks.gpr -XCHOLESKY_SB_MODE=release -j2
python tests/compare_reference.py
python tests/proof_inventory.py --begin
gnatprove -f -P checks.gpr -u mj-cholesky_arithmetic.adb mj-cholesky_band.adb mj-cholesky_sparse.adb \
  --level=2 --timeout=5 --memlimit=1000 -j4 --prover=cvc5,z3 --counterexamples=off --report=all
python tests/proof_inventory.py
```

The default build root is `/var/tmp/sparkling-cholesky-sparse-band-20260930`.
Override it with `CHOLESKY_SB_BUILD_ROOT` and the scripts' `--build-root` option.
Compiler flags and selected sources are in [checks.gpr](checks.gpr).
Checked builds execute contracts, overflow and validity checks; release builds
disable assertion checks, with `-O3 -march=native -gnatn -flto` and preserved
floating-point evaluation order. Build artifacts stay outside the repository.
