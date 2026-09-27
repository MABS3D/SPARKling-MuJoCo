# Pose-tree refactoring performance

The baseline is `4c6c39f22f9a484ddb09ffc08662fef22c381fe2`. `baseline.json`
verifies the frozen smooth sources in `baseline`. The builder uses the active
repository's unchanged model/kernel sources and verifies the reference C
binary and library against the supplied reference build receipt.

`evidence/build.json` records final inputs and flags. `session1.zip` and
`session2.zip` contain complete measurements and raw timed-process outputs;
`summary.json` summarizes their per-state medians without pooling intervals.
The initial six-block pilots are retained in the external recovery archive.

See [the report](../../../docs/tree-invariants.md) for reproduction, uncertainty,
the remaining C gap and the exact scope of the associated formal proofs.
