# Gold mocap mapping and recovery from the Linux I/O interruption

The actual private Mocap_Mapping_Valid function now proves its exact Boolean
result: IDs are in range, every nonnegative ID is unique, and every mocap slot
is covered. Its full scope closes45 checks on each3.14/3.17 closure, including
termination; the separate coverage lemma closes12 on each. Counts are separate
scopes, not a whole Data-unit claim. Existing warnings are retained. The same
count precondition is preserved, with no assumptions or check suppressions.

The original one-pass seen-array algorithm is retained. Contracts, assertions,
invariants and the coverage lemma are Static. Fresh validation objects emit
neither the Ghost spec nor lemma; the mapping function is372 bytes on both
closures (the previous validation body was382). Code size is not timing.
The C source excerpts show sequential mocap ID allocation and raw pose copying
in mj_resetData; source hashes and the exact fragments are retained.

Final actual source2363 passes368 cases per reference/profile,1472 new C
comparisons, with16 samples,100 steps and unchanged2e-10 tolerances. All92
output files are byte-identical to the previously verified adopted baseline.
Intermediate syntax failures, quantifier timeouts and successful earlier
variants retain their own actual status and source hashes. New shared object
caches were copied for faster rebuilds; prior binaries/reports were preserved.

The Linux I/O failure stopped two supervisors with exit135 before final result
handling. Their partial files are preserved without invented success reports.
Recovered source manifests were rehashed before resuming. The prepared
projection annotation fix correctly qualifies three generated validity clauses.

Private raw-reference proof work closes7 for a copied quaternion on both
references,18 for the whole copied array on3.17,4 for projecting model validity
to body parameters,6 for one body's raw quaternion,26 for the composed owned
reference loop, and10 for its wrapper. The latter scopes are3.17-only and have
their separately recorded callee contracts. Their construction/reset lifecycle
integration remains open; no mocap type invariant is adopted. All unsuccessful
variants and complete setter watchdogs are retained with actual outcomes.

This checkpoint adopts only the proved mapping validator/spec/coverage helper.
Whole state/dynamics Gold, full features, coordinated latest ABI migration and
integrated C performance parity remain open. No new timing is claimed and no
additional commit or push is performed by this work.
