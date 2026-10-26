# Cross: reproduced integrated gain, adoption still pending

A private body-only candidate replaces six intermediate product subtype checks
with proved Static bounds. The same six rounded products, three subtractions,
public domain and complete functional postcondition remain. C evaluates the
same ordered expressions without these intermediate checks. No assumption,
suppression, new trusted production body or narrower input domain is introduced.
The compiler inlines Cross; no standalone symbol does not mean no executed work.

The minimum closes 86 checks and the whole C3.17 math unit closes 796, retaining
10/66 existing diagnostics separately. Both profiles pass 5,972 exact IEEE-bit
C cases, including signed zeros, subnormals, exponent boundaries and cancellation.
Those frozen inputs/reports are in the preceding r620 checkpoint.

The first six-copy run covers nine movement scenarios from free_ball, chain24
and branches24. All intervals are below parity with the current published
arithmetic baseline plus locally adopted threshold8. The complete six-copy run
then covers all 30 supported scenarios; all endpoints pass, and all intervals
are below parity in that run. Each run uses 36 balanced blocks, 8 samples,
32 warmups, 100 steps, CPU 12, normalized argv0 and shared fixtures. Bootstrap samples
replicas then paired blocks. C is normal source-built 3.17 AVX/LTO with the same
GCC 16.1 toolchain, FP contraction off. Its shared-library placement is not varied
independently across C launcher copies. No own heavy jobs overlap accepted timing.
Individual estimates and raw data remain; there is no unweighted model average
or arbitrary slower-than-C allowance. Small-case uncertainty differed in the
interrupted attempt, which remains explicitly incomplete rather than discarded.

On the complete run, chain24 current/baseline ratios are about 0.9191, 0.9130, 0.9191;
branches24 about 0.9467, 0.9542, 0.9517. The first targeted run confirms both gains.
Chain24 still needs about 2.09-2.10 times C and branches24 about 1.59 times C.
This is useful progress, not overall C parity or complete MuJoCo coverage.

The first full run r624 was explicitly interrupted when C: reached about 65 MiB
free, before cache deletion or other heavy recovery work. All partial records
and its interruption reason are retained. After cleanup the exact same binary
hashes were used for the full r628 run. Known-heavy-process preflights are retained.
Only backed generated caches and losslessly stored, ignored raw ZIP duplicates
were removed; all source, proof receipts, binaries, logs and exact store bytes remain.
Tracked historical archives are untouched; WSL was not stopped or compacted.

The candidate remains private. Two-reference validation/release numerical
integration and the complete C3.14 math proof are live in r625, whose changing
outputs are deliberately excluded here. The immutable runner is retained.
The actual working Cross remains unchanged pending these gates. Whole dynamics
Gold, full engine migration and overall C performance parity are still unfinished.

Restore cross-performance.zip through tools/evidence_store.py before extraction.
Original fixtures and full proof/source inputs are exact-store dependencies in
r503/r620. This checkpoint remains local; no GitHub push is performed.
