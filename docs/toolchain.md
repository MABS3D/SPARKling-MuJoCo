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
