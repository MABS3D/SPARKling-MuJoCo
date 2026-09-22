# Toolchain

| Tool | Version | How installed |
|---|---|---|
| Alire | 2.1.1 | zip from github.com/alire-project/alire releases, in `%LOCALAPPDATA%\Programs\alr\bin` (added to the user PATH) |
| gnat_native | 16.1.0 | `alr -n toolchain --select gnat_native=16.1.0` |
| gprbuild | 26.0.1 | `alr -n toolchain --select gprbuild` |
| gnatprove | 16.1.0 | not a toolchain component in Alire 2.1.1; pulled by the `gnatprove = "^16"` dependency of `alire.toml` on the first `alr build` |
| Python | 3.13.15 | `winget install Python.Python.3.13`, at `%LOCALAPPDATA%\Programs\Python\Python313\python.exe` |
| mujoco wheel | 3.12.0 | `python -m pip install mujoco==3.12.0` |
| C compiler for the table dumpers | gcc 16.1.0 (GNAT-FSF-builds) | the one bundled with `gnat_native`, invoked as `alr exec -- gcc`; the pre-existing MSYS2 gcc 12.2.0 at `C:\msys64` exits with status 1 on any input and is not used |

Alire settings: `toolchain.assistant=false`, `msys2.do_not_install=true`.
All build, prove, and test commands run from the repository root as `alr exec -- <tool> ...`;
the PowerShell scripts add the Alire directory to `PATH` themselves.

## Memory guard (read before running anything heavy)

On 2026-09-03 this machine rebooted without a clean shutdown (Kernel-Power 41) while compiling
the validator units: the Resource-Exhaustion detector logged `gnat1.exe` at 65 GB of virtual
memory. The pagefile here is fixed at 4 GB with automatic management off, so once one process
runs away the commit limit is exhausted and Windows goes down instead of killing the process.
Recommended (not applied by the tooling): enable automatic pagefile management or set the initial
size to 16 GB or more.

Root cause on the project side: with `-O2 -gnata` the GCC optimiser inlined whole-model contracts
at every call site of an element predicate. Fixes in the code: proof-only contracts carry
`Assertion_Policy (... => Ignore)` in the proof-heavy units, element predicates have O(1)
preconditions, whole-model clauses are `No_Inline`, and the generated readers use small helper
procedures. Measured afterwards: the four big units compile at `-O2` in 4 to 16 s using at most
352 MB.

Rules:
- On Windows, every build and proof goes through `tools/guarded.ps1 -CapMB <n> -TimeoutSec <s> -- <command>`,
  which kills the tool tree when any `gnat1`/`gnatwhy3`/prover process exceeds the cap, when the
  system's free commit drops below `-MinFreeMB` (default 12 GB), or on timeout. `prove.ps1`
  delegates to `tools/prove.py`, which proves one unit at a time with `-j1` by default, never `-j0`.
- `python tools/prove_report.py` reads the per-unit `.spark` results, because the guard's log
  only contains the watchdog lines. Never trust the exit code of `alr exec -- gnatprove` alone:
  when gnatprove is killed, `alr` prints `exited with code -1` and still returns 0. The gate
  `prove.ps1` passes `--checks-as-errors=on`, and the `.spark` files are the record.
- `tools/guarded.ps1` watches and kills only the descendants of the command it launched. The
  first version sampled every gnat process on the machine and killed them all, so a scratch
  measurement and a project proof running at the same time killed each other and reported each
  other's peak memory; any figure taken while two runs overlapped under that version is void.
- A new large unit is compiled alone at `-O0` and `-O2` under the guard before it joins a full build.
- Never run two gnatprove invocations on the same object directory at once: they corrupt each
  other's `.ali` files ("GG data after GG end marker") and every later unit fails in seconds.
  `--clean` does not remove them; delete `obj/development/gnatprove` and start over. A killed
  run can leave an orphan prover process (parent gone, a few MB); stop it before the next run.

## Record update chains (gnatwhy3 memory)

`gnatwhy3` generates the verification conditions before any prover starts, and its memory grows
far faster than linearly with the length of a chain of calls that each update one component of
the same record with many access components. Measured on an isolated 83-component record
(`gnatprove -j8 --level=2`, one subprogram at a time with `--limit-subp`):

| Shape | Result |
|---|---|
| 83 sequential `Alloc (G.X, N)` calls | killed after 240 s at 3.6 GB, no prover had started |
| 83 sequential `Free (G.X)` calls | killed after 240 s at 1.8 GB |
| 83 moves `L : Acc := G.X` then one aggregate | killed after 497 s at 5.6 GB |
| 83 sequential `Fill (G.X.all)` calls (reader shape) | killed after 240 s at 2.1 GB |
| one aggregate `G := (X => New_I32 (N), ...)` | 27 s, 183 MB, 85/85 proved |
| 11 chunk calls of 8 frees with cumulative postconditions | 7 s, 141 MB (chunk body: 9 s) |
| 11 chunk calls of 8 reads with the layout as Pre/Post | 38 s, 162 MB (chunk body: 31 s) |
| the whole readers unit with unchunked `Read_Sizes` (98 writes into `Sizes`) and `Read_Fixed` (about 200 writes into `Option`/`Visual`/`Statistic`) | killed after 44 s at 5.5 GB |
| the same two as drivers over chunk procedures of 8 writes | 135 s and 127 s, all checks proved |
| `Read_Arrays` as 30 calls updating `M.<Group>` in turn, Pre/Post `Valid_Layout (M)` | 17 minutes alone (24 MB translation, 1.6 GB) while every other subprogram of the unit took seconds |
| `Read_Arrays` over per-group locals but with 30 early returns each calling a nested procedure that frees the 30 locals | 26 MB translation, over 20 minutes: each call to the nested procedure carries a frame over all 486 arrays |
| `Read_Arrays` over 30 `Allocate_Read_<Group>` helpers, each preserving an earlier failure | isolated driver: 96 flow/proof checks proved in 661 s, 1,180 MB process-group RSS (GNATprove 16.1.0 on Linux, 2026-09-22); helper bodies require their own proofs |

The scalar-record case matters as much as the pointer case: `Sizes` has 98 integer components.
The chain length is not the only factor: the frame of each call grows with the size of the
state being updated (`Model` holds 486 arrays; so do 30 group locals taken together), so a
subprogram must not contain many calls whose effects cover that whole state, whether they
update a record component or a set of locals through globals.

Rules, implemented in `tools/gen.py` (`CHUNK = 8`):
- Allocation builds each group record with a single aggregate of allocating functions
  (`New_I32` ...), and `Allocate` builds the whole `Model` from per-group locals with one aggregate.
  `Read_Arrays` does the same through `Allocate_Read_<Group>` helpers: each helper
  allocates its group and reads only if no earlier error occurred. Its postcondition
  preserves the first error and cursor on an incoming failure. The driver makes 30
  calls, assembles `Model` once, and the loader frees it when the result is not OK.
  Pairing allocation and reading avoids a 60-call chain and 29 whole-model branches.
- Deallocation and the group readers run in chunk procedures of at most 8 arrays; the free chunks
  state cumulatively which arrays are null, the reader chunks carry the group layout as
  precondition and postcondition. `Read_Sizes` and `Read_Fixed` are drivers over chunk
  procedures of at most 8 scalar writes.
- Hand-written code follows the same rule: never more than about ten component-updating calls in
  a row on one record. When a unit's proof stalls with `gnatwhy3` growing and no prover running,
  isolate the subprogram with `-u <unit> --limit-subp=<file>:<line>` on a scratch copy first.

## Linux verification without sharing Windows build artifacts

`SPARKLING_BUILD_ROOT` selects the root of `obj/`, `lib/`, and the test `bin/`.
Its default is the repository root. Always select a separate root when using
Linux tools, to avoid mixing Windows and Linux ALI files, objects, and proof caches.
GNAT and GNATprove 16.1.0 are available as official GNAT-FSF-builds release archives;
the Alire gprbuild 26.0.1 crate uses the upstream gprbuild 26.0.0-1 binary archive.
Put those three `bin` directories on PATH before using the commands below.

On Linux, use `tools/guarded.py` in place of `tools/guarded.ps1`. It enforces an
address-space limit per process, a total RSS limit for the launched process group,
a timeout, and a 12 GB floor on available RAM. It kills only its own process group
and removes orphaned provers on exit. It does not change the Windows commit guard.
For example, with `SPARKLING_BUILD_ROOT` set to a separate absolute directory:

```sh
python3 tools/guarded.py --cap-mb 4000 --timeout 900 -- gprbuild -P tests/tests.gpr -XSPARKLING_BUILD_MODE=validation -j2 -p
python3 tools/prove.py --unit mj-mjb --unit mj-models --unit mj-mjb-readers -- --timeout=30
python3 tools/prove_report.py --unit mj-mjb --unit mj-models --unit mj-mjb-readers
python3 -m unittest discover -s tests -p 'test_prove_report.py'
```

The example proves three complete units and explicitly reports partial library
scope. Without `--unit`, `prove_report.py`
requires results for every package declaring subprograms and rejects missing,
stale, stopped, flow-only, or skipped reports. It also checks that the subprogram
names declared by each unit and its subunits appear in the report (these names
are distinct within the current units). This catches limited subprogram proofs
that GNATprove labels PROGRESS_PROOF without any skip_proof entries. The invocation
receipt described below also rejects line/region-limited analyses that retain
all entity names. Built-in
Unchecked_Conversion instances inside the trusted bit conversions have no
separate body reports. Warnings are counted separately
from unproved checks. `prove.ps1` forces a whole-library analysis and additionally
requires every report to be newer than the start of that invocation; limited
line/subprogram proofs use the guard directly for diagnosis and cannot pass
the complete-unit gate.

The loader rejects a buffer longer than `Natural'Last` with
`(Size_Out_Of_Range, Header, -1)` before allocating. Every generated reader requires
that length bound. After changing `tools/gen.py`, regenerate the checked-in units
with `python tools/gen.py`; in particular, the allocating Read_Arrays contract and
body must be updated together with the public per-group allocators.

`MJ.MJB.Parse` and `Load` use documented Hide_Info annotations to compose the
callee contracts without expanding Is_Valid, Valid_Layout, and All_Null. These
annotations remove available facts, not proof obligations; no Assume, Skip_Proof,
or False_Positive annotation was introduced. See `docs/proof-justifications.md`.
After an interrupted proof, compiler/flow artifacts were regenerated from scratch;
only matching Why3 goal sessions were retained as solver caches.

The floating-array helpers use `Bad = -1 or else Bad in A'Range`. Do not
replace this with `Bad in -1 .. A'Last`: a null array can have bounds such as
`0 .. -2`, so the latter wrongly excludes the success sentinel. The group-reader
regression tests cover such null arrays for both floating-point widths.


## Unified checks and bounded numeric kernels

`python tools/check_all.py --alire` is the local/CI entry point. With the native
compiler tools on PATH, omit `--alire`. It checks isolated regeneration, runs all
three build/test profiles and the C differential tests, exercises `mjinfo`, and
then proves the entire library. The corpus must first be available from
`python tools/oracle.py corpus` with the pinned MuJoCo wheel.

The PowerShell entry points delegate to Python so Linux and Windows use the
same coverage checks. `tests/run.py` derives its nonempty expected test list
from `tests/tests.gpr`, forces rebuilding and rejects missing/stale executables;
it also runs every `test_*.py` test and `tools/compare_blas.py`. All executable
projects honor `SPARKLING_BUILD_ROOT`. The Windows watchdog preserves spaces,
quotes and trailing backslashes in native arguments, including executable paths.

`tools/check_gen.py` regenerates in a temporary directory and compares the
result to the working sources, without editing them or requiring a clean Git
index. `tools/prove.py` analyzes complete units serially, checks each report
against that invocation's start time, verifies whole-library coverage and
rejects source changes during the run. Compatible Why3 solver sessions may be
reused; reports themselves must be fresh. Every annotation still needs a ledger
entry. The default memory cap remains 4,000 MB.

Every accepted `.spark` report also requires the `.invocation.json` receipt
written by `tools/prove.py`, recording the complete-unit command and source/report
hashes. GNATprove line/region-limited runs may still list every entity, so entity
coverage alone cannot certify completeness. The driver rejects those switches;
replacing a report or changing source content invalidates its receipt. Use
`tools/prove.py --unit mj-blas` for an explicitly selected complete unit, or omit
`--unit` to certify the whole library. Raw targeted GNATprove runs are diagnostic
and do not produce an accepted complete-unit receipt.
Before starting, the driver moves earlier reports and receipts into
`SPARKLING_BUILD_ROOT/proof-history/`; Why3 solver caches remain in place.
GNATprove may otherwise return failure for an old, unselected unit even when the
currently requested unit proves successfully. An explicitly selected-unit run
therefore leaves certificates only for its selected scope; previous results
remain available in the history directory.

The report gate also rejects bodies outside SPARK, including a specification-only
analysis. Its explicit exceptions are the existing file read/write routines in
`MJ.File_IO` and the two bit-to-floating-point conversions in `MJ.Bytes`. These
four trusted bodies are counted separately from proved checks; an unknown
analysis mode or a similarly named routine in another package fails the gate.
Reports containing `pragma Assume` are rejected as well.

The release library uses `-ffat-lto-objects` so its static archive contains
ordinary symbol definitions even when `ar` does not discover the LTO plugin.
The executable projects use `-flto -fuse-linker-plugin` at link time. See the
[GCC LTO documentation](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html).
The first bounded 3D kernels and their comparison tolerances are documented in
[numeric-kernels.md](numeric-kernels.md).


Validator proof boundaries use the same bounded-body strategy. The generated
reference, real and Boolean diagnostics first test their exact family predicate.
On failure they search chunks of at most eight arrays for the first offending
field, preserving table and index order. A chunk's OK result continues the
search; the outer procedure can return OK only from the initial predicate test.
All generated chunk procedures are included in the whole-unit coverage gate.
Each chunk requires only the non-null arrays and matching bounds it reads;
the outer procedure establishes those requirements from `Valid_Layout`.
The three generated family predicates combine their independent array checks
with Boolean `and`: each operand is safe from `Valid_Layout` alone. They evaluate
all arrays even on invalid input, and retain the same Boolean result. Diagnostics
still scan in table order to locate the first error. Structural predicates whose
later checks depend on earlier results retain short-circuit `and then`.

Capacity counts run in helpers over individual arrays. `Jacobian_Capacity` and
`Has_Positive` are pure expression functions shared by the implementation and
the validity predicates. Their bodies are proved independently; local Hide_Info
annotations let the composition use equal function applications without expanding
nonlinear arithmetic or quantifiers. Generated reference-composition annotations
and hand-written ones are listed in `docs/proof-justifications.md`.

Structural element predicates check the array ranges they consume before
indexing. In particular, graph edge counts are computed only after a widened
block-size check. Pair signatures are compared in 64 bits: the reference loader
rejects a signature with bit 31 set, and the SPARK validator preserves that
restriction without overflowing while checking an invalid pair.
Texture extents are checked as `height * width <= (length - address) / channels`
after checking the address, nonnegative dimensions and positive channel count.
For those integers this is equivalent to the original byte-count comparison,
while avoiding the larger intermediate product. Boundary regressions include
maximum integer dimensions, zero area, a zero channel count and a huge address.

Control range checks iterate `nu` channels; force and activation ranges iterate
`nactuator`. MuJoCo's `engine_forward.c` clamps `nu` control values. Using actuator
indexes for control arrays missed vector-actuator channels and could index beyond
an empty control array. Diagnostics now identify control, force and activation
range fields separately. Quaternion/vector preconditions test membership in the
array range before subtracting from its last bound, including extreme null bounds.
Their squared norms are evaluated in pure scalar helpers with Tier0 arguments
and Tier1 results, separating floating-point bounds from array indexing.

Generated real/Boolean family predicates compose shared array predicates.
Those helpers are proved separately; local Hide_Info annotations prevent their
quantifiers from being expanded once per model field while proving composition.
