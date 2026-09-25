# SPARKling MuJoCo

We might be a little mad: we want to port MuJoCo to Ada/SPARK.

MuJoCo is a sophisticated physics engine.
Rebuilding its engine in a language that lets us formally prove properties of the implementation is a way to spend our evenings.

This is an independent, early-stage project. It is not a complete simulator, an official MuJoCo distribution, or a drop-in replacement.

Ambitious? Yes. A little unreasonable? Probably. Let's see how much physics we can make explicit enough to prove.

## Project status and navigation

The active development branch is **`spark-port`**. The port targets the pinned
MuJoCo **3.14.0** reference in the `mujoco/` submodule.

- [Verification policy](docs/verification-policy.md): Gold wherever possible;
  unfinished proofs remain explicitly pending.
- [Latest dynamics work and measured results](docs/c-parity-six.md): six C-inspired
  optimizations, numerical validation, proof scope, and remaining performance gaps.
- [Matrix kernels](docs/matrix-kernels.md) and [pose kernels](docs/poses.md).
- [Experimental smooth dynamics](experimental/smooth/README.md) and
  [collision experiments](experimental/collision/README.md).
- [Repository layout and archived branches](docs/repository.md).

C performance parity is **not yet achieved**: the latest supported movement
benchmarks take about **1.4–3.1 times** the C reference time. Proven kernel
contracts do not establish a complete proof of the experimental simulator.

Clone with the reference dependency:

```sh
git clone --recurse-submodules https://github.com/MABS3D/SPARKling-MuJoCo.git
```

See [contributors and upstream attribution](CONTRIBUTORS.md) and [LICENSE](LICENSE).
