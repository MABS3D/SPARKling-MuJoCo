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
- Every build and proof goes through `tools/guarded.ps1 -CapMB <n> -TimeoutSec <s> -- <command>`,
  which kills the tool tree when any `gnat1`/`gnatwhy3`/prover process exceeds the cap, when the
  system's free commit drops below `-MinFreeMB` (default 12 GB), or on timeout. `prove.ps1`
  already does this and runs gnatprove with `-j4`, never `-j0`.
- `python tools/prove_report.py` reads the per-unit `.spark` results, because the guard's log
  only contains the watchdog lines.
- A new large unit is compiled alone at `-O0` and `-O2` under the guard before it joins a full build.
- Never run two gnatprove invocations on the same object directory at once: they corrupt each
  other's `.ali` files ("GG data after GG end marker") and every later unit fails in seconds.
  Recover with `alr exec -- gnatprove -P sparkling_mujoco.gpr --clean`.
