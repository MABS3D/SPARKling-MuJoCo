# Dense Cholesky verification — 2026-09-30

The current contracts close for all three candidate units. Scope is runtime
safety and the explicit functional/integrity properties below. This is not a
full MuJoCo simulation proof, a universal C-equivalence theorem or performance
acceptance for integrated movement.

## Formal results

| Complete unit | Proof obligations | Flow/termination checks | Open |
| --- | ---: | ---: | ---: |
| MJ.Cholesky_Steps | 43 | 14 | 0 |
| MJ.Cholesky_Models | 132 | 15 | 0 |
| MJ.Cholesky | 501 | 64 | 0 |
| Total | 676 | 93 | 0 |

[Machine-readable coverage and warnings](results/formal-status-20260930.json).
Reports and matching frozen-source manifests:
[scalar steps](results/proofs/current-20260930-steps/ALL-summary.txt),
[dot models](results/proofs/current-20260930-zero-models/ALL-summary.txt),
[algorithms](results/proofs/current-20260930-full/ALL-summary.txt).
Each directory includes ALL.spark.json, manifest.json, source/, the command
log and solver output. GNATprove 16.1.0, CVC5/Z3/Alt-Ergo, per_path, 10 seconds
per attempt, 512 MiB per prover, two workers. No pragma Assume, skipped proof,
suppression or new trusted project body was introduced. Reviewed warnings
remain visible in the reports.

Proved functional scope:

- Exact ordered binary64 product, bounded scalar arithmetic, pivot clamp/root,
  lower entry update, signed update and destructive vector update.
- The recursive four-lane sum, C lane combination/tail, and production Dot
  equality to that rounded model, including zero operands.
- Factor preserves upper entries, bounds every stored/partial result, keeps
  rank within 0..N, and produces diagonals >=mjMINVAL on Success.
- Solve bounds successful/partial results and maps a zero RHS to a zero
  solution with Success. Its scalar subtraction/division contracts are exact.
- Update preserves upper entries and X(0), bounds arrays and rank, preserves
  positive diagonals on Success, and is an exact no-op for a zero vector.
- Local cell contracts give exact entry formulas and unchanged-cell frames.

The root relation uses the existing elementary-function contract; no new
correct-rounding theorem is asserted. A global functional model mapping every
nonzero RHS to the final solver vector, and general matrix reconstruction/error
bounds, remain outside this proved scope. These missing models are engineering
work, not a mathematical Silver exception. The scoped results above should not
be promoted to a claim of complete functional correctness for the solver.

## Numeric-limit handling and differential tests

Shapes/positive pivots alone do not bound ill-conditioned intermediates. The
new explicit Result parameter replaces potential out-of-domain stores with
Numeric_Limit, leaving bounded partial arrays. Factor/Solve use storage <=1e100;
Update uses storage <=1e150, narrower operands where the scalar formulas require
it, and positive input diagonals >=mjMINVAL. Only Success denotes completion.
C can continue outside those supported domains; the API documents that difference.

Both checked and release probes pass 1,233 C differential cases and 1,682,539
scalar/rank comparisons each, with zero numerical differences in the sample.
The maximum independently checked relative reconstruction residual is
1.8643e-15. Additional six cases per build cover Numeric_Limit, partial bounds,
unchanged upper entries and zero-input behavior at extreme admissible inputs.

[Checked comparison](results/numerics-20260930-validation.json),
[release comparison](results/numerics-20260930-release.json),
[checked edge cases](results/edges-20260930-validation.json),
[release edge cases](results/edges-20260930-release.json).
Tests cover N=0..17,24,32,64,96,128; SPD/clamped inputs, solve, update/downdate,
threshold neighbours, scales, sparse/zero update vectors, and zero RHS.
These samples do not establish universal equivalence or general stability.

## Performance after the proof changes

Normal MuJoCo platform SIMD C; O3/native ISA/LTO, FMA contraction disabled in
both languages. Nine alternating paired samples on one logical CPU; preparation
and checksums are outside timed regions. The shared host adds uncertainty.
[Raw measurements, source/binary hashes and intervals](results/performance-20260930.json).

Ratios are Ada time / C time. The cycle is factor, solve, update, solve;
it is an algebra workload, not integrated movement.

| N | Factor | Solve | Update | Downdate | Cycle | Cycle 95% interval |
| ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 2.699 | 1.816 | 0.690 | 0.765 | 1.742 | 1.489–1.928 |
| 3 | 1.332 | 1.146 | 0.990 | 0.968 | 1.057 | 0.973–1.187 |
| 6 | 1.294 | 1.054 | 1.022 | 1.175 | 0.905 | 0.783–1.032 |
| 12 | 1.288 | 1.064 | 1.642 | 1.271 | 1.063 | 1.000–1.321 |
| 24 | 1.681 | 1.062 | 1.895 | 1.920 | 1.314 | 1.230–1.507 |
| 48 | 2.643 | 1.212 | 3.108 | 2.927 | 1.917 | 1.732–2.108 |
| 96 | 2.184 | 1.515 | 4.057 | 4.083 | 2.459 | 2.273–2.906 |

The new explicit numeric guards are executable and the larger cases regress.
At N=96 the measured cycle takes about 2.46x C time; this candidate is not ready
for performance acceptance. Small cases have wider intervals; no general parity
claim follows. Historical timings describe older source versions and do not
apply to this one. Next performance work is to prove a sufficient stage bound
and hoist redundant entry checks, followed by an equivalent integrated workload.

Checked/release/benchmark build logs are in results/*-build-20260930.log.
The candidates remain separate from active dynamics. Source/evidence hashes
are recorded in results/manifest-20260930.json.
