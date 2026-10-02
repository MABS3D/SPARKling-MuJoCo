# Sparse assembly proof closure, 2026-10-02

The delivered `MJ.Constraint_Assembly` source closes the three functional
obligations retained in the earlier `../20261002` snapshot. This is evidence for
the isolated CSR assembler under its public preconditions, not integration of
constraints into the active simulation step.

| Verification | Result |
| --- | --- |
| Complete-unit proof/flow diagnostics | 509 proved, 0 open, 0 warnings |
| Entity coverage | Complete; no skipped proof/flow or `Assume` |
| Final-source `Reframe_Contact_Values` diagnostic | 57 proved |
| Final-source `Add_Contact` diagnostic | 85 proved |
| Checked differential tests | 894 cases / 1901 operations passed |
| Release differential tests | 894 cases / 1901 operations passed |
| Official-engine scenes per profile | 39 |
| Largest absolute difference from engine | 2.220446049250313e-16 |

Gold covers exact floating-point contact expressions, row copying, columns,
metadata and counter updates, initialization, runtime safety and frame/failure
preservation. The public input domain is unchanged. The additional private
row-copy bound is implied by the existing ten-row block limit. Composition
lemmas and assertions are static ghost code and add no executable buffer scan.
Real-arithmetic accuracy and integrated performance remain separate claims.

`sources.json` identifies the production source shared by the complete-unit
proof, final-source minimal diagnostics and both builds. `proof-summary.json`
and `whole-unit.spark.json` record all entity coverage and proof attempts.
`minimal-subprograms.json` contains only the two diagnostics on this exact final
source; earlier row-copy/append diagnostic iterations are not counted there.
`differential.json` records the pinned MuJoCo 3.14.0 oracle, C helper/compiler
hashes and both executable hashes. `reference.c` preserves the literal extracted
oracle; no Ada implementation calls it. No executable is stored here.

`SHA256SUMS` seals the files in this evidence directory. `test-driver-hashes.json`
identifies the build/proof/test drivers and resource watchdog. Build flags and
tool versions remain in the project and receipts.

From the candidate directory, reproduce using fresh absolute output paths:

```text
python3 tests/check.py --out /var/tmp/assembly-contact-model --phase small --only Reframe_Contact_Values --timeout 5
python3 tests/check.py --out /var/tmp/assembly-contact-caller --phase small --only Add_Contact --timeout 5
python3 tests/check.py --out /var/tmp/assembly-complete --phase whole --proof-mode per_path --timeout 10
python3 tests/check.py --out /var/tmp/assembly-checked --phase build
python3 tests/check.py --out /var/tmp/assembly-release --phase build --mode release
```

Use the Python environment containing NumPy and the official MuJoCo 3.14.0
wheel for the differential harness:

```text
/var/tmp/sparkling-movement-env/bin/python tests/differential.py --out /var/tmp/assembly-comparison --binary /var/tmp/assembly-checked/build/validation/bin/assembly_probe --binary /var/tmp/assembly-release/build/release/bin/assembly_probe
```
