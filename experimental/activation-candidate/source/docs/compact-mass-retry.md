# Canonical compact mass retry

The retry produced faster **isolated prototypes**, not C parity. The active
simulation remains on its previous dense mass assembly. Only the standalone
compact helper extensions and their structural tests have been integrated.
Their complete-unit proof closes 185 checks; integration/lifecycle proofs are
still unfinished, so neither prototype is enabled by default.

## Change guided by MuJoCo C

Reference: normal SIMD MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. In
`src/engine/engine_core_smooth.c`, `mj_crb` writes compact ancestor rows and
`mj_factorM` copies that storage directly into the factor buffer.

The new representation is compact for the entire lifetime of the internal mass
buffer, sized from `Ancestor_Rows.Count`. It needs no mutable dense/compact flag
and no policy-dependent format dispatch. The usual CRB path writes directly
into the final mass buffer. Factor preparation copies it directly, avoiding the
dense gather. A dense public query or Strict solve expands into its destination;
the Jacobian fallback assembles in existing dense scratch, then packs once.
The fallback and Strict policy remain supported. Their performance has not been
established by the Compatible stepping benchmark.

The measured prototype follows the C parent walk. The verification candidate
uses the precomputed ancestor columns in reverse order and splits inertia
loading, bounded accumulation and row publication into smaller procedures. The
latter calls exact row-projection/frame contracts. Arithmetic expression order,
rejection limits and existing warnings/deallocators are preserved. Numerical
checks do not establish universal or bitwise equivalence for Strict/fallback.

The earlier mixed-format attempts were slower. Direct writes, fixed format and
inlining recovered their losses; canonical allocation finally established gains.
This is evidence for the combined implementation, not a controlled attribution
to one of those changes. Gains on the one-DOF case cannot be explained by mass
storage size, which is unchanged there; compiler effects also matter.

## Final verification candidate: integrated movement

Baseline: the accepted scan-only candidate, already including the preceding
magnitude-check optimization, not bare `bf265c8f`. Ryzen 7 9800X3D, CPU 12;
GNAT/GCC 16.1; the pinned normal SIMD C reference. Two independent 24-block
sessions, alternating prior Ada/current candidate/C, 11 models × three states,
four 100-step trajectories per process: 4,752 processes, 1,900,800 timed steps.
Numerical checks, builds and proofs completed before these timing sessions.

Positive savings mean faster than the prior Ada version. Ranges are medians
across states and sessions, not confidence bounds. The last column counts paired
95% bootstrap intervals wholly below one; intervals are not multiplicity-adjusted.
C ratios above one mean the candidate remains slower than C.

| Model | Time saved vs prior Ada | Candidate / C | Improved intervals |
| --- | ---: | ---: | ---: |
| `hinge_motor` | 2.3 to 2.7% | 1.17–1.18× | 6/6 |
| `branched_multijoint` | 1.5 to 3.4% | 1.55–1.57× | 5/6 |
| `chain_12` | 1.0 to 1.9% | 1.95–1.99× | 3/6 |
| `crb_no_damping` | 0.5 to 1.4% | 1.99–2.01× | 4/6 |
| `crb_chain_24` | 2.0 to 2.9% | 1.91–1.95× | 6/6 |
| `ancestor_star_24` | -0.1 to 1.0% | 2.54–2.55× | 0/6 |
| `ancestor_forest_24` | 2.4 to 3.6% | 2.22–2.25× | 6/6 |
| `ancestor_branches_24` | 1.3 to 3.0% | 2.20–2.23× | 5/6 |
| `simple_hinges_6` | 1.6 to 1.9% | 2.50–2.52× | 6/6 |
| `simple_sliders_6` | 5.5 to 6.0% | 1.51–1.52× | 6/6 |
| `simple_mixed_8` | 4.2 to 4.6% | 1.64–1.65× | 6/6 |

The star result is compatible with noise; it is not an established improvement.
No final case had an interval wholly above one. The chain at 24 DOF, forest and
simple models show repeatable gains, while several other cases are less decisive.
No average of percentages or count of faster kernels is used as an aggregate
movement result. Raw records retain per-step medians, MAD, p95 and extrema.

Both final sessions produced exactly the same tested trajectory outputs as prior
Ada. Maximum absolute difference versus C was 3.90e-14. This is limited to the
supported fixture set and 100-step trajectories, not a universal accuracy bound.

The less modular first candidate was also measured in two complete sessions:
- `crb_chain_24`: 2.0–3.8% saved.
- `ancestor_star_24`: 0.5–1.3% saved.
- `ancestor_forest_24`: 2.5–4.8% saved.
- `simple_sliders_6`: 6.2–6.8% saved.
- `simple_mixed_8`: 5.0–6.4% saved.

Those figures belong to `measured/`, not `verification/`. The corrected total
symmetry query does not alter its release movement binary: the recorded hashes
are identical. The modular version must be judged using its own table above.

## Validation and proof scope

Both source lanes passed checked differential tests against C under Compatible
and Strict: 624 scenarios and 168,192 comparisons **per policy and per lane**,
including API error cases, tree fixtures and dense fallback cases. The final
verification lane retains one full readiness check and three mutable checks per
successful step, confirmed on 11 models with instrumented/release outputs equal.
No readiness scan was removed by this retry.

The proof effort found a genuine API-contract issue in the first prototype:
`Symmetric_Mass` called `Mass_Entry`, whose precondition requires a current mass.
The symmetry query itself has no such precondition. It now uses structural
lookup directly, and the checked probe explicitly exercises the initial stale,
zero mass. The active simulator never received the incorrect prototype body.

| Proved scope | Closed checks | Meaning |
| --- | ---: | --- |
| Complete `MJ.Compact_Inertia` | 185 | Exact lookup, expansion, projection, rejection witness, clear/store and frame contracts |
| `Load_Composite` | 29 | Exact component copy, initialization and bounds |
| `Accumulate_Composite` | 13 | Safety and preservation of bounds; no full physical/ordered-sum model claimed |
| `Try_Assemble_Compact` in modular snapshot | 26 | Composition preserves bounded output under the called contracts |
| `Allocate_Dynamics` | 22 | Compact allocation, layouts and initial zeros |
| `Get_Mass_Matrix` | 17 | Public dense values and caller array bounds |
| Corrected `Symmetric_Mass` | 4 | Valid structural access without requiring mass freshness |

These are scoped proofs, not a declaration that the complete dynamics is Gold.
The complete helper proof's dependency closure is hash-matched to the active
helper. Other rows refer to the exact snapshots indexed in the evidence archive;
they are not a single whole-program proof. Checked and optimized standalone
tests cover empty/singleton/chain/star/forest/256-DOF patterns and whole-buffer
projection, rejection and unchanged surrounding entries.

Still pending before enabling either integration:

- Close the `Assemble` publication and preservation obligations; the latest
  selected attempt timed out after 300 seconds and proves nothing about closure.
- Close `Load_Ancestor_Factor` bounds and state-frame obligations.
- Finish lifecycle proof revalidation (`Initialize`, `Create`, `Reset`). Latest
  attempts leave obligations open; see exact budgets and diagnostics in the index.
- Revalidate affected complete units after those leaf/interface fixes, then
  rebuild and repeat integrated timing if generated code changes.

These are unfinished proof-engineering tasks, not documented mathematical
exceptions allowing a Silver-only completion claim. The active stepping path
is intentionally unchanged while the new representation remains experimental.
Dense-query expansion also introduces work at that API boundary; the timing
above covers a dynamics/integration step, not repeated dense mass queries.

## Reproduction and evidence

`tests/movement_performance/compact_mass_retry` contains two reviewable source
sets and patches, a hash-checked builder, passing numerical/structural results,
failed and passing proof snapshots, rejected pilots and both final timing pairs.
Its [README](../tests/movement_performance/compact_mass_retry/README.md) gives commands.
`measured` and `verification` results are deliberately named separately.
No commit, merge or GitHub publication was performed for this retry.
