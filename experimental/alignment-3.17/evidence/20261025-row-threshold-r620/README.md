# Earlier SIMD dispatch for disjoint factor rows

The actual solver now selects its existing vector row backend at eight elements,
previously sixteen. The reviewed C3.17 mju_addToScl AVX implementation starts at
four. Arithmetic, ordered FP expressions, domains, rejection flags, unaffected
entries and all public contracts remain unchanged. No assumption, suppression,
new trusted production body or deallocator change is introduced.

The minimum closes 40 checks; the full kernel unit independently closes 156 checks
on each exact C3.14/C3.17 dependency closure. Five inherited reassociation warnings
per unit remain explicit; strict warning-free passed is false, while obligations
are closed. Both 14,905-case disjoint-row corpora pass, as do all 13 broader numerical
groups covering validation/release, raw mass, derivatives, reverse layouts, compact
cache and direct CRB. Adopted source manifests match the verified builds exactly.

The full 30-case movement experiment and independent chain24 repeat use six
byte-identical copies per role, 36 balanced blocks, 8 samples, 32 warmups, 100 steps,
CPU 12, normalized argv0 and shared fixtures. Ada outputs match exactly; C outputs
meet the recorded tolerance. C is the normal source-built 3.17 SIMD/LTO reference,
FP contraction off, compiled with the same GCC 16.1 toolchain. Its shared-library
placement is not varied independently across launcher copies. No own heavy jobs
overlap accepted measurements. The initial r611 run was interrupted and explicitly
disqualified because an earlier own Linux Git status process was still scanning.
Its qualification, incomplete outputs and failure record remain available.

Across chain24 states the first median time ratios are 0.98766, 0.98331, 0.98463;
the repeat gives 0.98281, 0.98701, 0.98173. Each 95% interval lies below 1. Other first-run
workload intervals include 1; individual regressions/uncertainty remain in the
summary and raw evidence. These are workload-specific measurements, with no
unweighted aggregate or arbitrary noise allowance. Chain24 still takes about
2.3 times normal C, so overall parity and full MuJoCo completion remain pending.

ELF .text differs in exactly one byte, the dispatch immediate 15 to 7; instruction
addresses/sizes and read-only/writable data match. This is compiler evidence,
separate from formal proofs and timing. The 837-check reduction proof checkpoint
retains its original scope under unchanged called contracts; it was not rerun here.

A further private Cross candidate replaces six intermediate subtype checks by
proved Static bounds. Its minimum closes 86 checks; the whole math unit closes
796, retaining 10/66 existing diagnostics respectively. Both profiles pass 5,972
exact-bit C cases. The normal movement builder is ready, but integrated timing
and broader integration gates remain pending. Cross is inlined in the candidate;
its absent standalone symbol does not imply that its work disappeared. Sources,
reports and executables are preserved separately in cross-private.json and the
archive. The actual working math body remains unchanged.

Restore row-threshold.zip through tools/evidence_store.py before extraction.
Exact frozen sources, proof reports, commands, binaries, numerical outputs and
raw performance samples are retained; generated caches are excluded. The C3.14 proof launcher initially lacked the helper-module Python path and
exited before proof startup. Its original log and the environment correction
are retained; completed numerical groups were verified unchanged and not rerun.
The change is local and no new GitHub push is performed by this checkpoint.
