"""Trace a persisted controller case, and reevaluate identical C states in Ada.

The C states are diagnostic inputs only, never values used by the implementation.
Each prefix starts from the original input; each matched-state evaluation resets
the adapter, retaining the original controls and applied forces.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import shutil

import mujoco
import numpy as np
from compare import parse


FIELDS = dict(length='actuator_length', velocity='actuator_velocity',
              force='actuator_force', qforce='qfrc_actuator', acc='qacc', dot='act_dot')


def state(data):
    return np.r_[data.qpos, data.qvel, data.time, data.act]


def input_line(data, steps):
    values = [steps, data.time, *data.qpos, *data.qvel, *data.ctrl, *data.act,
              *data.qfrc_applied, *data.xfrc_applied.ravel()]
    return ' '.join(format(float(value), '.17g') for value in values)


def errors(actual, expected):
    assert actual.shape == expected.shape
    return dict(exact=bool(np.array_equal(actual, expected)),
                bit_exact=actual.tobytes() == expected.tobytes(),
                passed=bool(np.allclose(actual, expected, atol=2e-10, rtol=2e-10)),
                max_abs=float(np.max(np.abs(actual-expected))) if expected.size else 0.)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--model', required=True)
    parser.add_argument('--sample', type=int, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    model_path = args.reference/(args.model+'.mjb')
    input_path = args.reference/(args.model+'.input')
    original = input_path.read_text().splitlines()[args.sample+1].split()
    shutil.copy2(model_path, args.out/'model.mjb')
    (args.out/'original-case.input').write_text('1\n'+' '.join(original)+'\n')
    values = list(map(float, original))
    steps = int(values[0])
    model = mujoco.MjModel.from_binary_path(str(model_path))
    data = mujoco.MjData(model)
    data.time = values[1]
    offset = 2
    for target in [data.qpos, data.qvel, data.ctrl, data.act,
                   data.qfrc_applied, data.xfrc_applied.ravel()]:
        target[:] = values[offset:offset+target.size]
        offset += target.size
    assert offset == len(values)
    prefix_lines = [str(n)+' '+' '.join(original[1:]) for n in range(steps+1)]
    matched_lines, wanted_states, wanted_evaluations = [], [], []
    mujoco.mj_forward(model, data)
    for n in range(steps+1):
        wanted_states.append(state(data).copy())
        matched_lines.append(input_line(data, 0))
        fresh = mujoco.MjData(model)
        fresh.time = data.time
        for field in ['qpos', 'qvel', 'ctrl', 'act', 'qfrc_applied', 'xfrc_applied']:
            getattr(fresh, field)[:] = getattr(data, field)
        mujoco.mj_forward(model, fresh)
        wanted_evaluations.append({key: getattr(fresh, field).copy()
                                   for key, field in FIELDS.items()})
        assert not np.any(fresh.warning.number)
        if n < steps:
            mujoco.mj_step(model, data)
            assert not np.any(data.warning.number)

    observed = {}
    for label, lines in [('prefix', prefix_lines), ('matched-state', matched_lines)]:
        text = str(len(lines))+'\n'+'\n'.join(lines)+'\n'
        (args.out/(label+'.input')).write_text(text)
        run = subprocess.run([str(args.binary), str(model_path), 'loads'], input=text,
                             text=True, capture_output=True, timeout=120)
        (args.out/(label+'.output')).write_text(run.stdout)
        (args.out/(label+'.stderr')).write_text(run.stderr)
        assert run.returncode == 0, run.stdout[-3000:]+run.stderr
        observed[label] = parse(run.stdout)
        assert len(observed[label]) == steps+1
        assert all(row['evaluate'] == row['step'] == 'SUCCESS' for row in observed[label])
    prefixes = [dict(step=n, **errors(got['state'], want))
                for n, (got, want) in enumerate(zip(observed['prefix'], wanted_states))]
    evaluations = [dict(step=n, errors={key: errors(got[key], want[key]) for key in FIELDS})
                   for n, (got, want) in enumerate(zip(observed['matched-state'], wanted_evaluations))]
    first = lambda records, predicate: next((row['step'] for row in records if predicate(row)), None)
    sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
    report = dict(reference=mujoco.__version__, model=args.model, sample=args.sample,
                  steps=steps, first_state_bit_difference=first(prefixes, lambda x: not x['bit_exact']),
                  first_state_failure=first(prefixes, lambda x: not x['passed']),
                  first_evaluation_failure={key: first(evaluations, lambda x: not x['errors'][key]['passed'])
                                            for key in FIELDS},
                  prefix_errors=prefixes, evaluation_errors=evaluations,
                  hashes={str(path): sha(path) for path in [args.binary, Path(__file__),
                          Path(__file__).with_name('compare.py'), library,
                          model_path, input_path, args.out/'prefix.input', args.out/'matched-state.input']})
    (args.out/'reference-states.json').write_text(json.dumps([x.tolist() for x in wanted_states])+'\n')
    (args.out/'reference-evaluations.json').write_text(json.dumps(
        [{key: value.tolist() for key, value in row.items()} for row in wanted_evaluations])+'\n')
    (args.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print({key: value for key, value in report.items()
           if key not in ['prefix_errors', 'evaluation_errors', 'hashes']})


if __name__ == '__main__':
    main()
