# Public API coverage inventory

`public-symbols.json` and the equivalent CSV enumerate 630 public symbols from the top-level MuJoCo 3.14.0 C headers: 609 functions, 12 callback hooks and 9 public data symbols. All 563 MJAPI declarations in mujoco.h are represented. The inventory also includes 63 Filament functions without the MJAPI marker and 26 plugin callback field contracts. Header hashes and the official stable commit are recorded.

The inventory is a work queue, not a completeness certificate. The 29 mappings (including the integrated RK4, implicit, discrete, inverse and finite-difference adapters) identify native Ada entry points or adapters and explicitly retain domain, integration, proof and performance limits. `unmapped` means the symbol has not yet received an audited mapping; existing lower-level implementation may exist elsewhere. `missing public entry` identifies compiler/specification, plugin-resource, visualization/rendering and UI surfaces not provided by this recovered API facade. Compiler address passes and the native callback runtime do not fill those whole surfaces.

Columns keep implementation, linkage, numerical tests and proofs independent. A comparison corpus is not a universal equivalence proof. A kernel proof does not imply the complete entry point is proved. The facade is a native Ada namespace; a binary-compatible C ABI is not supplied.

Remaining queue:

1. Audit and map every remaining engine/utility function to actual native implementation, then implement gaps and unify its owned-state entry point.
2. Link packed state APIs to all actual owned engine producers, rather than requiring the caller to assemble storage.
3. Port the public editable specification, complete MJCF/URDF compiler and resource/provider flows.
4. Implement public visualization, OpenGL/Filament rendering, UI and associated callbacks/context lifecycle.
5. Complete plugin registry/ABI/resources and connect native callbacks throughout supported producers.
6. Inventory the separately exposed experimental USD C++ headers and optional language bindings; they are not silently included in the stable C count.
7. Establish per-entry functional proof and numerical coverage, plus representative integrated performance on the completed paths.

Reproduce from a verified official reference checkout:

```sh
python3 experimental/public-api/tests/inventory.py --reference /path/to/mujoco/include/mujoco --out experimental/public-api/inventory
```
