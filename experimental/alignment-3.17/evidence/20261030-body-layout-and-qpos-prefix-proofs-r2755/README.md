# Body metadata layout and Qpos prefix proofs

The candidate adds only an internal Static body-count/array-shape precondition,
a proved Ghost projection of body DOF source-array allocation/bounds and a
Static Qpos validation-prefix invariant. Removing those additions exactly
recovers the previously adopted source. No runtime check, traversal, record
copy, public input restriction, assumption or trusted body is added.

The original single body assignment leaves three pointer/index obligations
open. Shape facts close both index checks; a separate layout projection closes
the remaining source-pointer gap. Its complete minimum closes8 checks on each
reference. The body-update region then closes28 reported checks per reference.
The reference/spring-reference region initially leaves two range checks open.
The new Qpos prefix invariant closes11 checks and the assignments15 on both
references, including initialization/preservation and both value bounds.

Selected Initialize/Create_Dynamics calls meet the stronger shape contract on
both references. The final prefix addition changes only the callee body; exact
caller text, callee pre/postconditions and all other files are checked identical
to those already proved call scopes. This audit reuses unchanged modular call
interfaces; it is not a fresh proof run or a whole constructor proof.

Both fresh validation/release matrices pass528 cases per reference/profile,
with unchanged16 samples,100 steps and2e-10 tolerances. All132 output files equal
previous production byte-for-byte; both Ghost projections are absent from
native symbols. Whole MJ.Data flow closes with the same five modeled
deallocators. Existing reviewed warnings remain. No timing claim follows.

Earlier600-second region/whole-procedure watchdogs and the null-procedure
syntax error are preserved as failed attempts. Copied Why3 sessions can predate the failed attempt; their freshness audit
distinguishes historical cache from current-run evidence. No current-run
progress or complete proof is inferred from stale cached sessions. Final whole-procedure outcomes are recorded
in summary.json; selected scopes must not be mistaken for the entire routine.
Even a complete current-contract proof does not establish exact copying of
every physical field or complete simulation correctness. Full constructor,
Reset/state/dynamics, feature/ABI alignment and integrated C parity remain open.

This checkpoint also retains the exact duplicate-cleanup plan and receipt:
four ignored reconstructable ZIPs and thirteen obsolete untracked indices,
totaling1,040,097,328 bytes. The current manifest/recipes/payloads, tracked
indices, sources, unique evidence and active caches were preserved. The prior
full verification covered73 archives/494 inventory files. No VHDX compaction,
shutdown or physical-image shrink is claimed.

Candidate status: retained as a private candidate. No commit or push is implied.
