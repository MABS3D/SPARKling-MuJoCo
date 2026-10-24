# Foundation 3.17 r5 evidence, 24 October 2026

The [public archive](foundation-r5-public.zip) retains source snapshots, generation
inputs, commands, logs, results, proof receipts, all retained negative attempts,
XML/assets and MJB payloads up to 1 MiB. Identical payloads are stored once by
SHA256. [manifest.json](manifest.json) records the ZIP digest, size and every
omission, including its exact digest, size and source paths. The complete original
archive is preserved locally at the path and digest in that manifest.

This public subset omits only MJB payloads larger than 1 MiB and regenerable ELF
executables. It is not a copy from which the omitted bytes or the complete
original ZIP can be reconstructed. Compiler outputs and caches were already
excluded from the original evidence archive. All text sources, generated Ada,
XML, generation commands, pinned reference hashes and test/proof reports remain
auditably reconstructable. Re-running the retained corpus producer against the
pinned reference and source tree regenerates its omitted MJBs; absolute asset
paths can change the exact resulting bytes. Digests refer to the original runs.

Run from this directory, with Python 3 and its standard library only:

```sh
python3 verify.py
python3 verify.py --extract /tmp/foundation-r5-retained-evidence
python3 verify.py --restore-sources sparkling-alignment-317-foundation-r5-20261024 /tmp/foundation-r5-sources
```

The output directories must not already exist. Extraction verifies every retained
payload and writes an explicit omissions file. Source restoration recovers the
exact candidate source closure, with the large generated MJBs recorded as absent.
This package adds no new compiler, runtime or proof results.

[Results summary](results-summary.json): both 3.17 profiles pass 10 Ada suites,
77 Python tests, 12 ABI scenarios, 8 wide-reference boundary cases and generation
reproduction. The 100 raw corpus images have a 49 accepted / 36 unsupported-flex /
15 unsupported-plugin validation split; this does not mean 100 supported physics
models. Production 3.14 validation and release regression pass. Its current
generator additionally reproduces all 13 generated production outputs byte for
byte, with no compiler invocation ([receipt](generator314-reproduction.json)).

The local flag minima close 14 proof plus 4 flow checks on 3.17 and 10 proof plus
4 flow checks on 3.14; exact unchanged dependencies support their limited reuse
on r5. Whole-loader Gold, full C 3.17 validation equivalence, engine migration and
integrated performance acceptance remain open.
