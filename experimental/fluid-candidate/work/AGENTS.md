# Shared project instructions

## Priority: align with the latest stable MuJoCo

The user has made alignment with the latest official stable MuJoCo release a
project priority. Prioritize this alignment when planning and implementing work;
do not extend the translation against an outdated baseline without checking the
corresponding upstream changes.

- Last verified on 2026-09-23: [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0),
  commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
- The baseline found during that review was MuJoCo 3.12.0, commit
  `13827e9ee56f097f57acf69ae52b078f9839682d`. Recheck the latest stable release
  before migration; do not treat the development branch as a stable release.
- Known alignment work: unsigned extraction of pair/exclude signatures;
  `site_dataid` and coordinated model generation, layout, MJB loading and
  validation updates; new integrator and enable-flag values; explicit handling
  of differences in inertia pivot clamping versus the prototype's rejection policy.
- Update the pinned reference, version metadata, reference tests and affected
  contracts/proofs together. Document unsupported upstream features and deliberate
  behavioral differences. Do not claim alignment from a version bump alone.
- The reviewed dense matrix formulas and vector arithmetic were unchanged;
  vector AVX tail handling was reorganized. Preserve valid translated work while
  checking behavioral compatibility with the new reference.

Continue to apply the project's [verification policy](docs/verification-policy.md).
Existing proofs establish properties of their current contracts; they do not by
themselves establish compatibility with a newer MuJoCo release.
