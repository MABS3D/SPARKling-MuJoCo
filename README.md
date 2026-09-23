# SPARKling MuJoCo

**We might be a little mad: we want to port MuJoCo to Ada/SPARK.**

Author and maintainer: **[MABS3D](https://github.com/MABS3D)**.
See [contributors and upstream attribution](CONTRIBUTORS.md).

MuJoCo is a sophisticated physics engine. Rebuilding its engine in a language
that lets us prove properties of the implementation is an ambitious way to spend
our evenings. We are doing it anyway, one small, testable piece at a time.

The goal is a SPARK port of the MuJoCo engine and its visualization geometry,
with explicit contracts, checked data flow, proofs of runtime safety, and
numerical comparisons against the original C implementation.

This is an independent, early-stage project. It is not a complete simulator,
an official MuJoCo distribution, or a drop-in replacement.

Current upstream baseline: **MuJoCo 3.14.0**. See the [migration record](docs/mujoco-3.14-alignment.md) for changes and fresh evidence. The older vector/foundation counts below describe the 3.12 snapshots.

## Languages

| Language | Role in this project |
| --- | --- |
| **Ada / SPARK** | Ported engine components, functional contracts, ghost models, proofs and Ada tests. SPARK is reported as Ada by GitHub. |
| **Python** | Code generation, test and proof orchestration, and numerical comparisons. |
| **PowerShell** | Windows build, test and proof entry points. |
| **C** | Small reference probes and layout extractors used to compare the port with MuJoCo. |

GPR files define the Ada projects and build profiles. GitHub language statistics
exclude the upstream `mujoco/` reference, generated Ada files and archived proof
evidence through [.gitattributes](.gitattributes); the port's C test probes remain
classified as C.

## What exists today

- Ada model types and generated structures based on the MuJoCo C tables.
- Binary `.mjb` loading, allocation, cleanup, and model validation.
- Structural and numeric validity predicates, capacity calculations, and
  diagnostics for malformed models.
- 35 bounded dense vector kernels (3D, 4D, and generic length), plus two
  scalar helpers, with proved functional contracts.
- 17 dense matrix kernels covering fixed 3x3 and generic matrices, with proved
  functional contracts; see the [matrix verification snapshot](#dense-matrix-verification-snapshot).
- Separate [collision](experimental/collision/README.md) and
  [smooth dynamics](experimental/smooth/README.md) prototypes, with their own
  documented verification scope and remaining work.
- Corpus tests, corruption tests, proof-report checks, reproducible generation
  checks, and a differential harness that compiles the actual MuJoCo C kernels.
- Development, validation, and release build profiles, with resource guards
  around expensive builds and proofs.

The earlier foundation snapshot of 2026-09-23 passed the complete proof gate
for its ten core units: 11,416 checks, no unproved obligations, and 142 reviewed
warnings. Four application bodies remain trusted, and five standard deallocator
instances use GNATprove's memory model. Those historical totals belong to that
snapshot and are not certificates for the subsequent vector source changes.

The vector increment passes complete-unit verification of `MJ.BLAS` and
`MJ.Vector_Models`: **749 checks, zero unproved obligations, and 29 reviewed
warnings** about the runtime square-root model and recursive ghost definitions.
All vector kernels have proved functional properties in addition to safety.
Recursive-model bodies and unfolding lemmas are proved; no assumptions or
proof suppressions were added. The square-root accuracy boundary and per-kernel
properties are documented in [numeric-kernels.md](docs/numeric-kernels.md).

On identical frozen verification sources, all three build profiles pass
**983 Ada assertions across nine executables, 62 Python tests, and 742,493
scalar comparisons against C over 3,643 cases each**. The reference is compiled
from the pinned MuJoCo sources. These are correctness checks, not performance
benchmarks; no speed advantage over C has been demonstrated.

This increment was checked on x86-64 Linux/WSL with floating-point contraction
disabled. Windows/Alire still needs verification. The older foundation units
have not been re-proved for the new global source hashes, and prototypes under
`experimental/` are outside the scope of these vector results.

## The approach

Target **SPARK Gold wherever possible**: prove useful functional properties in
addition to Silver runtime safety. Silver-only coverage is an explicitly
documented exception for mathematical or research limitations, not a shortcut
around unfinished proof work. See the [verification policy](docs/verification-policy.md)
for immediate vector priorities and the distinction between floating-point
behavior and accuracy over the reals.

Start with a model validator. Establish the layout and index properties that
the simulation code will need, then express those requirements in contracts.
Build the numerical and physical routines on that foundation, checking each
increment against C as it becomes usable.

Formal verification establishes the properties we specify; it does not
automatically establish physical correctness, numerical equivalence, or solver
convergence. Differential tests and numerical analysis remain essential.

The current explicit trusted code boundaries include file I/O and two
bit-to-floating-point conversions. Proof-context annotations are documented in
[the justification ledger](docs/proof-justifications.md).

## Where we are going

1. Keep the foundation proofs and tests passing, add CI, and verify Windows.
2. Extend the numeric kernels: spatial algebra, quaternions, sparse operations,
   and factorizations.
3. Build `Data`, state management, unconstrained dynamics, and integration.
4. Add collision detection, contacts, constraints, and solvers.
5. Expand sensors, state APIs, inverse dynamics, and other engine services.
6. Tackle advanced features such as derivatives and implicit integration.
7. Port visualization geometry and measure performance against C.

We intend to grow through working examples, starting with simple systems
without contacts, rather than waiting for every subsystem to be finished.
The ambitions in `bible.md` describe the destination, not the current status.

The initial target is binary64 and single-threaded execution. Flex and
plugin-dependent models are currently rejected. The upstream compiler produces
the binary models used by the tests; an XML compiler is not implemented here.

## Reference version

The `mujoco/` submodule pins MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

After cloning, initialize the reference sources:

```sh
git submodule update --init --recursive
```

The C differential harness also checks recorded hashes of its reference source
and headers. See [numeric-kernels.md](docs/numeric-kernels.md) for the contracts,
test inputs, and floating-point tolerances.

## Building and checking

Read [the toolchain notes](docs/toolchain.md) first. The project uses GNAT and
GNATprove 16, GPRbuild, Python, and a C compiler. Alire can resolve the Ada tools.
Proof workloads can be substantial; keep the resource guards enabled and use
separate build directories for independent runs.

Prepare the test corpus with the pinned Python reference package:

```sh
python -m pip install mujoco==3.14.0
python tools/oracle.py corpus
```

Run the combined generation, build-profile, test, tool, and proof checks:

```sh
python tools/check_all.py --alire
```

If the native tools are already on `PATH`, omit `--alire`. Set
`SPARKLING_BUILD_ROOT` to place build artifacts outside the source tree.
The checks intentionally fail when required proof reports or test executables
are missing, stale, or incomplete. Recheck the full gate after source changes;
the verification snapshot above is tied to specific source hashes. During
diagnosis, select the smallest affected subprogram before a final complete run.

## Contributions

Small, reviewable changes are welcome: a bounded kernel with a useful contract,
a reproducible mismatch against C, a better invariant, or a regression test for
a malformed model. Keep verification claims scoped to the evidence and explain
any numerical tolerance.

The project declares Apache-2.0 in `alire.toml`. Upstream MuJoCo and its bundled
dependencies retain their respective licenses and notices in the submodule.

Ambitious? Yes. A little unreasonable? Probably. Let's see how much physics we
can make explicit enough to prove.

## Dense matrix verification snapshot

The 17 dense matrix kernels have proved functional contracts. The five-unit
numeric gate passes **1,628 checks, zero unproved obligations and 54 reviewed
warnings** on the isolated MuJoCo 3.14.0 verification snapshot. The three new
matrix units contribute 879 checks. All three profiles pass 1,085 Ada
assertions, 72 Python tests and 1,028,505 C scalar comparisons each.
See [matrix contracts, domains and evidence scope](docs/matrix-kernels.md).
These results concern the frozen numeric snapshot; concurrent foundation and
vector optimization changes require their own verification. Performance parity
with C remains pending.
