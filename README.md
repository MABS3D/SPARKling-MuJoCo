# SPARKling MuJoCo

We might be a little mad: we want to port MuJoCo to Ada/SPARK.

MuJoCo is a sophisticated physics engine.
Rebuilding its engine in a language that lets us formally prove properties of the implementation is a way to spend our evenings.

This is an independent, early-stage project. It is not a complete simulator, an official MuJoCo distribution, or a drop-in replacement.

Ambitious? Yes. A little unreasonable? Probably. Let's see how much physics we can make explicit enough to prove.

[Latest checkpoint — 1 October 2026](docs/publication-2026-10-01.md): direct tendon Jacobian views, elastic/contact materials and isolated rigid collision routines.

[Previous checkpoint — 30 September 2026](docs/publication-2026-09-30.md): ball/free dynamics, spatial tendons, performance work, solver contracts and new isolated candidates.

[Previous checkpoint — 29 September 2026](docs/publication-2026-09-29.md): faster matrix-to-quaternion conversion and a verified scalar contact candidate.

[Previous checkpoint — 27–28 September 2026](docs/publication-2026-09-28.md): implementations, isolated candidates, proof status and C comparisons.

Maintained by [MABS3D](https://github.com/MABS3D). See [contributor and upstream attribution](CONTRIBUTORS.md).
