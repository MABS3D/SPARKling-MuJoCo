# SPARKling MuJoCo

**We might be a little mad: we want to port MuJoCo to Ada/SPARK.**

MuJoCo is a sophisticated physics engine. Rebuilding its engine in a language
that lets us prove properties of the implementation is an ambitious way to spend
our evenings. We are doing it anyway, one small, testable piece at a time.

The goal is a SPARK port of the MuJoCo engine and its visualization geometry,
with explicit contracts, checked data flow, proofs of runtime safety, and
numerical comparisons against the original C implementation.

This is an independent, early-stage project. It is not a complete simulator,
an official MuJoCo distribution, or a drop-in replacement.

## What exists today

- Ada model types and generated structures based on the MuJoCo C tables.
- Binary `.mjb` loading, allocation, cleanup, and model validation.
- Structural and numeric validity predicates, capacity calculations, and
  diagnostics for malformed models.
- Four initial bounded numeric kernels: `Add3`, `Sub3`, `Scl3`, and `Dot3`.
- Corpus tests, corruption tests, proof-report checks, reproducible generation
  checks, and a differential harness that compiles the actual MuJoCo C kernels.
- Development, validation, and release build profiles, with resource guards
  around expensive builds and proofs.

The validator and its proofs are actively being refactored. This snapshot does
**not** claim a complete, passing whole-library proof. Passing tests or a proof
of one function must not be presented as verification of the entire engine.

The numeric comparison suite contains 2,102 input cases and 21,020 scalar
comparisons for the four implemented kernels. These are correctness checks,
not performance benchmarks. We have not demonstrated a speed advantage over C.

## The approach

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

1. Finish the foundation and validator verification.
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

The `mujoco/` submodule pins MuJoCo **3.12.0**, commit
`13827e9ee56f097f57acf69ae52b078f9839682d`.

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
python -m pip install mujoco==3.12.0
python tools/oracle.py corpus
```

Run the combined generation, build-profile, test, tool, and proof checks:

```sh
python tools/check_all.py --alire
```

If the native tools are already on `PATH`, omit `--alire`. Set
`SPARKLING_BUILD_ROOT` to place build artifacts outside the source tree.
The checks intentionally fail when required proof reports or test executables
are missing, stale, or incomplete. The full proof gate is still a development
target, not a promised green build for this work-in-progress snapshot.

## Contributions

Small, reviewable changes are welcome: a bounded kernel with a useful contract,
a reproducible mismatch against C, a better invariant, or a regression test for
a malformed model. Keep verification claims scoped to the evidence and explain
any numerical tolerance.

The project declares Apache-2.0 in `alire.toml`. Upstream MuJoCo and its bundled
dependencies retain their respective licenses and notices in the submodule.

Ambitious? Yes. A little unreasonable? Probably. Let's see how much physics we
can make explicit enough to prove.
