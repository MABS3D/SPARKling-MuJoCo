# Direct compact mass: first prototype, not enabled

A subsequent [canonical-storage retry](compact-mass-retry.md) found faster
isolated candidates. Their runtime integration remains pending proof closure;
the negative results below describe the first prototype only.

The active movement pipeline still assembles a dense mass matrix and packs its
ancestor rows for the compatible solver. The direct compact integration tried
on 2026-09-26 was reverted after it slowed the integrated multi-DOF workloads.
No compact-mass speedup is claimed.

The prototype follows MuJoCo 3.14.0 `mj_crb`: accumulate composite inertias,
project each DOF against its ancestors, and store only the ancestor row.
It reused the prefix of the existing mass allocation, added a format flag,
copied that prefix into factor storage, and expanded dense public queries on
demand. Strict policy and fallback assembly remained dense.

Two independent 24-block sessions against commit
`bf265c8f544e8e151c62a30634cd1d44ea613c3d` showed roughly **1–14% longer step times**
on the multi-DOF cases. For example, the 24-DOF star slowed by 6–7%, mixed simple
DOFs by 13–14%, and the 24-DOF chain by 1–2%. The results include uncertainty and
must not be dismissed as noise or offset by counting individual kernel wins.
Specialized and inline variants recovered part of the loss but did not establish
a broadly beneficial replacement. Fewer memory entries alone were insufficient.

Disassembly showed that the initial combined dense/compact procedure stopped
being inlined. Phase-clock instrumentation also identified increased CRB cost;
those instrumented times are diagnostic, not release performance measurements.
The rejected prototype's complete inputs, source, numerical tests, path counts,
proof diagnostics and paired timing sessions are preserved under
`tests/movement_performance/compact_mass/evidence`.

`MJ.Compact_Inertia` remains an isolated, unused building block: exact rounded
row projection, an explicit rejection witness, constant-time structural lookup,
and symmetric dense expansion with frame properties. Its archived complete-unit
proof closed 149 checks. The helper has since been extended to whole-buffer
operations: the retry records a fresh complete-unit proof of 185 checks. This does **not** prove the full physical mass
algorithm. Two prototype assembly size/publication proof checks were still open
when the runtime integration was rejected; their failed results remain archived.

Checked prototype validation passed 624 scenarios and 168,192 comparisons per
policy against MuJoCo, plus structural cases including 256 independent DOFs.
This establishes tested numerical compatibility within the supported scope,
not universal equivalence or performance parity. The active pipeline keeps its
one full readiness check and three mutable readiness checks per successful step.

The accepted performance work for this iteration is documented separately in
[bounds-validation-performance.md](bounds-validation-performance.md).
