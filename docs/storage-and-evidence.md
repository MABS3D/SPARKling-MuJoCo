# Storage audit and exact proof bundles

Audit: 2026-10-25. Numerical code and its proof claims are unchanged by this storage work.

## Linux image

The Ubuntu VHDX file measured 207,783,723,008 bytes (193.5 GiB); the roughly
1 TiB shown by Linux is virtual filesystem capacity. Before cleanup, `/var/tmp`
used 154.5 GiB, including 132.9 GiB in SPARKling work directories. Other projects
and toolchain installations were left untouched.

The completed cleanup removed 2.735 GiB from 90 generated
compiler/prover cache directories in this task's recent r410–r467 runs. Frozen
source, manifests, logs, executables and archived proof receipts were preserved;
all 117 published evidence files were hashed before removal. This cleanup does
not claim that Windows recovered the same physical amount or that the VHDX was
compacted. WSL was not stopped and the VHDX was not compacted.

A read-only follow-up found 57.141 GiB in 4,395 older `obj`/`analysis`
directories under SPARKling temporary workspaces. These have not been removed.
The repository's ignored `obj` cache (about 919 MiB) and original proof ZIPs
were also left intact. A broader cleanup must retain any unique proof receipts
and distinguish generated artifacts from inputs before deleting anything.

## Portable archive storage

Twenty new ZIP bundles originally occupy 1,107,247,886 bytes.
The lossless store occupies 676,178,693 bytes including recipes and index
(38.9% less). Its individual payload files are at most 32 MiB.
Existing tracked historical ZIPs are unchanged. The original new ZIP files remain
local and are ignored by Git; their exact portable representation is committed.
No symlinks or archive moves are required.

`tools/evidence_store.py` stores original compressed ZIP payload bytes once,
along with every local header, descriptor, gap and central-directory byte.
Restoration never recompresses a member. Recipes and payloads are SHA-256 checked,
and reconstruction is checked against each original archive digest. All 117
entries of the existing evidence inventory remain unchanged and verified.
This storage check is separate from SPARK proofs, numerical tests and timing.

From the repository root, using Python 3.9 or later:

```sh
python3 tools/evidence_store.py verify
python3 tools/evidence_store.py restore
python3 -m unittest discover -s tools -p test_evidence_store.py
```

`verify` checks every stored ZIP without materializing it, then checks the full
inventory using reconstructed ZIP digests and physical metadata files. `restore`
materializes the exact ZIPs at the paths recorded by the original evidence,
requiring about 1.03 GiB if all are absent. It skips matching files and refuses
to overwrite differing files or existing partial outputs. An optional
repository-relative ZIP path selects only that bundle. Historical ZIP links
inside the evidence refer to these restored local files.

To store a newly created bundle, then stage the resulting payloads and metadata:

```sh
python3 tools/evidence_store.py pack experimental/alignment-3.17/evidence/NEW/NEW.zip
```

Packing appends new immutable payload files and recipes; it reuses known payloads.
Verification rejects an inventory ZIP that is neither stored nor a recorded
Git-tracked historical bundle, preventing ignored new archives from being lost.
Keep the bundle in the evidence inventory and preserve its original SHA-256.
Verification and an actual restoration were performed before this commit.
