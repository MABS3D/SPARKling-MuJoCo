# Native sleep controller and smooth integration

The reference is official MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Production routines call no C
or Python. The test oracle compiles the unmodified `engine_sleep.c` and links
the official library.

`MJ.Sleep_Manager` implements delay counters, cycle traversal, awake lists,
wake from pose/load/contact/equality/group changes, and sleeping island lists.
The caller supplies resolved topology, active group predicates and island CSR.
Those inputs do not establish that the complete island producer is integrated.
`MJ.Sleep_Cycles` provides the shared bounded traversal; malformed input returns
-1 and wake rejects it before changing any tree.

`MJ.Data.Sleeping` owns a smooth engine and its sleep state. It currently accepts
independent trees under Euler integration and rejects constraints, tendons,
equalities, flex, activation, plugins and mocap. The probe frees its source
model before movement. A complete engine needs sleep integrated with native
constraint/island production, every force producer and supported integrator.

Fresh 3 October evidence in `evidence/recovery-20261003` includes 1,075 controller
cases / 10,438 operations against C, and 39 smooth models / 2,652 operations.
The latter covers slide/hinge/ball/free, 1/4/16 trees, allowed/never/init, gravity,
damping, signed zero loads, enable/disable and reset. Final validation and release receipts in `evidence/recovery-composition-20261003`
use an identical frozen source map. Each profile passes the full controller and
smooth corpus, plus 12 failure/retry cases. The retry test reproduced loss of a
pose wake after Numeric_Limit; rollback now restores the pose-history cache.
The release controller also passes 532 malformed/valid cycle edge cases.

The scalar kernels close 13 proof obligations and 10 flow diagnostics. Five
simple enum expression definitions have zero arithmetic proof obligations;
the driver records that fact explicitly. The new cycle model specifies the
ordered traversal, minimum ID and bounded rejection, not only a result range.
The ghost recursion and reveal lemma are proof targets and do not execute.
The cycle unit closes 40 proof obligations and 6 flow diagnostics on its final
source. The final controller build and post-refactoring differential runs pass in
validation and release. Wake_Island closes its
stronger frame contract on a separate snapshot (34 proof +5 flow); Update
closes 49 proof +2 flow after adding prefix invariants and exact body states.
Full manager functional contracts, the public adapter, and integrated movement
proofs remain pending.

`MJ.Sleep_Bytes.Positive_Zero` preserves the C byte-zero rule, including -0.
GNATprove 16.1 previously failed to translate `Copy_Sign` when this expression
was inlined. This is an open proof-engineering boundary, not a trusted function,
assumption, mathematical exception or claim of complete Gold verification.
No current performance-parity result is claimed.

Reproduction from the repository root, with fresh output directories:

```sh
python3 experimental/sleep-candidate/tests/check.py --phase small --unit mj-sleep_cycles --out /var/tmp/sleep-cycle-small
python3 experimental/sleep-candidate/tests/check.py --phase whole --unit mj-sleep_cycles --out /var/tmp/sleep-cycle-whole
python3 experimental/sleep-candidate/tests/check.py --phase build --out /var/tmp/sleep-controller
/var/tmp/sparkling-movement-env/bin/python experimental/sleep-candidate/tests/differential.py --binary /var/tmp/sleep-controller/build/validation/bin/sleep_probe --out /var/tmp/sleep-controller-compare
python3 experimental/sleep-candidate/tests/edges.py --binary /var/tmp/sleep-controller/build/validation/bin/sleep_probe --out /var/tmp/sleep-edges
python3 experimental/sleep-candidate/tests/build_engine.py --out /var/tmp/sleep-engine
/var/tmp/sparkling-movement-env/bin/python experimental/sleep-candidate/tests/integration.py --binary /var/tmp/sleep-engine/build/validation/bin/sleeping_probe --out /var/tmp/sleep-engine-compare
```

Use `tools/guarded.py` for corpus runs as for the bounded build/proof drivers.
Numerical tests, proof contracts and integrated performance remain separate
claims, each attributable to the recorded source and binary hashes.
