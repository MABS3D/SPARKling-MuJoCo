# Proved gravity guard elimination

See [the report](../../../docs/force-guard-elimination.md).

`proof-closure.json` lists the 11 accepted local scopes (295 proof obligations, zero open). `evidence.zip` includes failed and superseded attempts explicitly, final and previous sources, compiler commands/flags/hashes, numerical results, and all timing sessions. Only `gravity_only` from `isolation-session1` and `isolation-session2` is adopted; the both-guard candidate is not. Its measured release binary SHA256 is `c2b105ab894fc1869366122cecfbe738190b963eabba0740cabf434ab54acb03`.

Archived scripts preserve the original absolute work paths; adjust these paths and the toolchain root when reproducing on another machine. All archive members are checked by SHA256.json. Existing unchanged dependency proofs are inherited from the scan-parity checkpoint at commit 677e7547; the new local proof totals do not count those old proofs again.
