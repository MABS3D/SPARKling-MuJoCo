# Complete current-contract manifold-copy VC coverage

Copy_Manifold_Joints is adopted with its internal Static body-shape relation,
proved Ghost body-layout projection and Static Qpos validation-prefix invariant.
The exact adopted source is candidate2741, SHA-256
`2b247768281c5b9884a4845124872b2f3b2319101fe136b10f856cfe5f33a977`.

| Disjoint region | Proof VCs per reference |
| --- | ---: |
| Contract and contract-expression safety | 11 |
| Projection calls and allocation | 4 |
| Qpos validation and prefix invariant | 10 |
| Joint reads, group bounds and outer invariant | 13 |
| Quaternion reads | 8 |
| Component updates and inner invariant | 28 |
| Body updates, body-loop invariant and final access | 21 |
| Total | 95 |

A fresh whole-routine inventory contains95 unique
(check_file,check_line,check_col,rule) tuples on each pinned3.17/3.14 closure.
Seven successful complete region runs per reference partition that inventory
exactly: no missing, duplicate or foreign VC. msg_id is filter-local and is not
used as identity. The independent audit checks exact source-manifest hashes,
identical semantic GNATprove options, selected entity, complete representation,
fresh reports, all proof entries informational and no skipped/assumed VCs.
The low-step inventory's successful entries are not needed as proof: all95
are covered by the seven ordinary-resource runs, including every invariant's
initialization/preservation, postcondition and allocation/leak check.

This is complete VC coverage for the routine's current contracts under callee
contracts. The monolithic600-second attempts still time out; this checkpoint
does not turn those runs green or infer progress from stale Why3 cache XML.
Existing reviewed warnings remain and make individual wrapper passed flags
false despite all scoped obligations closing. It does not prove exact copying
of every physical field, complete constructors/Reset/state/dynamics, full
features/ABI alignment or integrated C performance parity.

The production3.14 source closure matches after the already existing build
normalization: two ABI-independent structural helper files are supplied from
experimental/alignment-3.17/src, and the GPR adds the SPARK library directories.
The normalization is checked explicitly rather than silently treating those
three paths as identical. The3.17 closure remains a private reference; no
production ABI/version pin is changed.

The preceding checkpoint retains fresh validation/release native matrices:
528 cases per reference/profile,132 byte-identical outputs versus previous
production, unchanged16 samples/100 steps/2e-10 tolerances, both Ghost helpers
absent from native symbols, exact Static/Ghost erasure and clean whole MJ.Data
flow with the same five modeled deallocators. Those unchanged-source results
are reused; no redundant numerical run or new timing claim is made here.
See ../20261030-body-layout-and-qpos-prefix-proofs-r2755/README.md.

The strengthened internal precondition is established by both constructors on
both references. The prior modular interface audit verifies unchanged caller
text and pre/postconditions after the prefix-only body change. No runtime scan,
record copy, public input restriction, assumption or trusted body is added.
The next functional gap is preservation/mapping of the individual body fields;
the current postcondition covers layout and selected frame properties.

Adopted locally. No commit or push is implied by this checkpoint.
