# Phase proof closure and redundant phase-entry scans

This experiment starts from the integrated pose-tree work, not from the older
Git HEAD. See `baseline-sha256.json` for the frozen input source hashes.

The private mass assembly phase requires `Is_Ready` on entry. Its former
`Phase_Ready` branch is replaced with a proved Static assertion. The public
mass API checks `Is_Ready`; the internal pipeline calls the proved
`Update_Poses` first and exits on failure. No mass-result postcondition is used
to justify removing the guard of a later phase.

The remaining checks and fallback/rejection policies are retained. Proofs of
selected callsites establish those obligations only; they do not establish
whole-caller or whole-dynamics correctness. Timeouts and unproved checks remain
pending engineering work, not a mathematical exception to Gold.

The accepted change also splits the guarded actuation entry from `Compute_Ready`.
Both retain the original functional/frame contracts, and the complete unit is
checked after the fragments. This preserves the successful readiness needed
by `Solve_Acceleration`, whose public boundary already checks readiness.
Only its redundant entry guard is removed; freshness, total-force bounds,
solver policies and Euler's guard remain. These local proofs remain under the
existing stable-layout/configuration contracts; the full preceding mass and
force implementations are not thereby proved.

See [the complete scope and results](../../docs/phase-closure.md).
