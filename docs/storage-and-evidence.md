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
requiring space for the selected original bytes. It skips matching files and refuses
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

## Follow-up: completed caches and raw ZIP duplicates

2026-10-26: a Cross timing run was explicitly interrupted after the Windows
volume fell to about 65 MiB free. Its partial outputs are preserved and do not
stand for a completed 30-scenario acceptance run. The replacement run uses the
same executable hashes after cleanup, with no overlapping heavy task work.

The follow-up removed 55 generated `obj` directories from this task's completed,
archived runs: 763,409,976 bytes (about 728 MiB). Frozen sources, copied SPARK
reports, logs, executables and raw measurements remain. Other projects,
toolchains, active work and unmatched older directories were left intact.

Full exact-store verification passed 27 archives and all 168 then-current
inventory entries before deleting three ignored raw ZIP duplicates: r556,
r605 and r620, totaling 379,618,821 bytes (about 362 MiB). Every original ZIP
byte remains reconstructable with `restore`; existing recipes and payloads
were preserved. The new audit receipts are additional inventory entries.

After cleanup, Windows reported about 743 MiB free. Reusable Linux filesystem
blocks do not establish equal physical Windows-byte recovery. WSL was not
stopped and the VHDX was not compacted.

[Exact removal lists, preserved inputs and scope](../experimental/alignment-3.17/evidence/20261025-cache-cleanup-r627/README.md).

A subsequent pass, after all timing processes were terminal, removed the
remaining 24 Git-ignored, untracked raw ZIP duplicates (1,337,333,642 bytes),
checking each size, SHA-256 and stored recipe first. All 27 original stored ZIPs
remain losslessly reconstructable; restoring those together would require about
1.60 GiB. Windows reported 2,073,694,208 bytes free afterward. Historical tracked
archives and the exact store are untouched. New checkpoints may add archives;
the store manifest records their current sizes.

[Per-archive duplicate checks and exact restoration scope](../experimental/alignment-3.17/evidence/20261026-exact-zip-cleanup-r629/README.md).


## Completed constructor and force-sum work caches

2026-10-26: after all named proof/build/timing handles completed, the exact
constructor/force-sum checkpoint was packed and all 39 stored archives plus the
full inventory were verified. Twenty partial Why3 session XML reports from the
two timed-out whole-math controls were copied before cleanup; they do not prove
whole-unit completion. The successful full reports and baseline flow traces are
also preserved outside generated caches.

The follow-up removed only 45 generated obj/analysis directories outside frozen
source trees in this task's completed r907-r965 workspaces: 2,361,757,271 apparent
bytes (about 2.20 GiB, measured with du -b). Sources, toolchains, runtime binaries,
other projects and active work were excluded. Linux free blocks do not establish
equal physical Windows-byte recovery. WSL was not stopped; the VHDX was not
compacted or trimmed.

[Exact directory list, copied partial reports and removal receipt](../experimental/alignment-3.17/evidence/20261026-completed-cache-cleanup-r968/README.md).
This cleanup changes no numerical algorithm or verification/performance claim.

## Follow-up: exact ZIP duplicates after rotation/group proof work

2026-10-28: fresh full verification passed65 stored archives and all436
then-current inventory entries before removing35 ignored, untracked raw ZIP
copies. Every size, SHA-256, stored recipe and Git status was checked again
immediately before deletion. Removed bytes total4,588,267,819 (about4.27GiB).
All original ZIPs remain exactly reconstructable through the preserved store.
Sources, unique proof evidence, active caches, other tasks and toolchains were
left intact. Windows free bytes measured1,903,661,056 before and6,579,826,688
after; these are observations alongside concurrent work, not a VHDX compaction
claim. WSL was not stopped, trimmed or compacted.

[Exact removal list and verification receipt](../experimental/alignment-3.17/evidence/20261028-tight-rotation-bounds-and-group-layout-r2198/README.md).
