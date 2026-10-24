# Shared project instructions

## Priority: align with the latest stable MuJoCo

The user has made alignment with the latest official stable MuJoCo release a
project priority. Prioritize this alignment when planning and implementing work;
do not extend the translation against an outdated baseline without checking the
corresponding upstream changes.

- Last verified on 2026-10-24: [MuJoCo 3.17.0](https://github.com/google-deepmind/mujoco/releases/tag/3.17.0),
  released 2026-10-22, commit `800a109a4bdd02cb60404d565db4ae16fb04a53b`.
  The official tag and a fresh source checkout agree; the isolated reference
  wheel reports 3.17.0. These checks establish the reference, not port alignment.
  The production pin is 3.14.0 (`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`).
  Preserve the verified [3.15 candidate](experimental/alignment-3.15/README.md)
  (`9ea3cdfcae93bf2cc4dc0e1a1627c5a39a1e06e5`) as historical evidence while
  preparing the coordinated 3.17 migration.
- The 3.17 ABI requires coordinated handling of the third serialized MJB flag
  (`flg_adhesion`), `mjNEQDATA` 12, `nefmCvert`/`efmC_perm`, and
  `tex_contenttypeadr`. Confirm generated sizes, layouts and reference rules
  against the actual 3.17 headers and wheel before admitting its MJB files.
  Preserve exact decoding and rejection rules for older supported ABIs.
- The reviewed 3.15-to-3.17 sparse/cone update bodies are identical. Other solver
  behavior changed: Hessian allocation preflight/fallback, stopping scale from
  current mass trace, blocked symbolic factorization, and fused dense updates.
  Include these changes when assessing current-version behavior and performance.
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
