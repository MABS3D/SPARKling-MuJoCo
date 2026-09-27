# Rejected direct compact mass prototype

The prototype is **not enabled** in the active simulator. Its multi-DOF movement
regressions are documented in [the experiment report](../../../docs/compact-mass.md).
The proved `MJ.Compact_Inertia` helper and its standalone test remain available
for future integration work.

`evidence/rejected-prototype-source.zip` contains the tested integration and its
original builder/harness. The numerical and performance archives refer to that
snapshot, not current sources. `prototype-snapshot-match.json` records the source
match before the integration was reverted. `proof-index.json` includes failed
attempts and the two unresolved assembly interface checks. No timeout or empty
proof invocation is a pass.

The baseline sources are now shared with `../bounds_validation/baseline` and
pinned to commit `bf265c8f544e8e151c62a30634cd1d44ea613c3d`. To reproduce the old
prototype, extract its source in a separate checkout, restore that baseline next
to its archived builder, and supply the same hash-pinned C reference. The
remaining `check_paths.py` instruments the archived prototype only.

The current standalone helper test is built by `../bounds_validation/build.py`.
It independently walks parent chains for empty, singleton, chain, star, forest
and 256 independent DOFs, and checks structural zeros, symmetry, nonzero array
bounds, exact projected values and rejection of oversized projections.
