# Compatible solver reduction

`MJ.Solver_Reductions.Forward_Value` replaces the final forward substitution's
single dependent sum on rows with at least four ancestors. Empty rows return
the original right-hand side directly; one to three ancestors use the original
scalar order and checks, matching C's scalar tail without preparing SIMD lanes.
Longer rows use the four lane reduction, subtract it from the right-hand side,
and return a bounded value plus an acceptance flag. It never modifies factor storage,
solution storage, physical state, inputs, or diagnostics. The caller publishes
the returned scratch entry only on success.

The reference is MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, specifically
`mujoco/src/engine/engine_util_sparse_avx.h:mju_dotSparse_avx` and the scalar
fallback in `engine_util_sparse.h`. The implemented order is:

1. Initialize lanes 0–3 directly from the first four products, when present,
   as in the native AVX implementation.
2. Accumulate subsequent blocks in four independent lanes.
3. Merge `(lane0 + lane2) + (lane1 + lane3)`.
4. Add each of the remaining zero to three products in index order.
5. Subtract the result from the right-hand side.

The operations are floating-point products/additions, with FMA and reassociation
disabled by the existing release policy. This order deliberately changes some
rounded results from the previous completely ordered sum. Its contract models
the chosen expression and branches; it does not claim equality to a real-number
dot product or bitwise equality to the previous Ada implementation. No signed
zero identity beyond Ada numeric equality is claimed.

## Preserved rejection policy

For rows with at least four ancestors, the four-lane path is used only when every product has absolute value at most
`2**176`, the original right-hand side has absolute value at most `2**196`, and
the candidate subtraction remains in `Work_Real`. All products can be computed
safely before this decision: two `Work_Real` inputs give a product bounded by
`1e121`; at most 255 products are accumulated in a domain far below floating
overflow.

`Fast_Prefix` proves equality to the former ordered recurrence and the bound
`abs(prefix(k)) <= k * 2**178`. `Prove_Fast_Domain` uses that bound to prove every
old prefix and its final subtraction are within `Work_Real` throughout the fast
domain. Thus a previously rejected cancellation cannot be turned into success
by choosing another addition order.

Outside that domain, `Dot_Ordered` preserves the previous prefix order and its
per-prefix `Work_Real` checks. A finite final cancellation still rejects if an
earlier prefix exceeded the accepted range. Failure returns `Value = 0`,
`Ok = False`; the caller retains the original state-publication protocol.

The product-threshold reduction counts integer rejected lanes. It does not use
the fused Boolean reduction affected by the previously observed compiler bug.

## Validation

Run `check_reductions.py --out <fresh-directory> --toolchain-root <toolchains>`.
The harness freezes the sources and builds both with assertions/index/overflow
checks and with the same optimized flags used for movement timings.

The 34,031 cases include every ancestor-row length from 0 to 255, contiguous and
non-contiguous ancestor maps, all tail lengths, positive/negative threshold
endpoints and their adjacent floating values, each bad lane in short rows and
around larger SIMD boundaries, wide finite products, and cancellation that
must reject an early prefix. Each case compares the exact chosen expression,
fallback output, and old acceptance status against independent scalar code.

The final source passed all 34,031 cases in each build in
`/var/tmp/sparkling-reductions-tests11`. Its optimized probe is byte-for-byte
identical to the preceding frozen runtime probe from tests10, SHA-256
`2be85f7bab70a31f7a5b53d2d0a360941f6b2bf462aed41946186679e70830d6`.
This identity applies to the reduction probe; the integrated executable has
its own source and binary checks and timing evidence.

The fresh complete-unit proof in `/var/tmp/sparkling-reductions-whole1`
closed **740 proof checks and 84 flow checks**, with zero unproved checks or
errors, in 357.6 seconds. This followed passing minimum-subprogram proofs,
including the final 158 checks for `Dot_Blocks` and 86 for `Dot_Four`.
Counts from those earlier invocations are not added to the whole-unit count.
The bounded product and accumulation, exact rounded lane/merge/tail models,
ordered fallback, termination, and acceptance equivalence are all covered.
`Forward_Value` proves both the chosen rounded output and equality of `Ok` to
the former ordered algorithm's acceptance decision, under `Valid` and the
declared argument subtypes. Its immutable inputs and absence of global effects
are checked. Caller preconditions and complete simulation/state correctness
remain separate integration obligations.

The final proof uses only proved ghost lemmas, local hiding of expression-body
details, and proved `Assert_And_Cut` boundaries. No new assumptions, suppressions,
or trusted arithmetic bodies were introduced. The expression bodies themselves
are included in the complete-unit proof. These annotations do not establish
error bounds against an ideal real dot product or physical stability.

Reproduce the proof with the recorded GNATprove 16.1 toolchain:

```sh
python3 experimental/smooth/tools/prove_fragments.py \
  --whole-unit mj-solver_reductions --report-dir <fresh-directory> \
  --toolchain-root <toolchains> --wall-seconds 600 --prepare-seconds 600 \
  --total-seconds 720 --prover-seconds 15 --steps 0 \
  --provers cvc5,z3,altergo --jobs 4 --cap-mb 4000
```

The final package source hashes are
`a37af1670c08f37b732a17ce19f7ebe64e935a6e183f9a3bb768d995ee1e1305`
for the specification and
`1b94c9637db165f5402c15af708cc3c8697a8e47879958e41d531cd8987793d7`
for the body. Frozen proof sources, complete logs, test inputs/results, and
earlier diagnostics are retained in the [combined evidence](evidence/README.md).
Earlier failures and timeouts are diagnostic history, not Gold evidence;
tests1 also timed out and is not a pass.

The integrated movement harness remains the performance acceptance test.
Independent accumulation lanes and observed vector products are code-generation
facts; neither alone establishes a speedup for the complete step.
