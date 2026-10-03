# Native public API facade and state services

Recovered from the original 2026-10-02 pre-crash workspace. The Ada namespace links existing native vectors, matrices, poses, kinematics, dynamics and owned data operations. New services implement state signatures, packed state extraction/set/copy, object-name hash tables and model/type queries. The official C library is used only as a test oracle.

This is a native Ada interface, not a binary-compatible C ABI or a complete MuJoCo implementation. State packing receives caller-owned arrays in C field order; it does not synthesize missing engine producers. Runtime renames retain the underlying engine's supported domains. Compilation, visualization/rendering, UI, plugin resources and other public gaps are explicitly queued in `inventory/README.md` and the 630-symbol JSON/CSV inventory.

Recovery validation passed 2,992 state/type/solver-info comparisons, six atomic invalid-input cases, 330 loaded-name comparisons (including UTF-8, NUL and invalid/absent names), and a runtime smoke test with source-model deletion, 100 steps, reset and repeated cleanup. The final rebuild and both differential corpora were renewed after the proof refactoring; final receipts and hashes are recorded separately.

The complete state unit now discharges 157 proof checks plus two flow diagnostics, with full SPARK coverage and zero open obligations. Functional properties cover exact ordered size/prefix relations, extraction/get semantics, block copy, preservation of previously extracted fields and failure atomicity. Set_State and Copy_State currently prove safety and error atomicity; their complete success/frame contracts remain to be strengthened. Names/model-info semantics, the runtime facade and the full engine composition still require their own proofs. No universal equivalence, whole-API Gold, or integrated performance claim follows from these results.

`Prefix_Size` has an exact static recurrence. `Prior_Blocks` and `Preserve_Matches` prove that copying one field leaves previously extracted fields intact. These ghost lemmas add no runtime scans. Provers check their bodies; no assumption or trusted helper replaces a proof. Both build profiles retain runtime checks; proofs and tests use frozen source closures, one job and explicit watchdog limits.

```sh
python3 experimental/public-api/tests/build.py --out /var/tmp/api-repro --working-dependencies
/var/tmp/sparkling-movement-env/bin/python experimental/public-api/tests/differential.py --binary /var/tmp/api-repro/build/validation/bin/api_probe --out /var/tmp/api-state-compare
/var/tmp/sparkling-movement-env/bin/python experimental/public-api/tests/names.py --binary /var/tmp/api-repro/build/validation/bin/api_names_probe --out /var/tmp/api-name-compare
python3 experimental/public-api/tests/prove.py --out /var/tmp/api-copy-proof --only Copy_Block
python3 experimental/public-api/tests/prove.py --out /var/tmp/api-whole-proof
```
