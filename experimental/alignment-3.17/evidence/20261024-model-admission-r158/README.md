# Local Model_Admission checkpoint r158

The final frozen complete source-library candidate is based on the verified
3.17 foundation r5 and the separate structural overlay. Production remains on
3.14. No commit, push or production migration was performed for this checkpoint.

- `MJ.Model_Admission`: 88 whole-unit checks, no open obligations, no assumptions
  or proof skips. Two recursion warnings and two operator-reassociation warnings
  remain visible:
  `obligations_closed=true`, strict `passed=false`. This uses the separately
  proved Model_Structures contracts, not a proof of all validator callers.
- Runtime r159: 43 scenarios in validation and 43 in release, all passing with
  source and driver hashes unchanged. Full libraries compile separately under
  their normal flags; the test transport retains assertions in both profiles.
- Reference: unchanged official MuJoCo 3.17.0 wheel and pinned checkout
  `800a109a4bdd02cb60404d565db4ae16fb04a53b`. The archive records C validator
  source, library, tool, harness and fixture hashes.

The 33 FLEX cases include three populated CSR patterns, negative/oversize widths
and addresses, out-of-range/duplicate/descending columns, unused storage,
shared rows and invalid efm0 DOF IDs. The 2D fixture uses `equality="vert"` and
`elastic2d="bend"`, as defined by the actual C XML tables and producers. The
seven B/D cases include the valid chain, root width, parent subset, ancestor
count, diagonal position, and body-row width/column mismatches. Three mesh
cases cover the valid mesh and zero normal/texture counts with faces present.
C acceptance/rejection and implicated field are checked; Ada helper diagnostics
are exact. Non-FLEX cases additionally require exact full-validator diagnostics.
FLEX full validation still returns Unsupported_Flex and is explicitly separate.

`admission.zip` contains 683 members: six complete source snapshots r153-r158,
32 minimum/whole proof attempt directories, final runtime sources and harness,
XML/MJB inputs, transcripts, build logs and both final executables. All proof
attempts are retained, including failed FLEX postconditions, a misplaced
annotation, the 240-second body-caller limit and the earlier DOF composition.
Build objects and static libraries are unnecessary to reproduce the commands
and are omitted. `archive-manifest.json` hashes every included member;
`verification.json` records reread verification. The final sources are under
`snapshots/r158/source/`; each snapshot has its own source-hash manifest.

Reproduce from the local repository with fresh Linux output directories:

```sh
python3 experimental/alignment-3.17/tests/prepare_admission.py --foundation /path/to/verified-foundation-r5 --out /var/tmp/admission-new
python3 experimental/alignment-3.17/tests/prove_admission.py --engine /var/tmp/admission-new --out /var/tmp/admission-minimum --subprogram Check_Dofs
python3 experimental/alignment-3.17/tests/prove_admission.py --engine /var/tmp/admission-new --out /var/tmp/admission-whole --whole-admission
/path/to/mujoco317/bin/python experimental/alignment-3.17/tests/test_admission.py --engine /var/tmp/admission-new --out /var/tmp/admission-runtime --reference-source /path/to/pinned-mujoco317
```

Continue with Diagnose_Sparse, Diagnose_Assets and Validate caller proofs,
complete FLEX admission and renewed full foundation/corpus and historical
regressions with the overlay. Compact M/B/D domain differences, full engine
migration and integrated performance parity remain unresolved. These are scoped
proof/runtime results, not complete port or performance acceptance.
