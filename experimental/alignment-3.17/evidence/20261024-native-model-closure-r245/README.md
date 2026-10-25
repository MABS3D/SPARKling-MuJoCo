# Local native-model constructor closure r245

No commits or pushes. C3.17.0 reference:
`800a109a4bdd02cb60404d565db4ae16fb04a53b`. Production stays on 3.14.

The two r224 model-to-pattern obligations are now closed. The selected row's
bounds are exposed by a separately proved pointwise lemma; allocated table shape
is handled independently of used-column values. This keeps the same accepted
inputs and the same executable copy. A row/column witness loop remains ghost
code. No assertions, language checks or proof obligations were suppressed.

The complete **Native_Mass_Models** unit closes **114 checks (96 proof, 18 flow)**,
with no open obligations, skips or assumptions. Its contracts specify exact
Success/Invalid_Model/Capacity_Exceeded selection, a consistent owned image,
source equality of row addresses, widths, columns, simple flags, dof_M0 and
armature, and the exact shared-span flag. The model may be freed after capture.
This is functional metadata-copy evidence under the validator/callee contracts;
it is not a universal proof of physical simulation or real derivative accuracy.

The whole-unit report retains **four existing structural warnings**: two integer
operator-reassociation diagnostics and two recursive-contract/numeric-variant
diagnostics in unchanged Model_Structures. Therefore obligations_closed=true and
strict passed=false. The constructor did not introduce these warnings. Earlier
minimal reports display only the warning subset reached by that scope.

Minimum scopes run before the unit: Reveal_Row 10, Reveal_Input_Layout 2,
Reveal_Source 50, Capture_Validated 14 and Capture 7 checks close. They are not
added to the whole-unit count. The model-independent **Native_Mass_Patterns**
unit, with an equivalent factored input-layout predicate, closes **151 checks
(126 proof, 25 flow)** without warnings. Its contracts still cover exact copying,
interval overlaps, disjoint dense-to-native projection and zero unused slots.

The two earlier aggregate unit attempts exceeded 240 seconds. The final unit
allows 600 seconds of total wall time and completes in about 294 seconds, while
retaining 3 seconds per prover attempt, 650 MiB per prover, 2500 MiB for the group
and one job. The final per-check unit proof is not replaced by the sum of minima.
The failed/time-limited attempts and actual resource logs are retained.

Both validation and release pass the unchanged numerical gates:

- C3.17: 288 raw mass states (zero numerical difference), 960 original derivative
  samples and 960 reordered samples.
- C3.14: 132 raw mass states and 960 derivative samples at the existing tolerances.
- Four malformed/default model scenarios per profile/version reject safely in
  both public constructors, preserving model flags and empty workspace state.

The reordered oracle remains the original C model with an explicitly checked
bijection of mass-derivative columns. It does not claim direct C success on every
mutated model: the r195 Newton/sparse C crash remains independently recorded.
Shared raw storage is still tested separately; its complete force/dynamics path
is explicitly unsupported. No new movement timing result is claimed.

The current 3.17 build uses the same 45 foundation library files as r186, and all
Ada sources of the model proof snapshot equal the current runtime closure. The
six files of the pattern proof equal both runtime versions. Historical 3.14 uses
the same constructor code and passes runtime regression; the 3.17 whole-model
proof does not automatically prove the older validator's distinct clauses.

Remaining work includes complete Data.Native_Mass/workspace composition and
pattern-to-simulation binding, shared-buffer dynamics, full stable-version
engine/API migration, global Gold and integrated performance parity with C.
These remain open engineering work; this checkpoint does not complete the port.

Reproduce with tests/build.py into a fresh Linux directory; pass the verified
--foundation for 3.17. --prepare-only freezes sources without claiming compilation.
Run prove_reader.py --models --only for each minimum, followed by --only whole-unit
--wall-seconds 600. Run prove_native_mass.py --patterns for minimum scopes and its
whole unit. Build validation then release with --resume; execute the frozen raw
mass and derivative drivers using the corresponding pinned Python/C environment.

native-model-closure.zip retains source snapshots, fixtures, all proof attempts,
resource logs and validation/release receipts. The manifest hashes every member;
compiler/proof caches are excluded and untimed ELF binaries are hashed as local
omissions. verification.json records an independent reread and preservation of
all prior evidence entries. No acceptance case was dropped from execution.
