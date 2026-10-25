# Local native CSR row-domain checkpoint r186

All changes remain local, without new commits or pushes. Production is still
3.14. Reference: official C3.17.0 commit
`800a109a4bdd02cb60404d565db4ae16fb04a53b`.

The native M/B/D/tendon predicates now use the already proved per-row CSR
model: reordered rows, shared/prefix spans, gaps and unused storage retain the
C admission domain. The old CSR_OK utility keeps its compact semantics for
legacy users and tests. The documented nonstrict duplicate-tendon correction
is retained rather than reproducing C3.17's unconditional width-cap regression.

Four native diagnostic procedures close twelve checks each. Their postconditions
specify the exact CSR mapper/kernel result and success equivalence, including
field and first bad row. Parent-subset and D/B comparison preconditions close
15/18 checks after removing two redundant row scans and two constant-time span
guards respectively. D_Diag_At closes nineteen checks. Model_Admission closes
166 whole-unit checks with no open obligations, assumptions or skips. The two
recursion and two operator-reassociation warnings remain explicit:
obligations_closed=true, strict passed=false. Renewed caller scopes are
Diagnose_Sparse 42, Diagnose 14 and Validate 7; other historical scopes are not
claimed afresh from these numbers.

The complete r186 library/project equals proof snapshot r184 byte for byte
(46 files). Both validation and release pass ten Ada suites, 77 Python tests,
all 100 corpus inputs, twelve ABI scenarios, eight wide-bound cases,
deterministic regeneration and 69 actual C-produced admission scenarios.
The corpus retains the 49 OK / 36 Unsupported_Flex / 15 Unsupported_Plugins
split; 100 loaded inputs do not mean 100 supported simulations.

The 69 cases include the earlier 49 controls, eight reordered/shared M/B/D/
tendon inputs and twelve native width/address/column errors. Shared cases put
invalid integers in unused columns to detect accidental whole-storage scans.
The C oracle accepts all eight positives and rejects the twelve negatives at
the named fields. B/D malformed cases exercise total CSR diagnostics/Validate;
body/DOF helper calls are explicitly withheld where their stated sparse
preconditions do not hold. This is recorded as HELPER_PRE FALSE rather than a
silent skipped test.

The C-only controls compare four disjoint storage permutations for 32 steps
with applied torques. qpos/qvel/qacc differences are zero. Associated M/D maps
are permuted consistently. Shared storage is admission-only, and no Ada motion
or timing result is claimed. Before-change receipts retain six C-accepted MJBs
that old Ada rejected, with successful raw parsing and byte roundtrip.

The updated diagnostic test names M_colind for the two confirmed C3.17 errors.
Its ABI branch preserves the previous expectations on 3.14; the full test passes
against the unchanged historical library/corpus. Historical sources, project,
input, build log and executable are retained separately.

The source audit covers canonical row-address consumers. Spatial-tendon code
uses actual addresses/widths and plugin copy preserves descriptors. The derivative
adapter still explicitly requires compact M storage and rejects other patterns;
this is a remaining migration restriction, not an unverified new fast path.
Full consumer migration and compatibility remain open.

`row-domain.zip` contains two frozen source snapshots, sixteen minimal/whole
proof receipts, complete foundation gates, actual C fixtures/controls and the
historical regression. The final plain source tree is `foundation/source/`.
`archive-manifest.json` hashes every member and lists large regenerated MJBs
and untimed executables omitted from the archive; originals remain at their
recorded local paths. No acceptance input was dropped from execution.
`verification.json` records an independent reread and source-closure checks.

Run the current builder's prepare/generate/verify phases with a fresh output
folder and the pinned checkout/wheel, then use prove_admission.py for minimum
scopes before --whole-admission. check_row_domain_motion.py reproduces only
the C fixture control. Complete FLEX/plugins/engine/API migration, exact count
models and capacity sufficiency, global Gold and integrated C3.17 performance
parity remain unfinished.
