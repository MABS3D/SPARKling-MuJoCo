# Local native mass / derivative checkpoint r195

Changes remain local and uncommitted. Production stays on 3.14. The current
reference is official C 3.17.0, commit
`800a109a4bdd02cb60404d565db4ae16fb04a53b`.

The derivative workspace now owns actual M row addresses, widths and columns.
Disjoint rows may be reordered: the already published dense mass is gathered
into native storage without recomputing CRB. Source models are freed before
sampling in both probes. Shared spans have a separate raw-image reader matching
C's sequence: zero all slots, assign simple/diagonal values, add ancestor terms,
then add fixed-tendon armature. The scratch dynamics still multiplies/solves a
dense physical mass, so Create explicitly returns Unsupported_Feature for shared
M slots instead of publishing derivatives of different forces. Raw shared-image
support is not whole-step or inverse-force support.

Zero, Update and Gather_Row have exact functional/frame contracts. Minima run
first, followed by the whole unit: **47 checks (40 proof, 7 flow)** close with
zero warnings, skips, assumptions or open obligations. These are the same
obligations, not added to the minima twice. Bounded has only two flow checks.
Failed r191/r192 attempts retain the length-check diagnostic and new integer
reassociation warnings; final source uses the equivalent last-index condition
and explicit evaluation parentheses. Existing reviewed project warnings and
modeled deallocators were not changed.

Both checked validation and optimized release pass against C 3.17:

- 24 raw-storage configurations, 12 states each: **288/288**, max absolute
  mass difference zero. Covers scalar/free/ball joints, branched chains, fixed
  and spatial tendons, disjoint reordering, shared spans and unused slots.
- **960/960** derivative samples over 80 model configurations with original
  storage, retaining the historical finite-difference tolerances.
- **960/960** with reordered M storage, compared with the original C model and
  an explicitly checked bijection of Mq columns. Other outputs retain the same
  physical coordinate order. These are not calls to C on every mutated model.

A direct C call on reordered M storage crashes on the Newton/sparse elliptic
contact case. The isolated reproducer invokes only the unmodified C wheel;
its reference validator accepts the saved MJB, then transitionFD segfaults.
The six diagonal rows have addresses [5,4,3,2,1,0]. MakeHessian uses the last
row end (1) when reserving mass entries, while later shifts use the six widths.
This is source evidence for an allocation/layout assumption, not a complete
upstream memory-safety proof or a claim about the supported model-editing API.
The direct experiment, signal, faulthandler trace and source are retained.
No upstream PR, commit or push was made. Shared raw-image fixtures separately
retain C's near-singular-inertia warnings; no motion equivalence is claimed.

C 3.17 also rejects its compiler's duplicate fixed-tendon width=3 when nv=2.
The runner records that original rejection and retains duplicate-column coverage
using a third independent DOF; the original nv=2 fixture remains on C 3.14.
The historical 3.14 closure passes **960/960 derivative samples** and **132/132
raw mass states** in both profiles. The owned derivative sources are byte-equal
between versions, as are all four files used for the kernel proof. The 3.17
closure reuses 45 unchanged verified r186 foundation library files; its own GPR
project is distinct from the foundation's 46-file library/project closure.

Complete functional/safety proofs of Capture/Evaluate and workspace composition,
including pattern-to-simulation binding, remain unfinished proof engineering;
this is not a mathematical Silver exception. Real derivative accuracy, shared
numeric-buffer dynamics, full 3.17 engine/ABI/API coverage, sensors, history,
inverse-discrete correction and integrated C performance parity remain open.
No new timing result is claimed.

`native-mass.zip` retains complete frozen sources, all executed fixtures and
receipts, minimal/whole proof attempts, old failures and official C source
excerpts as full files. Compiler object/proof-cache trees are excluded; hashes
of the untimed executables are listed as omissions and originals remain local.
`archive-manifest.json` hashes every member. `verification.json` records an
independent reread and current source-closure checks.

Reproduce with tests/build.py into a fresh Linux output directory. For 3.17
supply --foundation pointing to the verified r186 foundation tree; omit it for
3.14. Build validation, then release with --resume. Run prove_native_mass.py
on the frozen build before interpreting whole-unit evidence. From the frozen
source, run check_native_mass.py and compare.py with the corresponding pinned
Python/C environment, --reference, --binary and fresh --out folders; repeat
compare.py with --mass-layout reverse for 3.17. The snapshot includes both test
providers and tools/guarded.py. No suppressed language checks or fast-math flags
are used.
