This project: COMPLETE PORT!!!!!



\- Code is in the SPARK subset, data flow is analyzed: no uninitialized reads, no aliasing, no hidden side effects. 

\- Proved absence of runtime errors: no buffer overruns, no division by zero, no invalid operations.

\- Proved key invariants: sparse index structures are well-formed, contact counts stay within bounds, solver iterations terminate.





Keep attention high on:

\-The mjData layout

\-Floating point

\-Collision



The architectural key: a proven model validator. Every runtime proof hinges on "the model's index arrays are well-formed." So you write one SPARK-proved validation pass that runs once at model load, express validity as type predicates, and let every downstream proof assume it. This verified-checker pattern is what makes the whole thing tractable you validate the compiler's output instead of proving the compiler.


Performance doctrine (2026-09-23): every component must be benchmarked against
the corresponding MuJoCo C implementation while it is being built. Require at
least parity within measured noise, or faster; never accept a confirmed slowdown
as completed work. Check the smallest subprograms first and repeat the comparison
as integration progresses. Numerical differential tests do not replace timing
measurements, and optimizations must preserve the formal contracts. Missing or
inconclusive performance evidence remains pending. See
[verification policy](docs/verification-policy.md#performance-against-the-c-reference).
