# Four-lane packed-copy proof and integrated rejection

The private common-domain copy now accumulates four independent maxima, then
combines them and handles the final 1–3 elements. Generic Copy_Row, all public
contracts, rejection domains and other source files remain unchanged. The
initial attempt times out and exposes a Source'Length conversion issue for an
extreme array bound. The final 1753 version divides an Int64 length before
converting to Natural and explicitly unrolls each four-element group.

The final minimum closes 77 checks. Complete Row_Bounds units close 341 on
both reference closures, including exact copy, maximum/witness, packed-row
coverage and frame properties. Warnings remain visible: the minimum has eight
FOR-loop array-initialization precision warnings; each whole unit has 13 total
warnings. Actual initialization obligations close. There are no assumptions,
suppressed checks, new trusted port bodies or changed inline directives.
Counts describe separate scopes and must not be added together.

Fresh bit checks pass 12,336 scenarios in each of the four standard profiles:
0–256 DOFs, chains, independent roots and deterministic forests; signed zeros,
subnormals, work caps and their predecessors, maxima in every lane, random data,
all remainder classes, copied bits, source preservation and untouched guards.
The oracle is the unchanged proved sequential Copy_Row. Test-only bit conversion
is outside the SPARK port. Both-reference/profile activation/integration and
all 30 actual movement endpoints also pass; Ada endpoints match the original
baseline exactly and native C uses the unchanged 2e-10 oracle tolerance.

Disassembly confirms four independent scalar maximum accumulators. It also
retains checked index arithmetic; no vectorized maximum or speedup is inferred
from source structure alone. Six-replica full-30 diagnostics use unchanged
baseline1319, candidate1753 and native C3.17 SIMD/LTO, fixed inputs/forces and
balanced orders, with all own heavy jobs idle. Raw outputs and uncertainty are
preserved. The candidate is slower than published Ada by 8.15–8.77 percent on
free_ball, 6.24–6.90 percent on chain_24, and 5.48–5.65 percent on branches_24.
Their per-state 95-percent intervals are above parity. Lower medians on ball,
free and fixed_tendon have intervals including parity, so they do not establish
speedups. No aggregate percentage average or faster-case count is an acceptance
metric. Relative to native C, the candidate remains about 1.63x, 1.95x and 1.55x
on those three models respectively.

The candidate is not adopted. Formal qualification also remains false: three
existing configuration/state obligations in the actual caller remain open.
The unchanged caller's earlier partial receipts retain their original bindings;
fresh whole Row_Bounds reports establish the unchanged callee contracts only.
Production numerical code is unchanged. Full port, coordinated latest migration,
whole dynamics/factorization Gold and parity with C remain unfinished. A plan
for tighter pose-producer bounds is archived explicitly as unimplemented work.
This checkpoint is local. Exact ZIP bytes can be reconstructed using the store.
