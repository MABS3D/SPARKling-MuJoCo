# Solver support fusion, 2026-10-24

The solver gathers ascending numerical support while performing its existing
M/J numeric admission checks. Sparse transpose sizing without native CSR sums
row widths instead of scanning J again. Public input checks and FP arithmetic
order remain unchanged; metadata is prepared earlier in local storage.

Support_Prefix, Support_Unfold and Support_Total close 10, 8 and 18 scoped
checks respectively, including the exact ordered integer sum and its bound.
Recursive-model warnings remain visible (`passed=false`,
`obligations_closed=true`). These local proofs do not close Solve_With_Force,
caller preconditions, or global solver correctness.

The frozen validation build passes 428 dense, 428 sparse fallback and 432 native
CSR differential cases against historical C 3.15.0. Robustness passes 240 stress
cases, 240 deterministic replays and five capacity boundaries; Cholesky edges
also pass. Runtime checks remain enabled. The initial build log records missing
probe fixtures in the older check.py source selection; the completed-input
build includes every project-listed test source and succeeds.

No new integrated movement timing, 3.14 regression or 3.17 alignment claim is
made at this checkpoint. Performance benefit and complete integration renewal
remain pending.

The archive contains the immutable proof source/manifest, scoped proof receipts,
frozen solver runtime sources/project/binaries, numerical results, commands and
drivers. index.json records SHA-256 for every member. Generated build objects
and prover caches are excluded. To reproduce, extract, set the recorded build
root/mode with GNAT16.1 on PATH, rebuild runtime/solvers.gpr, then adapt the saved
driver paths to the extraction location; install MuJoCo3.15.0 for differential
tests. The original absolute paths in receipts identify the actual run.
