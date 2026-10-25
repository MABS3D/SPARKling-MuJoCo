# Local native-pattern checkpoint r224

No commits or pushes. Production stays on 3.14; reference C 3.17.0 is pinned to
`800a109a4bdd02cb60404d565db4ae16fb04a53b`.

The owned pattern is now a separate model-independent unit. Its contracts cover
exact interval-overlap detection (including empty/touching spans), copying all
row descriptors and native columns, the precise shared-slot flag, disjoint
projection from the dense mass, preservation of earlier rows and zero values in
unused slots. All minima and the unchanged complete unit pass **149 checks:
126 proof + 23 flow**, with no warnings, skips, assumptions or open obligations.
These counts are not added to the earlier 47 elementary-write checks. Overlap
is an expression definition with two flow checks and no separate arithmetic VCs.

Capture uses row-interval comparisons instead of a separate maximum-sized Seen
array; column storage is copied contiguously, including unused values. In the
worst case the overlap check examines Nv*(Nv-1)/2 row pairs. No creation-speed
improvement is claimed without timings. The disjoint gather still zeroes unused
storage before filling rows; these are output writes, not repeated validation.

The public constructor now checks the model layout before calling Is_Valid,
whose precondition requires allocated, correctly sized tables. The derivative
workspace has the same boundary guard and calls Capture_Validated after its own
validation, avoiding the reader's previous duplicate whole-model validation.
The reader's separate executable row-span scan is replaced by the proved pattern
contracts and a pending model-to-pattern proof. All language checks remain active.

The model bridge is isolated in Native_Mass_Models. Its contracts specify exact
status selection, an internally consistent image, and equality with source row
addresses, widths, columns, simple flags, dof_M0 and armature. **These model bridge
contracts are NOT fully proved.** The final minimum closes 56 checks and leaves
two obligations: deriving the selected row's positive width from the model
predicate and the final Input_Valid implication. Earlier memory/time-limit and
quantifier attempts are retained. The two inherited Model_Structures recursion
warnings stay visible. A historical layout minimum closes two checks; this does
not close the current whole model or reader unit. Capture/Evaluate/workspace
composition and pattern-to-simulation binding remain unfinished proof engineering,
not mathematical Silver exceptions. No new trusted bodies or assumptions exist.

Both checked validation and optimized release pass:

- C3.17: 288 raw mass states, zero numerical difference; 960 original and 960
  reordered derivative samples at the historical tolerances.
- C3.14: 132 raw states and 960 derivative samples, retaining the original
  duplicate-tendon model.
- Four invalid-input scenarios per profile/version: an empty model, plausible
  sizes without allocated tables, missing dof_M0, and inconsistent nC. Both the
  public capture and workspace reject safely and preserve model flags.

Reordered derivatives use the original C model plus an explicitly checked
bijection of Mq columns; they are not direct C calls on every mutated model.
The direct Newton/sparse C crash and duplicate-tendon reference limitation remain
recorded in r195. Shared raw mass images remain tested, but full shared-buffer
force/dynamics support is still explicitly rejected. No new integrated timing
or overall performance parity is claimed.

The 3.17 closure retains 45 identical r186 foundation library files. The old 3.14
ABI remains unchanged; its isolated source snapshot additionally reuses the same
ABI-independent Model_Structures ghost helpers. These helpers retain their r150
source and proof scope. The six files used for the pattern proof equal both
runtime closures byte for byte.

Reproduce with tests/build.py and a fresh Linux output directory, passing the
verified --foundation for 3.17. --prepare-only freezes sources for diagnosis and
makes no compilation claim. Build validation then release with --resume. Run
prove_native_mass.py --patterns (minima first, whole unit last); prove_reader.py
--models --only selects each model-bridge scope. Run the frozen
check_native_mass.py and compare.py with the matching pinned Python/C environment,
--reference, --binary and fresh --out. For 3.17 also use --mass-layout reverse.

native-patterns.zip retains current and historical source closures, all fixtures,
proof attempts, failed preparation/build cases and gate receipts. The manifest
hashes every member and lists excluded compiler/proof caches and untimed ELF
omissions. Originals remain local. verification.json records an independent
reread, source checks and preservation of the prior evidence inventory.
