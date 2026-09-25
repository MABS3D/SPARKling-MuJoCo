# Immutable topology and conservative C simple-DOF specialization

`MJ.Smooth_Topology.Cache` owns copies of roots, last DOFs, true DOF parents,
DOF-body and DOF-joint mappings, armature, reverse accumulated subtree mass,
simple-run counts and constant diagonal inertias. It is built during `Create`,
freed with the existing modeled integer/real deallocators, and exposes read-only
accessors. Its private invariant establishes layouts and index/value bounds;
there is no newly trusted readiness Boolean or per-step topology scan.
Subtree masses cover nonworld bodies; the unused world slot does not represent
the C compiler's total-world subtree mass.

`Build_Body_Links` derives roots and last DOFs once. Its contract specifies the
exact parent recurrence. `Add_Subtree` specifies the rounded parent addition and
unchanged other entries, including failure behavior. Cache `Build` specifies
exact correspondence for every stored input entry. Their completed whole-unit
proof was recorded in `/var/tmp/sparkling-topology-unit3`:

- `MJ.Smooth_Topology`: 208 emitted checks, none unproved.
- `MJ.Simple_Kernels`: 10 emitted checks, none unproved.

The DOF-to-joint accessor returns its proven identity directly, avoiding a hot
index-array load in this scalar-only scope. The ancestor unit, including the new
row-disjointness lemma, closes 773 checks in `/var/tmp/sparkling-ancestor-unit11`.

Packed factor updates use `MJ.Solver_Kernels.Add_Row_Disjoint`, with one mutable
buffer and a proved nonoverlap precondition. Its contract specifies the exact
rounded update, every untouched entry, and the complete rejection predicate.
The helper closes 37 checks in `/var/tmp/sparkling-disjoint-row1`; the complete
solver-kernel unit closes 101 checks in `/var/tmp/sparkling-disjoint-row-unit1`.
No aliased-slice suppression or source-row copy is used. The checked and release
`check_disjoint_rows.py` probe each pass 14,905 cases in
`/var/tmp/sparkling-disjoint-row-tests1`, including SIMD boundary lengths,
rejected output lanes, unchanged source/gaps, and arrays ending at `Natural'Last`.

These unit proofs establish their functional contracts. The `MJ.Data.Build_Topology`
composition and full physical simple-body reasoning are separate: the bounded
composition diagnostic `/var/tmp/sparkling-topology-create2` timed out before
emitting obligations and remains pending proof engineering. No mathematical
exception or whole-simulator Gold claim follows from that diagnostic.

The implementation follows MuJoCo 3.14.0 `user_model.cc` root/last-DOF construction
and simple-run encoding, `mj_crb`'s constant diagonal branch, and the model-time
constant setup. For independent validation it uses a conservative subset of the
C eligibility rules: a leaf directly under the world or its fixed child, coincident
body/inertia frames, joints at the origin on exact coordinate axes, orthogonal
slides followed by at most one hinge. Source C flags must also permit the shortcut.
Approximate axes/frames or uncertain cases retain the general calculation.

The fixed diagonal is computed locally as armature plus mass for a slide, or
armature plus the appropriate principal inertia for a hinge. Imported `dof_M0`
is never used as a numerical authority: it can be stale in a mutable caller model.
The solver pattern uses an effective parent of -1 for validated simple DOFs;
true parents remain in the topology cache for physical recursions. Non-simple
rows must not have simple ancestors. Consequently diagonal-only simple rows
preserve the existing ancestor-prefix representation invariant.

The three `simple_*.xml` fixtures cover independent hinges with spring/damping
disabled, damped/stiff sliders in rotated frames, and sliders followed by a hinge
under a fixed rotated parent. C compilation confirms that every fixture DOF is
simple and every C row has one entry. The checked/release private probe verifies:

- roots, last DOFs, subtree masses and DOF mappings against C model metadata;
- simple run counts and actual diagonal-only Ada pattern selection;
- fixed diagonals against the C compiler's constants;
- a stale but valid Tier0 `dof_M0=1234` cannot change computed constants;
- a positive imported DOF flag without validated body eligibility cannot prune rows;
- both solver policies, freeing the caller model, and cache allocation/free reuse.

Run with the MuJoCo-enabled Python environment:

```sh
python check_topology.py --out /var/tmp/topology-check \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains
```

Pass `--build /path/to/integrated-build` to consume that build's immutable source
snapshot. Checked and release runs are both recorded; these are correctness
checks, not performance timings. `/var/tmp/sparkling-topology-tests3` passed all
three fixtures in both variants. The final repeat
`/var/tmp/sparkling-topology-tests4` passed the same complete probe against the
immutable `/var/tmp/sparkling-six-build4/source` snapshot, including the flat
kinematic layout and the direct DOF-to-joint accessor.

`prove_inertia_frames.py` is a separate batched proof driver for concrete
`Stable_Ready` assertions in the integrated inertia implementation. It retains
unit-level flow diagnostics from `.spark` as well as console output. A selected
assertion passing does not erase other open flow or numerical obligations.

The flat kinematic buffer lifecycle is proved separately in
`/var/tmp/sparkling-flat-lifecycle1`: `Allocate_Kinematic` closes 37 checks,
`Clear_Kinematic` 73 and `Free_Kinematic` 1, with no unproved or flow diagnostics.
The latter retains the existing modeled deallocator boundary. The exact source
snapshot is `/tmp/sparkling-smooth-fragments-1jyr5td_/source`.

The broad integrated frame batch `/var/tmp/sparkling-inertia-frames-batch5`
reached its 300-second watchdog without emitting obligations. It is pending,
not a pass; subsequent diagnostics therefore target minimal helpers first.

After the one-buffer row helper removed the unit-level alias diagnostic,
`/var/tmp/sparkling-inertia-load2` completed the isolated
`Load_Ancestor_Factor` diagnostic: 23 emitted checks, no flow errors, with the
final `Stable_Ready` assertion and the existing `State_Values` preservation
postcondition still open. Its stable/shape loop invariants and early-exit
assertion were proved. The follow-up `/var/tmp/sparkling-inertia-load3`, carrying
additional loop frame facts, reached the 180-second watchdog without emitted
checks. Those integration annotations and the new row-helper caller
precondition remain separate pending proof work; neither is counted as Gold.
