# Accepted friction response evidence — 2026-10-02

`proof-summary.json` records all three fresh complete-unit runs. The raw
`.spark.json` and logs are copied here, with source hashes in `sources.json`
and tool versions in `versions.json`. The source hashes cover the candidate,
its test scripts, project file and the two root scalar specifications.

All 539 checks close without warnings, skipped proofs, assumptions introduced
by this candidate, or missing declared subprograms. Proofs cover the stated
functional contracts; this is not a full C-equivalence or convergence proof.

`tests-summary.json` records both checked and release runs (2,096 cases each),
90 native solver systems, exact force and iteration comparisons, compiler
commands and native-library/oracle hashes. C supplies assembled AR/b for those
solver comparisons. Contact assembly, acceleration projection and mj_step
integration are outside this candidate.

Reproduce using `../tests/prove.py` and `../tests/check.py`, as described in the
candidate README. Every run requires a fresh external output directory.
