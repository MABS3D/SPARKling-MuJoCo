# Local native mass reader: disjoint path r278

All work remains local and uncommitted. HEAD is unchanged. The C 3.17 reference is
`800a109a4bdd02cb60404d565db4ae16fb04a53b`; production remains 3.14.

The reader now has a separately specified disjoint path. Every used native slot
equals the corresponding Mass_Entry of the current simulation cache; unused
slots are exactly zero. The shape boundary returns Success exactly for compatible
dimensions, and Invalid_Size with an entirely zero output otherwise. A default
pattern remains a valid public input and is safely rejected. The public domain
was not narrowed. Internal helper preconditions are Static, and the layout and
pattern lemmas are Ghost Static: they introduce no new executable scans.
The public Evaluate contract now publishes this disjoint behavior. The shared
CRB implementation is a separate private subprogram with its prior numeric
operation order; it still lacks a complete functional proof.

The normal path reuses the already computed dense mass, as before. Its branch
no longer enters the shared CRB composite-buffer declaration. The helper
extraction changes source structure; the release object has no separate
Gather_Current/Gather_Disjoint or ghost symbols. The shared subprogram may
remain separate. This is not timing evidence or integrated C parity.
C inverseFD copies its nC native mass values after inverseSkip, while the current
Ada scratch pipeline still publishes a dense mass cache before this projection.

The following minimum subprogram scopes close on the same frozen final source:

| Scope | Proof checks | Flow checks | Open |
| --- | ---: | ---: | ---: |
| Reveal_Mass_Layout | 1 | 1 | 0 |
| Gather_Current | 17 | 2 | 0 |
| Reveal_Pattern | 2 | 1 | 0 |
| Capture | 3 | 3 | 0 |
| Capture_Validated | 5 | 3 | 0 |
| Gather_Disjoint | 16 | 3 | 0 |
| Evaluate | 27 | 3 | 0 |

These counts are separate minimum scopes, not a summed whole-unit proof.
The inherited structural recursion/variant warnings remain recorded in each
reached scope. obligations_closed=true; strict passed=false wherever warnings
remain. No warnings were suppressed, and no assumptions, skipped obligations
or new trusted bodies were introduced. The constructor unit from r245 and the
pattern/storage kernel units remain separate evidence under their own contracts.

The initial Capture run exceeded the 2500 MiB group limit. Abstracting already
specified model predicates closed its checks without changing executable code.
An initial pattern lemma lacked the consistency requirement for a private local
helper: local helpers do not automatically inherit the public type boundary.
Its explicit internal precondition now carries that already guaranteed fact.
Two attempts at the old Evaluate callsite exceeded the same group limit, even
after abstracting predicates. Separating the shared CRB subprogram then closed
the complete public wrapper: 30 checks with about 1659 MiB peak group RSS.
This closes the two caller preconditions and the disjoint public postcondition,
but not the shared callee implementation or whole Data.Native_Mass unit.
The first minimum driver also selected both the local declaration and body;
it now selects the body. Failed attempts, source versions and logs are retained.
All final attempts keep one job, 3 seconds/650 MiB per prover, a 2500 MiB group
limit and a 240 second aggregate watchdog.

Both validation and release pass the full unchanged numerical suite:

- C3.17: 288 raw mass states with zero difference, 960 original derivative
  samples and 960 reordered derivative samples per profile.
- C3.14: 132 raw states and 960 derivative samples per profile at the existing
  tolerances. Its distinct validator is not automatically covered by the
  candidate-specific constructor proof.
- Four malformed-model scenarios and five reader-shape scenarios per
  profile/version. The latter exercise empty pattern, shifted, short and long
  outputs plus a valid output after freeing the source model; mass cache
  readiness/currentness is preserved.

The reordered oracle is the original C model plus a checked Mq column
bijection. The known direct C Newton/sparse reordered-storage crash and the
C3.17 duplicate-tendon compiler rejection remain separately recorded controls.
Shared raw mass cases are differential tests only; the derivative workspace
still rejects shared-buffer dynamics. C3.17 actuator-reflected armature and
other new engine behavior are not established by the shared legacy fallback.

This checkpoint proves projection of a ready current cache under its callee
contracts. It does not prove the physical correctness of that cache, a binding
between a captured pattern and the simulation model, the full shared reader,
workspace/Forward composition, complete stable-version migration or performance
parity. These remain open engineering work, not mathematical Silver exceptions.

Reproduce by preparing a fresh closure with tests/build.py --prepare-only,
using the verified 3.17 --foundation. Run prove_reader.py --only for each
listed minimum. The archived orchestration scripts build validation/release
and run the frozen check_native_mass.py and compare.py drivers against the
pinned 3.17 and 3.14 environments, including reordered 3.17 tests. Fresh final
trees borrow copied compiler caches only after checking source identity;
the two changed Ada files must be recompiled in each profile. No hard links
are used and the previous snapshots remain unchanged. The snapshot
manifest must match both proof evidence and actual runtime source hashes.

The ZIP retains all attempts, final source closure, test data/results and exact
commands. Compiler/proof caches are excluded; untimed ELF outputs are hashed
as local omissions. Verification independently rereads all archive members
and preserves every previous evidence-inventory entry.
