# Compact ancestor factors (2026-09-25)

This is the recorded ancestor-factor stage. The subsequent [six C-path
optimizations](c-parity-six.md) add simple-DOF pruning and four-lane reduction;
the historical results below describe the earlier source snapshot.

This change implements the ancestor-row structure of MuJoCo 3.14.0's
`mj_factorI` and `mj_solveLD` in the experimental scalar-joint `Compatible`
solver. It is an incremental solver change, not a claim that all simulation
storage or the complete dynamics proof has been converted.

## Representation and C correspondence

`MJ.Ancestor_Rows` builds an owned, immutable index pattern once in `Create`
from the validated model's `dof_parentid`. A row contains the DOF's ancestors
in increasing order, followed by its diagonal. Row offsets delimit a packed
array. The row of an ancestor is the matching prefix of the descendant's row;
there is no sparse intersection search and no numerical drop tolerance.

The C reference is pinned to commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. See
`mujoco/src/engine/engine_core_smooth.c`, `mj_factorI` and `mj_solveLD`, and
`mujoco/src/engine/engine_io.c`, `copyM2Sparse`.

The factorization visits rows and their ancestors in reverse order. Each
update uses the existing proved contiguous `Add_Row`, then `Scale_Row`.
Substitution only visits stored ancestors. Rows containing the full leading
prefix retain SIMD `Add_Row` for the transpose solve, direct column indexing,
and the proved triangular row address `i*(i+1)/2`. The forward reduction
keeps the prototype's ordered floating-point accumulation. This does not
assert universal bitwise equivalence with the C SIMD sparse dot product.
The pivot floor, sticky first-clamped diagnostic, work limits, and physical
state failure behavior are preserved. `Strict` retains its dense factor and
condition policy.

The new pattern deliberately includes **all** ancestors. It does not copy C's
`dof_simplenum` row pruning, which is outside this prototype's implemented
optimizations. The new fixtures have fixed leaf children to exercise C's
corresponding general path.

| 24-DOF topology | Dense factor entries before | Packed factor entries | Scalar factor updates before → now |
| --- | ---: | ---: | ---: |
| Chain | 576 | 300 | 2,300 → 2,300 |
| Four branches | 576 | 102 | 2,300 → 203 |
| Four independent chains | 576 | 84 | 2,300 → 140 |
| Star | 576 | 47 | 2,300 → 23 |

These are structural operation/storage counts, not measured speedups. A serial
chain still has a full lower triangle and cubic factorization work. Counts
refer to the active factor: the dense public mass and dense `Strict` scratch
are still allocated. Total simulation memory has not been reduced by these
amounts. The dense mass is packed before each compatible physical solve,
including the implicit-damping solve when required. `Copy_Matrix` transfers
all structural entries in one call, avoiding one `memmove` per short row.
Its `No_Inline` boundary prevents repeated buffer-descriptor loads in the
large simulation-level routine; its exact element mapping is proved.

## Formal scope

The entire new `MJ.Ancestor_Rows` unit closes **758 proof checks**, including
functional properties, with no unproved obligations in the recorded run:

- exact construction from the parent map, row offsets, lengths, diagonal,
  ordered columns, parent-prefix values, and ancestor row lengths;
- preservation of prior rows while appending a row;
- the private type invariant, default state, construction and destruction;
- exact dense-to-packed row copying, including nonzero target lower bounds;
- exact complete-matrix packing, output bounds, and the direct address for
  full leading prefixes.

The representation invariant is proved and the arrays do not escape through
the interface. There is no unchecked readiness flag replacing the existing
simulation guards. The private pattern may be mutated only by construction
and destruction; the established modeled `Free_Int` boundary is reused.
The existing `Add_Row` / `Scale_Row` functional kernels are unchanged.

The historical `Original_Ready` ghost predicate remains frozen. Its
compatibility lemma now explicitly requires the additional ancestor storage;
it does not assert that an arbitrary old object already has the new buffers.
Selected scratch allocation, clearing, freeing and historical-readiness
compatibility helpers close 24 + 85 + 1 + 1 checks on the unchanged `MJ.Data`
source. The expression-only storage query emitted no proof checks and is not
counted as a proof pass.

Full physical assembly/solver/lifecycle proofs remain experimental. The final
bounded diagnostic has 5 open checks out of 17 in `Load_Ancestor_Factor` and
50 out of 112 in `Solve_Compatible`; see the exact proof report for emitted
counts and locations. Open
integration obligations are proof engineering work, not mathematical reasons
to label the new integration Gold or a Silver-only exception.

## Validation

The final checked build passes **552 scenarios / 157,152 comparisons per
policy**, in both `Compatible` and `Strict`, against MuJoCo 3.14.0 with the
established tolerances (`atol=rtol=2e-10`). These compare mass, forces,
accelerations, poses, velocities, positions, and integration outputs, not
only a factor microbenchmark.

The new topology/packing probe checks **5,962 patterns** in checked and release
builds: every ordered parent map through seven DOFs, plus chain, independent
root, star and forest shapes at boundary sizes through 256. Every pattern is
constructed, used and freed twice; invalid parent maps are rejected by the
predicate. Both row and matrix copies are checked against independent parent
walks. The public row copy also uses nonzero target lower bounds.

All **85 pivot-policy cases / 170 scenarios** pass. The checked failure probe
injects synthetic bounded symmetric masses at every stored position in the
first updated ancestor row, verifies `Numeric_Limit`, unchanged physical
state and inputs, invalid acceleration cache, sticky clamp diagnostics, and
successful retry after replacing poisoned scratch. Its complete numerical
run passes all 552 scenarios / 157,152 comparisons.

Replaying the preceding stage's identical input files produces **34 byte-identical
outputs per policy**. This is deliberately a replay: inserting new fixtures
changes the random sequence of later fixtures in a fresh run. Comparing
those different inputs would not be a valid bitwise check.

## Whole-step performance

Two separate sessions, each with 24 balanced process-order blocks, three
initial states per model, 4 samples of 100 Euler steps and two warmups,
CPU 12, frozen previous Ada / current Ada / native SIMD C. Each session has
1,728 process runs. No build, proof, or numerical-validation job ran alongside
these final timings. The final proof-only constructor annotations produced a
release executable byte-identical to the measured executable;
`binary-identity.json` records both hashes. The final checked executable was
rebuilt and its numerical/pattern tests rerun. Failure, boundary and replay
probes from the preceding build are retained with their exact source snapshots;
their solver and data sources are unchanged. Compiler versions, flags, binary/source hashes, every
sample, MAD, p95 and paired bootstrap confidence intervals are archived.

Times below are the median of the three per-state time medians, showing the
range across the two sessions. Changes and C ratios are the median of the
three paired per-state ratios, also across the sessions; they are not ratios
of the aggregated time medians. No mixed-workload weighted average is claimed.
Negative changes mean less time than the preceding Ada implementation.

| Model | Previous Ada ns/step | Current Ada ns/step | Paired time change | Current / C |
| --- | ---: | ---: | ---: | ---: |
| 1 DOF | 619.3–624.9 | 613.7–623.5 | -0.85–-0.56% | 1.419–1.433 |
| 5 DOF, branched | 1891.4–1893.1 | 1922.4–1934.9 | 1.84–2.35% | 1.931–1.942 |
| 12 DOF, chain | 4650.2–4738.4 | 4813.5–4857.3 | 1.90–2.60% | 2.298–2.316 |
| 6 DOF, no damping | 2294.2–2298.9 | 2321.8–2325.3 | 1.16–1.49% | 2.439–2.449 |
| 24 DOF, chain | 10373.1–10377.1 | 10753.6–10792.1 | 3.89–3.93% | 2.264–2.268 |
| 24 DOF, star | 14888.4–14893.3 | 12907.6–12917.4 | -13.13–-12.98% | 3.126–3.142 |
| 24 DOF, forest | 10868.4–10924.5 | 9560.8–9605.1 | -12.32–-12.16% | 2.743–2.747 |
| 24 DOF, branches | 10921.5–10955.4 | 9682.1–9747.8 | -11.32–-10.75% | 2.677–2.685 |

Every 24-DOF sparse case has a paired 95% interval below 1 in both sessions.
The 24-DOF chain has an interval above 1 in all six measurements; its regression
is real in this experiment. Some small changes on 1/5/6/12 DOFs have intervals
crossing 1; exact per-case intervals are in `first.json` and `repeat.json`.
There is no multiplicity correction. The observed 11–13% savings on sparse
models do **not** establish general parity with C or erase the chain regression.

Earlier retained experiments document the rejected row-by-row packing version
and the bulk-packing/direct-index iterations. Final claims use only the two
independent 24-block sessions above. The final trajectory outputs also agree
with C within tolerance (maximum absolute error 2.254e-14) and have zero
absolute difference from the previous Ada outputs in all measured cases.

## Remaining work

The packed solver is implemented, but end-to-end compact mass assembly is
not: the public dense mass is still assembled, scanned by readiness and then
packed. Dense `Strict` scratch is also still allocated. Removing those copies
and unused allocations requires coordinated mass-cache/API and lifecycle work.
The remaining solver index/frame obligations also need closure; kernel proofs
and numerical agreement do not close the whole physics pipeline. Performance
parity remains workload-specific work, with the serial-chain regression an
explicit acceptance issue rather than a hidden microbenchmark tradeoff.

Evidence: `tests/movement_performance/ancestor_storage/evidence/`. Reproduce
with that directory's parent `build.py`, `compare.py`, `check_patterns.py`,
`check_failures.py`, `replay.py`, and the existing numerical/policy harnesses.
