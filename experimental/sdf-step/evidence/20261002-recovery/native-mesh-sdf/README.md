# Reproducible native reference failure

MuJoCo 3.14.0, reference commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
The standalone C replay loads XML or MJB and invokes the official library
without Ada or Python participating in dynamics. The library and input hashes
are in `manifest.json`; the compiler command and logs are retained.

The original mesh/SDF pair reports six contacts against a `pairMaxContact`
budget of four on its initial `mj_forward`. A reduced tetrahedral mesh (four
vertices) against a sampled cube SDF reproduces the discrepancy with zero
velocity/forces and no time steps: `sdf_initpoints=1` returns two contacts
against a budget of one. `tetra-4.xml` is a control that completes.

The C diagnostic is at `engine_collision_driver.c:2033`. The Python binding
process instead aborted with heap-corruption diagnostics while trying to
handle this same native error. This receipt establishes a reference failure;
it is not a passing Ada/C differential case and does not establish the exact
heap-write location. No reference source was patched or exception suppressed.

Run the compiled C replay with `reduced/tetra-1.xml reduced/zero.input`; it
returns exit status 1 and the recorded native diagnostic.
