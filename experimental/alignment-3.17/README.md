# Coordinated MuJoCo 3.17 foundation candidate

Official reference: [3.17.0, 22 October 2026](https://github.com/google-deepmind/mujoco/releases/tag/3.17.0),
commit `800a109a4bdd02cb60404d565db4ae16fb04a53b`.
The production pin remains 3.14; the separate 3.15 candidate and its evidence
remain reproducible. This candidate does not establish engine migration, full
functional Gold, or integrated C performance parity.

The generator recognizes the exact 3.14, 3.15 and 3.17 schemas. The 3.17 model
adds `nefmCvert`, `efmC_perm` and `tex_contenttypeadr`; `mjNEQDATA` is 12.
Its MJB fixed block contains three flags, including `flg_adhesion`, whereas the
older two ABIs contain two. Readers, size calculations, allocation/release,
reference clauses and the test serializer are generated together. The loader
publishes the serialized adhesion flag only when that ABI contains it.
`Without_Flex` also clears the new ordering size, and the 3D elasticity stride
stays 24 in both 3.15 and 3.17.

`Read_Flags` has a local contract specifying the exact decoded bytes; the scoped
proof evidence is recorded below. `Read_Fixed` composition, the full generated
readers and the caller proofs remain open on the candidate sources. Adding a
contract alone is not a successful proof.

The foundation runner has three explicit phases. Preparation copies and hashes
sources from the pinned checkout. Generation compiles/runs the real header
dumps, regenerates the Ada closure, applies the required 3.17 validation overlay
and compiles corpus images with the actual official wheel. Verification runs
all ten existing Ada suites, exact ABI comparisons, generation reproducibility
and the existing Python tests. Each phase retains commands, logs and hashes;
a failed command stops that phase. No corpus input or failed case is silently
removed to establish acceptance. Both build profiles retain runtime checks.

```sh
python3 experimental/alignment-3.17/tests/build_foundation.py --phase prepare --out /var/tmp/align317-new --reference-root /path/to/official-3.17-checkout
python3 experimental/alignment-3.17/tests/build_foundation.py --phase generate --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python --mode validation
python3 experimental/alignment-3.17/tests/build_foundation.py --phase verify --out /var/tmp/align317-new --python /path/to/mujoco317-venv/bin/python --mode release
```

The ABI fixtures distinguish the actual new behavior: an adhesive geom with
the third flag set, automatic/explicit welds with 12 data values, a 1D elastic
rod with a nonempty sparse metric ordering, embedded and by-reference textures,
and an ordinary model. The probe compares decoded arrays bitwise and checks
byte roundtrips. Two deliberately forged old headers must be rejected.
Three additional scenarios corrupt the owned model after raw decoding and
exercise `Validate`: permutation entries below -1 or at `nv`, and an external
texture without a path. They are identified separately from C-produced images.
The permutation mutations use a nonflex model so the existing unsupported-flex
guard cannot mask the field being tested. This is test setup, not a change to
the public admission domain.

The validation overlay adds current texture and permutation semantics. Sparse
validation and the remaining 3.16/3.17 engine changes must be audited and covered
before production adoption. Latest-stable alignment includes the actual
producers, integration paths, resources and public APIs; accepting the new ABI
alone does not complete that work.

## Initial validation checkpoint, 24 October 2026

Frozen foundation r3 passes all ten Ada suites, all 72 existing Python tests,
generation reproduction and 12 ABI scenarios, with the source closure unchanged.
All 100 official/fixture corpus images decode raw; validated loading agrees with
49 accepted models, 36 expected unsupported-flex rejections and 15 expected
unsupported-plugin rejections. These are foundation results, not 100 supported
physics simulations.

The `Read_Flags` minimum closes 14 proof and four flow checks on 3.17 and ten
proof and four flow checks on 3.14, without open obligations or warnings. The
contracts specify the exact flag bytes and the legacy absent-adhesion result.
Complete fixed-block, loader and engine Gold remain open. The first proof-driver
attempt rejected a successful prover report because it recognized only the body
location; the renewed driver also verifies the unique matching specification
location. Both attempts are retained.

The first complete ABI comparison retained five failures caused by test output
joining negative integers to their field labels. Explicit separators corrected
the transport; the new immutable run passes every case without changing engine
code, guards, data or tolerances. Earlier fixture preparation also retained two
rejected designs: actuator adhesion does not set the geom/pair adhesion flag,
and an ordinary 2D flex does not allocate the new sparse ordering. The final
cases use an adhesive geom and a 1D elastic rod, following the real C producers.

Checked/release runtime regression and additional scoped proofs are separate
acceptance steps. The initial validation snapshot does not promote the
production pin or establish integrated performance.

## Reference-table audit and known C regression

The first generator regex silently omitted `flex_vertedgeadr`, whose target is
`nflexedge*2`. The replacement parses every complete X row or rejects the table;
its regression test compares the ordered row names with an independent count
from the actual C macro and covers the multiplied target explicitly. The
pinned sources contain 96 reference rows in 3.14, 95 in 3.15, and 98 in 3.17.
The first 3.17 candidate represented 97. An audit initially assuming 99 was
rejected and retained; the source, rather than that assumption, determines the
required count. Multiplied target/count/address arithmetic is emitted in Int64.
The additional reference and its callers require fresh validation evidence.

The 3.17 C validator also rejects a fixed tendon containing two terms on the
same joint when `nv=1`: `ten_J_rownnz` is 2, although its nonstrict column list
`[0,0]` is valid. The identical XML compiles, saves, reloads and runs on C 3.15.
Controls with a merged term or a second DOF pass on C 3.17, isolating its new
`rownnz <= nv` check. The port retains duplicate-capable nonstrict tendon CSR;
this confirmed upstream regression is not reproduced by narrowing Ada's domain.
The local evidence records the unmodified wheel hashes, XML, command outcomes
and controls. No upstream PR has been published for this investigation.

C 3.17 adds other sparse/ancestry admission checks that still require an audit
against the port. The current ABI candidate therefore does not claim whole
validation equivalence or completed latest-stable engine alignment.

## Complete parser checkpoint r5, 24 October 2026

The renewed immutable candidate passes both validation and release: ten Ada
suites, 77 Python tests, 12 ABI scenarios, eight direct boundary cases of the
wide reference target, and deterministic regeneration in each profile. All
98 actual C reference rows are represented. The corpus remains 100 raw models
with the 49/36/15 admitted/flex-rejected/plugin-rejected split above.
The r4 negative boundary probe incorrectly expected Integer'Last to fit below
2*Max_Size, although Max_Size is 2**27-1. Its failure is retained. Only those
expectations changed for r5; the generated runtime predicate was preserved.

Production 3.14 passes its ten Ada suites in validation and release, plus the
72 existing Python tests in validation. The final production Ada source and
corrected project equal that regression snapshot; the five added parser tests
pass separately and in the full 3.17 runs. The already proved Read_Flags body,
contract, constants, byte reader, types and relevant declarations are byte
identical between r3 and r5; the dependency audit records this limited reuse.
The new reference predicate and complete validator do not inherit that flag
proof. All negative attempts and exact source objects are retained in the
verified evidence archive. Complete engine alignment, whole-loader Gold and
integrated performance acceptance remain open.

## Publication evidence, 24 October 2026

The [upstream source audit](evidence/20261024-upstream-source-audit/report.md)
compares the pinned 3.15 and 3.17 implementations; its
[archive](evidence/20261024-upstream-source-audit/source-audit.zip) retains the
source files, exact diffs, tag receipts and schema audit. The separate
[fixed-tendon reproducer](evidence/20261024-fixed-tendon-c-regression/reproducer.zip)
contains the unchanged C-wheel regression, controls and an unsubmitted proposed
patch. Publishing this repository does not submit an upstream pull request.

The [foundation r5 public evidence](evidence/20261024-foundation-r5/README.md)
retains deduplicated source snapshots, commands, logs, reports, XML and small MJBs,
with verified hashes. Its manifest explicitly lists omitted large generated MJBs
and executable payloads; the complete original archive is preserved locally.
