# C algorithm audit

Read [the interpretation and applicability](../../../docs/c-dynamics-algorithm-audit.md).
This receipt accompanies a source audit of the pinned MuJoCo 3.14.0 reference.
It contains no new performance measurements and no SPARK proof claims.

* `results.json` records source and oracle-library hashes, topology, source-level
  loop counts, and the CRB scalar reconstruction checks. Candidate counts describe
  unimplemented alternatives, not executed optimizations.
* `fixtures/` retains the three XML models and nine initial states from the
  whole-step benchmark. Each is checked over 100 evolving states: 900 matrices,
  27,900 stored elements, zero observed absolute error in this run.
* `algorithm_audit.py` is the exact script snapshot. Run the maintained script
  one directory above this folder; the snapshot is for provenance, not execution
  from a different directory hierarchy.
* `manifest.json` hashes every other file here.

The mirror consumes `cinert` and `cdof` computed by the Python package's C
library. It validates a reconstruction of CRB, not an independent kinematics
implementation or an implemented SPARK CRB. It uses the numerical oracle
package, not the native timing library; both are MuJoCo 3.14.0. Operation counts
for the Ada source and the C source do not compare identical primitive operations
and must not be converted into speedup claims. Counts assume successful steps
and the enabled damping present in these fixtures.

Reproduce from the repository root with the existing Python environment
containing `mujoco==3.14.0` and NumPy:

```sh
python tests/movement_performance/algorithm_audit.py \
  --fixtures tests/movement_performance/algorithm_evidence/fixtures \
  --out /var/tmp/sparkling-algorithm-audit-new
```

The output directory must be new. The script checks the pinned upstream commit
and that the four examined C source files are unchanged. Numerical assertions,
fixture scope checks and topology/count checks must all pass. Changes to the
Ada algorithms require reviewing the count formulas as well as their hashes.
