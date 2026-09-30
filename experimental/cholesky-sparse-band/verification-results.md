# Verification results — 2026-09-30

Reference: MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
The source-hashed reports below correspond to the current six implementation files.

## Differential and numeric checks

| Build | Tests passed | C comparisons | Boundary expectations | Bit-identical outputs |
| --- | ---: | ---: | ---: | ---: |
| validation | 1731 | 1724 | 7 | 1731 |
| release | 1731 | 1724 | 7 | 1731 |

Exact comparison uses the uint64 representation of binary64, including the sign of zero.
Both profiles use the same 1,731 cases. C sparse solve uses the extracted upstream body with its normal AVX header.
There are also 974 independent residual or factor-reconstruction checks on reference outputs;
SPARK output is compared with those outputs separately. Seven cases per profile use explicit expectations
for empty inputs and our additional numeric, pattern and capacity rejection paths.
See [differential.json](evidence/differential.json) for families, versions, seed, hashes and platform.

## Formal checks

GNAT/GNATprove 16.1.0, gprbuild 26.0.0, cvc5 1.3.2 and Z3 4.15.4.
Diagnosis started with `Add_Product`; the final run selected all three complete implementation units,
forced fresh analysis with `-f`, used level 2, 5 seconds per goal, 1000 MiB per prover and four workers.
All implementation bodies are in SPARK. No proof/flow skips, pragma assumptions or suppressed checks were used.
The standard elementary square-root contract is a runtime-library boundary.

| Unit | Proof checks closed | Proof checks open | Flow obligations open |
| --- | ---: | ---: | ---: |
| `arithmetic` | 93 | 0 | 0 |
| `band` | 258 | 9 | 0 |
| `sparse` | 400 | 36 | 0 |

These counts are verifier checks, not a percentage of functional correctness or of MuJoCo coverage.
A proved check can still depend on an invariant or called contract whose own proof is open.

| Subprogram with open obligations | Closed checks | Open checks |
| --- | ---: | ---: |
| `MJ.Cholesky_Band.Factor` | 68 | 3 |
| `MJ.Cholesky_Band.To_Dense` | 42 | 4 |
| `MJ.Cholesky_Band.From_Dense` | 33 | 2 |
| `MJ.Cholesky_Sparse.Factor` | 79 | 7 |
| `MJ.Cholesky_Sparse.Numeric` | 56 | 9 |
| `MJ.Cholesky_Sparse.Solve` | 32 | 2 |
| `MJ.Cholesky_Sparse.Update` | 41 | 2 |
| `MJ.Cholesky_Sparse.Symbolic_Count` | 31 | 7 |
| `MJ.Cholesky_Sparse.Symbolic_Fill` | 67 | 9 |

Gold is closed for the local functional contracts of `Add_Product`, `Multiply`, `Divide`, `Root`,
`Factor_Pivot` and `Copy`: exact successful binary64 expressions, pivot clamp/root composition,
or exact copy with preservation of untouched entries. No whole-matrix Gold claim follows from these results.
Dot and sparse dot safety checks pass; their full ordered functional models are still missing.
Band solve/multiply checks pass under their stated contracts, but full solve/product relations remain to be specified and proved.
Sparse merge buffers use `Relaxed_Initialization` with a proved initialized-prefix invariant;
this avoids adding a full zero scan to merge scratch and is not a trusted initialization assumption.

Remaining work includes elimination-tree invariants and counts, fill-merge structural preservation,
transpose-map access bounds, band-address/frame composition, and full ordered factor/solve models.
These are unfinished proof-engineering tasks, not documented mathematical exceptions permitting Silver-only completion.
The scalar-domain restrictions and numeric rejection behavior are described in [README.md](README.md).

The source-hashed [proof inventory](evidence/proof-inventory.json) lists exact locations and rules.
The [full-unit log](evidence/complete-units.log) and [minimal-subprogram log](evidence/minimal-final.log) retain diagnostics.

## Reference scratch-contract observation

The pinned C numeric routine does not initially zero scratch, despite its header saying contents are ignored.
For a 3x3 zero source with an implicit diagonal and a diagonal symbolic pattern, zero scratch produces
rank 0 and diagonal `3.162277660168379e-8`; scratch initialized to 3.75 produces rank 3 and diagonal
`1.9364916731037085`. Both leave scratch zero on return. The SPARK routine explicitly clears scratch
and therefore returns the documented zero-source result for either initialization. C comparisons use zero scratch.
Inactive factor padding is preserved; missing source diagonals and empty source rows are supported.

## Integration and performance

This is a standalone experimental addition. No production dynamics call site was changed.
No integrated movement or performance comparison has been run for these new routines.
There is no claim of C performance parity or of a smooth-pipeline speedup.
Caller proofs and representative integrated benchmarks remain required before kernel acceptance.
