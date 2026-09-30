# Dense Cholesky — experimental candidate

`MJ.Cholesky` translates MuJoCo 3.14.0, revision
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, dense
`mju_cholFactor`, `mju_cholSolve` and `mju_cholUpdate`.
The stable release was rechecked on 2026-09-30. See [NOTICE](NOTICE).

- `Factor (A, N, Minimum, Rank, Result)`: lower-triangle factorization, clamped
  deficient pivots, rank count and zeroed deficient columns.
- `Solve (A, X, N, Result)`: in-place forward/backward substitution.
- `Update (A, X, N, Plus, Rank, Result)`: rank-one update/downdate, destructive X.

Storage is zero-based row-major; N is 0..11585. Upper entries are preserved.
The four-lane dot recurrence and tail use C's operation order, with FMA disabled.
No allocation or ghost array copy occurs in executable kernels. The candidate
is separate from the dynamics LDLT inertia solver.

## Numeric domain and API change

Factor/Solve require input magnitudes <=1e100. Update requires magnitudes
<=1e150, including its destructive workspace. Solve/Update input diagonals
must be >=mjMINVAL; Minimum is mjMINVAL..1e60.
These are caller obligations, not properties implied by matrix shape.

The new `Result` is `Success` or `Numeric_Limit`. Growth beyond the documented
operand/storage domains stops explicitly and leaves a bounded partial result.
Only Success permits using the completed operation. C may continue with finite
values outside these domains; this intentional difference is tested. Update
checks narrow operand domains only when an entry uses them, preserving the
large final values in the clamped differential cases.

The default checked build retains checks. Release builds omit assertion/range
checks but retain explicit numeric-limit branches. Those branches add measurable
cost. The current candidate has not met integrated performance parity.

## Evidence and reproduction

All current contracts close in fresh complete-unit proofs: 676 proof obligations
plus 93 flow/termination checks, with no skipped proof or pragma Assume.
This proves the listed functional/integrity properties under the explicit
preconditions; it does not prove general real-arithmetic LLT identities or a
complete end-to-end solver model. See [verification.md](verification.md).

With GNAT/GPRbuild/GNATprove available:

```sh
. tools/env.sh
python3 tools/prove.py new-models ALL --unit mj-cholesky_models.ads
python3 tools/prove.py new-steps ALL --unit mj-cholesky_steps.ads
python3 tools/prove.py new-algorithms ALL
# Diagnose the smallest subprogram first:
python3 tools/prove.py new-factor Factor_Column Factor

gprbuild -f -p -P checks.gpr -j2
python tools/compare.py --output /tmp/cholesky-numerics.json
```

Comparison requires NumPy and MuJoCo 3.14.0. Override CHOLESKY_BUILD_ROOT and
pass --probe/--binary when using a different build directory. Frozen sources,
commands and reports are linked from the verification document. Historical
reports are retained and refer only to their own source snapshots.
