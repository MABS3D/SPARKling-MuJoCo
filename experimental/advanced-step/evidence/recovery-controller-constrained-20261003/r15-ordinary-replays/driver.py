"""Isolate one controller evaluation as an ordinary applied-force diagnostic.

C controller force is a persisted test input only. This establishes an
instantaneous replay, not equivalence of a constant-force trajectory.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
import mujoco
import numpy as np


def jacobian(model, data):
    if not mujoco.mj_isSparse(model):
        return data.efc_J.reshape(data.nefc, model.nv).copy()
    result = np.zeros((data.nefc, model.nv))
    for row in range(data.nefc):
        start = data.efc_J_rowadr[row]
        stop = start + data.efc_J_rownnz[row]
        result[row, data.efc_J_colind[start:stop]] = data.efc_J[start:stop]
    return result


def outputs(model, data):
    mass = np.zeros((model.nv, model.nv))
    mujoco.mj_fullM(model, data, mass)
    return dict(acc=data.qacc.copy(), free=data.qacc_smooth.copy(),
                jac=jacobian(model, data), aref=data.efc_aref.copy(),
                reg=data.efc_R.copy(), force=data.efc_force.copy(),
                qfrc=data.qfrc_constraint.copy(), mass=mass)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--model', required=True)
    p.add_argument('--sample', type=int, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    orig = mujoco.MjModel.from_binary_path(str(a.reference/(a.model+'.mjb')))
    line = (a.reference/(a.model+'.input')).read_text().splitlines()[a.sample+1]
    values = list(map(float, line.split()))
    data = mujoco.MjData(orig)
    data.time = values[1]
    offset = 2
    for target in (data.qpos, data.qvel, data.ctrl, data.act, data.qfrc_applied, data.xfrc_applied.ravel()):
        target[:] = values[offset:offset+target.size]
        offset += target.size
    assert offset == len(values)
    mujoco.mj_forward(orig, data)
    controller = outputs(orig, data)
    controller.update({name: getattr(data, name).copy() for name in
                       ['actuator_length', 'actuator_velocity', 'actuator_force', 'qfrc_actuator']})
    xml = ET.fromstring((a.reference/(a.model+'.xml')).read_text())
    xml.remove(xml.find('actuator'))
    (a.out/'model.xml').write_text(ET.tostring(xml, encoding='unicode'))
    model = mujoco.MjModel.from_xml_path(str(a.out/'model.xml'))
    mujoco.mj_saveModel(model, str(a.out/'model.mjb'))
    ordinary = mujoco.MjData(model)
    ordinary.time = data.time
    for name in ['qpos', 'qvel', 'xfrc_applied']:
        getattr(ordinary, name)[:] = getattr(data, name)
    ordinary.qfrc_applied[:] = data.qfrc_applied + controller['qfrc_actuator']
    tokens = [ordinary.time, *ordinary.qpos, *ordinary.qvel, *ordinary.qfrc_applied, *ordinary.xfrc_applied.ravel()]
    text = '1 0\n' + ' '.join(format(float(x), '.17g') for x in tokens) + '\n'
    (a.out/'input.txt').write_text(text)
    (a.out/'original-controller.input').write_text('1\n'+line+'\n')
    run = subprocess.run([str(a.binary), str(a.out/'model.mjb'), 'loads', 'problem'],
                         input=text, text=True, capture_output=True, timeout=30)
    (a.out/'output.txt').write_text(run.stdout)
    (a.out/'problem.txt').write_text(run.stderr)
    assert run.returncode == 0, run.stdout+run.stderr
    actual, rows = {}, []
    for line in run.stdout.splitlines():
        tag, *tokens = line.split()
        if tag == 'jac':
            rows.append(list(map(float, tokens)))
        else:
            try:
                actual[tag] = np.array(tokens, float)
            except ValueError:
                pass
    actual['jac'] = np.array(rows).reshape(-1, model.nv)
    mujoco.mj_forward(model, ordinary)
    expected = outputs(model, ordinary)
    for name, content in [('reference', expected), ('controller-reference', controller)]:
        (a.out/(name+'.json')).write_text(json.dumps({k:v.tolist() for k,v in content.items()}, indent=2)+'\n')
    difference = lambda x,y: float(np.max(np.abs(x-y))) if x.size else 0.0
    error = {k:dict(max_abs=difference(actual[k], v),
                   passed=bool(np.allclose(actual[k], v, rtol=2e-10, atol=2e-10)))
             for k,v in expected.items() if k != 'mass'}
    exact = {k:bool(np.array_equal(v, controller[k])) for k,v in expected.items()}
    digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    report = dict(reference=mujoco.__version__, model=a.model, sample=a.sample,
                  errors=error, ordinary_vs_controller_C_exact=exact,
                  ordinary_vs_controller_C_max_abs={k:difference(v, controller[k]) for k,v in expected.items()},
                  passed=all(v['passed'] for v in error.values()),
                  scope='instantaneous diagnostic with original C controller force added once to applied input',
                  hashes={str(f):digest(f) for f in [a.binary, Path(__file__), a.reference/(a.model+'.mjb'),
                          a.reference/(a.model+'.input'), a.out/'input.txt', a.out/'model.mjb']})
    (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))
    assert all(exact.values()), 'ordinary C replay changed the original C evaluation'
    raise SystemExit(not report['passed'])


if __name__ == '__main__':
    main()
