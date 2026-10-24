# FLEX single acceleration solve: 2026-10-24

`summary.json` records the exact candidate scope. `archive.json` identifies
`evidence.zip`; `entries.json` gives SHA-256 for every archived file. CRC and
all entry hashes were checked after compression. The archive contains the frozen
440-file source closure, C 3.14 corpus/outputs, build commands/logs, and the
unsuccessful minimum proof, including its raw diagnostic. Build objects and
binaries are excluded; numerical receipts identify their exact hashes.

Extract `evidence.zip` to recover `snapshot/source` and its source manifest.
The snapshot records production-reference adaptations; replaying the comparison
requires the official C 3.14 Python wheel, GNAT/GPRbuild, and the recorded
validation build options. Original commands and environment-specific paths are
retained in `snapshot/commands.json`; adjust only output/toolchain paths when
replaying. The ordinary repository builder remains
`experimental/alignment-3.15/tests/build_flex.py --production-regression`, with
a compatible C 3.14 foundation.

The minimum can be rerun from the repository using
`experimental/smooth/tests/prove_prepare_forces.py --engine <snapshot>
--out <fresh-output> --subprogram Prepare_Forces_Ready`. The recorded attempt
failed before generating verification conditions at `mj-data-pipeline.adb:455`:
a composite local before a loop invariant is unsupported by this GNATprove
front-end. This receipt does not establish the new stage contract.

C 3.15 and C 3.17 runtime acceptance for this patch remain pending. No release
timing was run after this change and no speedup is claimed.
