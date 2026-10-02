# Sparse constraint assembly candidate

Isolated Ada/SPARK implementation of the sparse row assembly in MuJoCo 3.14.0,
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
The official latest stable release was checked on 2026-10-01. The reference is
`mujoco/src/engine/engine_core_constraint.c`, particularly `mj_addConstraint`,
`mj_instantiateFriction`, `mj_instantiateLimit`, and `mj_instantiateContact`.

## Implemented

- Caller-owned CSR buffers with zero-based column indices and row addresses;
  a block appends at most ten rows without allocating on the heap.
- Exact row metadata: type, source ID, position, inclusion margin, friction loss,
  and equality/friction/limit counters.
- The C sparse empty-chain rule, including retention of structural numerical
  zeros. Raw `Append` retains empty contact rows; `Add_Contact` skips zero-DOF
  contacts as the upstream contact instantiator does.
- Frictionless contacts and pyramidal/elliptic contacts with dimensions 1, 3, 4,
  and 6. Pyramidal rows keep C's `normal + mu*tangent` operation order; elliptic
  tangential rows have zero position and margin.
- DOF friction and hinge/slide scalar limit rows. Limits use the strict
  `distance < margin` activation condition and C's signed distance expression.
- Prepared equality rows, tendon friction rows and tendon limit rows through
  `Append`. Their geometric calculations remain the producer's responsibility.
- Capacity checks before writing. A rejected or skipped append preserves the
  entire previous buffer, including unused suffixes. `Reset` changes only the
  cursors/counts; it does not clear arrays on every step.

The caller must append **equalities, DOF/tendon friction, joint/tendon limits,
then contacts**, in C's order. For each scalar joint, process the lower bound
before the upper bound. Input chains must be sorted, unique, and in range.
The input contact Jacobian is already in the contact frame, with common
ancestor DOFs removed. It is not a dense Jacobian converted by this module.

## Contracts and domain

Static functional contracts specify the floating-point values of every new
entry, metadata and counter updates, and preservation of all other entries.
They do not insert quantified buffer scans into the release executable.
`Valid` is a constant-time cursor/count predicate. Starting with `Reset`, the
append contracts establish contiguous row addresses inductively; arbitrary
direct edits to the public storage record are not certified construction.

The supported domain is finite binary64. Contact Jacobian entries are in
`[-1e20,1e20]`, coefficients in `[0,1e10]`, and position/margin in
`[-1e30,1e30]`. Scalar joint values, bounds and margins are in `[-1e10,1e10]`.
Capacities are up to 4096 DOFs, 8192 rows and 1048576 entries. A capacity
rejection is a documented local policy; C normally precounts and allocates
the required storage. Whole-model allocation, filtering, and group rollback
are not provided by this module.

The candidate is not wired into `mjData` or the smooth simulation step. Contact
Jacobian generation, ball-joint limit geometry, connect/weld equality geometry,
flex weighting, impedance/regularization, velocity/reference construction and
solver invocation remain separate integration work. No integrated performance
parity or numerical-accuracy theorem is claimed by assembly tests.

## Verification status (2026-10-02, closure)

The fresh complete-unit run checks every entity, without skipped proof/flow, an
`Assume`, or a new trusted application body. **509 proof/flow diagnostics pass;
zero obligations remain open and zero prover warnings are reported.** The
isolated assembly unit now has Gold coverage of its stated functional contracts:
exact CSR values and columns, metadata, counters, initialization, runtime safety,
and preservation of previous/unused storage on success, rejection and skipping.
This does not establish a real-arithmetic accuracy bound or full simulation
correctness; geometry, model ownership and dynamics integration retain the
separate scope described above.

All three previously open functional obligations are closed:

1. `Append` preserves the relation between previous rows and the input Jacobian
   when another row is copied. `Copy_Row` now takes the block base and exposes
   its already proved frame property directly in the caller's row coordinates.
2. `Append` establishes the final block-wide column-copy postcondition. Values
   and columns are specified in separate quantified clauses with the same
   functional meaning as the previous conjunction.
3. `Add_Contact` establishes the final relation between stored values and the
   specified contact-edge expressions. The proved static ghost helper
   `Reframe_Contact_Values` composes contact construction with CSR copying using
   the same chain indices as the public postcondition.

The public input domain and the floating-point contact formulas are unchanged.
The private row-copy bound on `Source` follows from `Append`'s existing
`Max_Block` precondition. The new helper and assertions are static proof code;
they do not add a buffer scan to either executable. Minimal diagnostics were
run before the complete-unit proof; the final-source contact helper and caller
pass 57 and 85 diagnostics respectively. The complete-unit run also closes
the bodies and contracts of all their callees.

The final checked and release executables both pass **894 cases / 1901
operations**, including 39 official-engine scenes and input chains with up to
4096 DOFs. The literal C helper matches all accepted raw appends; contact-frame
Jacobians independently generated with `mj_jac` match the engine's stored
values with a maximum absolute difference of `2.220446049250313e-16`.
Capacity failures, zero-DOF cases and reset/reuse also preserve the buffers in
the checked probe. Capacity rejection is tested against the candidate policy,
since the upstream helper receives preallocated storage.

Source hashes, commands, final-source minimal diagnostics, complete-unit
diagnostics and fresh checked/release test results are saved in
[`results/20261002-closure`](results/20261002-closure/README.md). Source hashes
match the complete-unit proof and both builds. The older `results/20261002`
directory remains a historical snapshot with three open obligations. These
results cover this isolated candidate and these stated domains, not full
dynamics or simulation performance.

## Reproduction

Run `tests/check.py` with a fresh absolute `--out` directory outside the repo:

```text
python3 tests/check.py --out /var/tmp/assembly-small --phase small
python3 tests/check.py --out /var/tmp/assembly-whole --phase whole --proof-mode per_path --timeout 10
python3 tests/check.py --out /var/tmp/assembly-checked --phase build
python3 tests/check.py --out /var/tmp/assembly-release --phase build --mode release
```

The script freezes source inputs, records SHA-256 hashes, diagnoses individual
subprograms before a whole-unit proof, and rejects unproved checks or incomplete
entity coverage. It uses the local native GNAT/GPRbuild/GNATprove toolchain
under `/var/tmp/sparkling-matrix-recovery/toolchains`, with a memory/time watchdog.

Use a Python environment with NumPy and the official MuJoCo **3.14.0** wheel:

```text
python tests/differential.py --out /var/tmp/assembly-differential \
  --binary /var/tmp/assembly-checked/build/validation/bin/assembly_probe \
  --binary /var/tmp/assembly-release/build/release/bin/assembly_probe
```

The differential harness compiles an unchanged extracted `mj_addConstraint`
body against the official wheel. It also checks complete assembled buffers from
engine scenes, independently generating contact-frame input Jacobians with
`mj_jac`. Prepared equality/tendon rows test copying/metadata, not their geometry.
The checked probe asserts preservation of all prior and unused entries on every
operation. Signed zero, strict boundary activation, structural zeros, contact
dimensions/cones, shared ancestors, zero-DOF groups, capacity exhaustion and
reset/reuse are included. These are finite differential tests, not a universal
proof of equivalence to C.
