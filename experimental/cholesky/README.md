# Dense Cholesky — experimental implementation

`MJ.Cholesky` implements the dense `mju_cholFactor`, `mju_cholSolve` and
`mju_cholUpdate` algorithms from MuJoCo 3.14.0, revision
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd` (`engine_util_solve.c`).
The reference release was checked on 2026-09-28. See [NOTICE](NOTICE) for upstream attribution.

- `Factor (A, N, Minimum, Rank)`: in-place lower-triangular LLᵀ factorization.
  Pivots below `Minimum` are clamped, decrement the returned rank, and zero
  the entries below that diagonal in the column, exactly as in C.
- `Solve (A, X, N)`: forward and backward substitution, replacing the RHS.
- `Update (A, X, N, Plus, Rank)`: rank-one update/downdate, with destructive
  vector workspace and the C pivot clamp at `mjMINVAL`.

Arrays use zero-based row-major storage. Upper-triangular entries are preserved
and ignored. Empty arrays are supported; aliased `A` and `X` are not supported
by the Ada interface. The in-place solve avoids a separate RHS copy.
No heap allocation or whole-matrix validation scan is added to release kernels.
The four-lane dot product preserves C's accumulation and remainder order;
FMA contraction is disabled in both languages.

The default library project retains runtime checks. The separately built
release executable is for measurement and does not imply proof closure.
These routines have **not** replaced the existing dynamics inertia solver,
which has a different storage scheme and LDLᵀ contract. Sparse symbolic/numeric
Cholesky, sparse updates and banded Cholesky are outside this dense delivery.

## Domain and assurance

Dimensions range from 0 to 11585. `Minimum` ranges from `mjMINVAL` to 1e60;
solve/update require positive input diagonals. The scalar proof helpers have
explicit broad magnitude domains (1e100 or 1e150); the dot-product model bounds
its inputs by 1e100. Checked builds reject violations of these domains.
Input shape and positive diagonals alone **do not prove** that every intermediate
value remains inside those domains. Ill-conditioned matrices and repeated
indefinite downdates can exceed them, or overflow even C's binary64 arithmetic.
Composition of these bounds remains open and is not a Silver or Gold result.

See [verification.md](verification.md) for exact proof scopes, numerical evidence
and performance limitations. C comparison is not a universal equivalence proof.

## Reproduce

From the repository root, with GNAT/GPRbuild/GNATprove on PATH:

```sh
# Optional helper for the toolchain layout used on this machine:
. experimental/cholesky/tools/env.sh

gprbuild -p -P experimental/cholesky/checks.gpr -j2
python experimental/cholesky/tools/compare.py --output /tmp/cholesky-numerics.json

# -f is intentional: compiler-switch experiments require a complete rebuild.
gprbuild -f -p -P experimental/cholesky/benchmark.gpr -j2
python experimental/cholesky/tools/benchmark.py --output /tmp/cholesky-performance.json
```

`compare.py` requires NumPy and the MuJoCo 3.14.0 Python package. Override
`CHOLESKY_BUILD_ROOT` to keep objects in a different directory; pass the resulting
executable path using `--probe` / `--binary`. Use `cholesky.gpr` from client projects.

The [proof command log](results/proofs/commands.json) records each complete-unit
invocation and its separate build directory. Run them from the repository root;
nonzero results for the iterative algorithms are expected until the listed open
obligations are closed. `SHA256SUMS` covers the delivered sources and evidence.
