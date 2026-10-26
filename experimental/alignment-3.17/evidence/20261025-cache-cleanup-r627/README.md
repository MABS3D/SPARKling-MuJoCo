# Completed-run cache cleanup after host-space exhaustion risk

A full Cross movement trial was explicitly interrupted when C: had about 65 MiB
free. Its partial outputs remain local, and it is not counted as a completed
30-scenario acceptance run. A new full trial uses unchanged binaries after cleanup.

Only compiler/prover obj caches from completed, explicitly archived task runs
were removed: 21 recent directories plus 34 directories included by the r605
checkpoint, totaling 763,409,976 bytes. Sources, copied SPARK receipts, logs,
executables and raw numerical/performance outputs remain intact. No toolchain,
other project, unmatched old directory, active process or stored payload was deleted.

Three ignored raw ZIP duplicates totaling 379,618,821 bytes were removed from
Windows after full exact-store verification passed all 27 archives and 168
inventory files. Their original compressed bytes remain reconstructable without
recompression through tools/evidence_store.py restore. Recipes and payloads are
unchanged by this deletion; all original archive SHA-256 values remain recorded.

After cleanup C: reported about 743 MiB free. Linux cache deletion makes existing
VHDX filesystem blocks reusable; it does not establish equal Windows physical-byte
recovery. WSL was not stopped and the image was not compacted. The earlier audit
and its separate 2.735 GiB cleanup remain historical evidence, not this operation.
