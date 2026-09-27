# MuJoCo 3.14.0 alignment

The current upstream reference is the official stable MuJoCo **3.14.0**, released
2026-09-22, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`:
[release](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0).
The migration compares the complete source delta from 3.12.0 commit
`13827e9ee56f097f57acf69ae52b078f9839682d`, including intervening changes.

## Implemented changes

- Regenerated the model, field IDs, layouts, allocator/free procedures, MJB
  readers and test serializer from the new C tables. There are **487 pointer
  fields**, 98 sizes and 96 generated reference clauses. The added `site_dataid`
  occurs between `site_bodyid` and `site_matid`. Fixed option/visual/statistic
  layouts are unchanged. Generation rejects an unexpected upstream version.
- MJB header version is **3014000** and the pointer count is **487**. Old 3.12
  images are intentionally rejected; regenerate them with the pinned 3.14 wheel.
- Mesh sites validate `site_dataid` in `-1 .. nmesh-1`, matching
  `mj_validateReferences`. Non-mesh sites do not dereference this field. The
  diagnostic identifies `Site_Dataid` and the failing site index.
- Pair/exclusion signatures decode the upper half with unsigned semantics.
  Signed storage with bit 31 set is valid when both body IDs are valid.
  `Signature_Bits`, `Signature_Low` and `Signature_High` have proved range and
  reconstruction contracts, without an unchecked conversion. The port retains
  its stronger pair-to-geometry consistency and no-self-exclusion checks.
- Added `Int_Discrete = 4`, `Enbl_Ipc = 64`, and `N_Enable = 7`. Option validation
  accepts the new integrator. IPC requires discrete integration and CG, forbids
  `sleep`/`fwdinv`, and discrete sleeping requires enabled islands, matching the
  non-flex rules in upstream `mj_checkDiscrete`. Recognizing
  these model options does not implement the corresponding simulator.
- The newly included official `welcome` model exposed an older validator bug:
  negative first/second plane extents are legal infinite-plane rendering values.
  They are now accepted; negative solid geometry sizes and negative plane grid
  spacing remain rejected. This follows upstream `user_objects.cc:checksize`.
- Rebuilt the corpus using the 3.14 wheel: 94 upstream models plus a dedicated
  mesh-site fixture, **95 compiled, zero skipped**. The fixture has both a mesh
  site and an ordinary site. A corpus receipt records every binary SHA-256,
  listing hash and oracle version; tests reject stale images or ABI metadata.
- Updated the compiled C reference manifests. The collision dependency closure
  shrank because upstream removed unnecessary umbrella-header inclusions; hashes
  cover the actual new dependencies. Existing historical evidence is retained
  with its original 3.12 reference, never relabelled.

The reviewed dense matrix formulas are unchanged. Dense-vector scalar arithmetic,
including the four-lane dot-product accumulation and remainder order, is unchanged;
AVX remainder handling moved into the AVX helpers. Matrix implementation work is
owned by the separate matrix task; this migration preserves its source files and
reruns its available numerical comparison harness against 3.14.

## Deliberate limits and differences

This is alignment of the implemented subset, not a full MuJoCo 3.14 simulator.
Flex/plugin models are still rejected by the foundation. Discrete integration,
IPC contacts, the new flex runtime arrays and effective-metric workspace, control
history replay, resource-provider archives, preserved MJCF frames and other
unported engine/compiler/rendering services remain outside the implemented subset.
The upstream compiler and official wheel remain the producer of MJB files.

The smooth prototype supports its existing Euler/hinge/slide subset. It rejects
`discrete` and IPC models with `Unsupported_Feature`. Upstream 3.14 `mj_factorI`
clamps a pivot below `mjMINVAL` and `mj_factorM` emits an inertia warning. The
prototype intentionally performs no regularization: nonpositive pivots return
`Singular_Inertia`; small relative pivots/poor conditioning return
`Ill_Conditioned_Inertia`; failed steps preserve the state. These are explicit
behavioral differences, covered by policy tests, not C-equivalence claims.

## Verification scope

Start with the changed element predicates, scalar signature decoders, site
allocation/free/layout/reader and asset diagnostics, then prove affected complete
units. Diagnostic subprogram runs alone are not complete-unit evidence. All
build/proof commands retain the resource guard and a 4000 MB process-group cap.
The existing trusted bodies, modeled deallocators and reviewed warnings remain;
no assumptions, suppressions or new trusted bodies were introduced.

Numerical differential tests establish sampled agreement within the stated
harness comparisons, not universal C equivalence or real-arithmetic accuracy.
The smooth and collision prototypes retain their independent formal-proof scope.
Historical foundation/vector/matrix proof totals are not recertified by changing
the reference version. Whole-project Gold, Windows verification and C performance
parity remain independent acceptance work under the verification policy. This
migration's correctness tests do not establish a speed claim.

## Fresh correctness results (Linux/WSL, 2026-09-23)

- All three profiles (`development`, `validation`, `release`): **1,097 Ada
  assertions across ten executables**, **72 Python tests**, **4,014 C comparison
  cases / 1,028,505 scalar comparisons per profile**. Recorded source hashes are
  identical at the start and end of each profile run.
- Compiled actual MuJoCo AVX paths (`-DmjUSEPLATFORMSIMD -mavx`, contraction off):
  **1,541 vector cases / 721,473 comparisons**, **371 matrix cases / 286,012
  comparisons** against the verified Ada validation executables. The C
  preprocessor confirms `mjUSEAVX` is defined. This is correctness evidence,
  not a timing benchmark.
- Generator check: all **15** generated/table files match a fresh isolated
  regeneration. CLI checks pass for usage, humanoid, mesh-site fixture and
  missing-file statuses.
- Collision regression: **5,260 cases / 105,200 scalar comparisons per build**
  in debug and optimized modes, plus analytic cases and rejected-input checks.
  The new reference dependency manifest covers the actual twelve C files.
- Smooth snapshot: **360 scenarios / 33,840 comparisons**, plus **14 policy
  tests**, including explicit rejection of discrete/IPC runtime requests. The
  immutable snapshot records its source hashes; later experimental edits are
  outside that run's claim.

Complete-unit proof results are added after the corresponding gate passes.

The integration runs use `tools/prove.py` with selected complete units, the
4000 MB guard, and an extended whole-process time budget. For large quantified
model predicates, `-- --proof=progressive --prover=z3` substantially reduced
proof time in a minimal-subprogram experiment without changing source, contracts,
obligations or the report gate. The standard multi-prover runs that reached their
process time limits are recorded as incomplete attempts, not accepted evidence.
Experimental context-hiding annotations were tested only in a disposable copy;
they were not introduced into the repository.
