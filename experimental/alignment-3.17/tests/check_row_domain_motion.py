"""C-only fixture control for disjoint CSR permutations; no performance claim."""
import argparse
import hashlib
import json
from pathlib import Path
import mujoco
import numpy as np
from test_admission import CHAIN, TENDONS, rearrange_sparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
assert mujoco.__version__ == '3.17.0' and mujoco.mj_version() == 3_017_000
assert not args.out.exists()
records = []
for stem in ['M', 'B', 'D', 'ten_J']:
    xml = TENDONS if stem == 'ten_J' else CHAIN
    original = mujoco.MjModel.from_xml_string(xml)
    changed = mujoco.MjModel.from_xml_string(xml)
    rearrange_sparse(changed, stem, 'reverse')
    first, second = mujoco.MjData(original), mujoco.MjData(changed)
    maximum = 0.0
    for step in range(32):
        force = np.array([1., -2., 3., .5]) * (1 + step / 64)
        first.qfrc_applied[:] = force
        second.qfrc_applied[:] = force
        mujoco.mj_step(original, first)
        mujoco.mj_step(changed, second)
        for name in ['qpos', 'qvel', 'qacc']:
            before, after = np.asarray(getattr(first, name)), np.asarray(getattr(second, name))
            assert np.all(np.isfinite(before)) and np.all(np.isfinite(after))
            maximum = max(maximum, float(np.max(np.abs(before - after))))
            assert np.allclose(before, after, rtol=1e-13, atol=1e-13), (stem, name, maximum)
    records.append(dict(stem=stem, steps=32, max_absolute_state_difference=maximum, passed=True))
result = dict(reference=mujoco.__version__, passed=True, cases=records,
              runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              mutation_runner_sha256=hashlib.sha256(Path(__file__).with_name('test_admission.py').read_bytes()).hexdigest(),
              scope='C disjoint-permutation controls only; shared spans are admission-only. No Ada simulation or timing claim.')
args.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(passed=True, cases=len(records))))
