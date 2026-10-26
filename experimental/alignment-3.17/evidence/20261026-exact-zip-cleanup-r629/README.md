# Remaining redundant local ZIP copies

After all movement processes were confirmed terminal, 24 further Git-ignored,
untracked raw ZIP duplicates were removed: 1,337,333,642 bytes. Each raw size and
SHA-256 matched its entry in the fully verified 27-archive store, and each recipe
was checked. Every original compressed byte remains reconstructable by restore.
All tracked historical ZIPs, source, proof receipts, logs, binaries, recipes and
payloads remain. No unique input or active job was removed.

Together with the three earlier removals, all 27 stored raw ZIP duplicates total
1,716,952,463 bytes. Restoring all would need about 1.60 GiB; restore a selected
archive when only one is needed. The operation reported 2,073,694,208 bytes free
on C: afterward. No VHDX compaction or equal physical recovery from Linux cache
deletion is claimed. The 55 completed cache-directory removals are documented
in the separate r627 receipt.
