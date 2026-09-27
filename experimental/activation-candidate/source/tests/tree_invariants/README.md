# Pose-tree verification evidence

See [scope, results and reproduction](../../docs/tree-invariants.md).

- `evidence/proofs.zip`: five disjoint proof groups, 1,617 proof checks and
  184 flow checks. The motion caller retains one unused-output warning.
- `evidence/source-map.json` and `source-objects.zip`: exact source snapshots
  indexed by SHA-256; `proof-continuity.json` checks unchanged proved bodies.
- `evidence/numerics.zip`: final Strict/Compatible checked comparisons, raw
  outputs, checked compiler project and build log.
- `evidence/build.json` and `integration-receipt.json`: compiled inputs and
  executable hashes, including the exact match to integrated source files.
- `numerical`: mathematical derivations and replay inputs. Earlier sections
  of `tree-error.md` are superseded as described by `accepted-product.md`.
- `evidence/arithmetic-certificates.zip`: six Gappa and ten SMT replay results.
- `fixtures` and `null-array-witness`: additional differential cases and the
  empty-array representation witness.

These results do not prove the full simulator, all callers of strengthened
readiness, or universal numerical equivalence to C. Repeated and unsuccessful
attempts in the external recovery archive are not added to the check totals.
