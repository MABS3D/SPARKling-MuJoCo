# Baseline reproducibility and state proof controls

Rebuilding the published1319 Ada source using the current strict build recipe
produces the exact same executable, SHA-256
`ddad4bf451f092e089bc336bb774216270373cb72aef00f3c8c6391036bbbc62`.
Both files contain2,973,320 bytes; their text sections match too. Source manifests
are identical. The added vendor search paths do not change this result. All30
fresh100-step endpoints equal baseline Ada exactly and satisfy the original
native C oracle at2e-10. No new timing is needed to compare identical binaries.
This rules out a baseline binary discrepancy for this particular rebuild; it
does not rule out code layout or compiler effects between different programs.

The preceding private split separates the legacy solver, restored byte for byte
to1319, from the certified solver. Certified95, legacy86 and composition7 scopes
close on both references with inherited warnings retained. A separate control
outlines only the new composition helper. Fresh numerical and raw six-replica
target9 diagnostics are preserved. Both controls remain slower than published
Ada and are not adopted. Neither combines the earlier common-copy or vector-width
controls, and separate experiment ratios do not measure causal cost fractions.

New state proof experiments add only static ghost facts to1675. The state-view
lemma closes5 checks on both references, with12 inherited warnings retained.
It relates State_Values to State_Image under explicit layout preconditions.
The1739 normal Solve scope closes153 checks but still has the same three open
properties: configuration preservation, Stable_Ready and state-value equality.
The additional image lemma does not establish whole-caller closure. Short Z3
diagnostics and a further opacity control retain their open checks as failures.
The preparation assertion/cancelled1738 run is retained with its actual source
and cancellation reason; it is not counted as verification of a corrected source.

Exact inverse-edit audits establish the static-only source scope of1741; they
are not substitutes for proving its caller obligations. No assumption, warning
suppression, forced inlining, domain restriction or new trusted body is added.
Production numerical code is unchanged. Full state/dynamics Gold, functional
factorization, coordinated latest-version migration, the full port and parity
with native C remain open. This checkpoint is local; no commit or push is made.
Exact archive bytes are reconstructable with tools/evidence_store.py.
