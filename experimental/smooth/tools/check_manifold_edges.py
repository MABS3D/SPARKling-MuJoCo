#!/usr/bin/env python3
"""Quaternion boundaries and atomic rejection, against the MuJoCo C library."""
import argparse
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from compare_numerics import parse_output, reference, model_xml


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--probe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--fixtures', type=Path, default=Path(__file__).resolve().parents[1]/'tests/manifold-fixtures')
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    records = []
    quats = {'zero': [0.,0.,0.,0.], 'below_threshold': [.1e-15]*4,
             'small_components': [.8e-15]*4, 'large': [1e10,-3e9,2e9,5e9],
             'negative_identity': [-1.,0.,0.,0.], 'half_turn': [0.,1.,0.,0.]}
    for name in ('ball', 'free', 'ball_parent_frame', 'free_parent_frame', 'free_ball_hinge'):
        m = mujoco.MjModel.from_xml_path(str(a.fixtures/(name+'.xml')))
        path = a.out/(name+'.mjb'); mujoco.mj_saveModel(m, str(path))
        for case, quat in quats.items():
            q = m.qpos0.copy()
            for j in range(m.njnt):
                if m.jnt_type[j] <= 1:
                    adr = m.jnt_qposadr[j] + (3 if m.jnt_type[j] == 0 else 0)
                    q[adr:adr+4] = quat
            v = np.linspace(-.3,.4,m.nv)
            ctrl = np.linspace(-.2,.3,m.nu)
            applied = np.linspace(-.1,.2,m.nv)
            clock, steps = .25, 5
            data = '1\n'+' '.join(format(x,'.17g') for x in np.concatenate((q,v,ctrl,applied)))+f'\n{clock} {steps}\n'
            run = subprocess.run([str(a.probe),str(path)],input=data,text=True,capture_output=True,timeout=60)
            (a.out/(name+'-'+case+'.output')).write_text(run.stdout+run.stderr)
            run.check_returncode(); row, = parse_output(run.stdout)
            assert row['forward'] == row['step'] == 'SUCCESS', (name,case,row)
            expected = reference(m,q,v,ctrl,applied,clock,steps)
            worst = 0.
            for field, want in expected.items():
                got = np.asarray(row[field])
                if field == 'quaternion': got *= np.where(np.sum(got*want,axis=1)<0,-1.,1.)[:,None]
                # qpos input is copied exactly, including intentionally nonunit quaternions.
                if field.startswith('unchanged_') or field.startswith('reset_'):
                    assert np.array_equal(got,want), (name,case,field,got,want)
                else:
                    error = np.abs(got-want)/(2e-10+2e-10*np.abs(want))
                    worst = max(worst,float(error.max(initial=0)))
                    assert np.all(error <= 1), (name,case,field,got,want)
            records.append(dict(model=name,case=case,max_tolerance_ratio=worst))
    inertial='<inertial pos="0 0 0" mass=".1" diaginertia=".02 .03 .04"/>'
    for kind in ('free','ball'):
        m=mujoco.MjModel.from_xml_string(model_xml(f'<body><joint type="{kind}"/>{inertial}</body>'))
        path=a.out/(kind+'-atomic.mjb');mujoco.mj_saveModel(m,str(path))
        q=m.qpos0.copy();v=np.zeros(m.nv);force=np.zeros(m.nv);force[-1]=1e10
        data='1\n'+' '.join(format(x,'.17g') for x in np.concatenate((q,v,force)))+'\n.25 1\n'
        run=subprocess.run([str(a.probe),str(path)],input=data,text=True,capture_output=True,timeout=60)
        (a.out/(kind+'-atomic.output')).write_text(run.stdout+run.stderr)
        run.check_returncode();row,=parse_output(run.stdout)
        assert row['forward']==row['step']=='NUMERIC_LIMIT'
        assert np.array_equal(row['qpos'],q) and np.array_equal(row['qvel'],v) and row['time'][0]==.25
        records.append(dict(model=kind,case='numeric_limit_atomic',passed=True))
    (a.out/'results.json').write_text(json.dumps(dict(mujoco=mujoco.__version__,status='passed',cases=records),indent=2)+'\n')
    print(len(records),'boundary scenarios passed')

if __name__ == '__main__': main()
