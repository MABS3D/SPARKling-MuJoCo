#!/usr/bin/env python3
"""Differential degenerate-model and diagnostic checks for both solver policies."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import mujoco
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[2]/'experimental/smooth/tools'))
from compare_numerics import model_xml, parse_output, digest


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--probe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    inertia = '<inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/>'
    # A fixed child selects C's general coupled-inertia path. A leaf with
    # several collinear slide joints is classified as dof_simplenum by C;
    # that specialized path is not an oracle for the general factorization.
    child = '<body>'+inertia+'</body>'
    fixtures = []
    for n in (2, 3, 4):
        for arm in ('0', '1e-16', '5e-16', '1e-15', '3e-14', '1e-10'):
            body = '<body>'+n*'<joint type="slide" armature="1e-4"/>'+inertia+child+'</body>'
            fixtures.append((f'parallel_{n}_{arm}', model_xml(body, gravity='0 0 0'), arm))
    fixtures.append(('damped_singular', model_xml('<body>'+2*'<joint type="slide" damping=".1" armature="1e-4"/>'+inertia+child+'</body>', gravity='0 0 0'), '0'))
    fixtures.append(('ill_conditioned', model_xml(
        '<body><joint type="slide"/>'+inertia.replace('mass="1"','mass="1e8"')+'</body>'+
        '<body><joint type="slide"/>'+inertia.replace('mass="1"','mass="1e-6"')+'</body>', gravity='0 0 0'), 'ill'))
    results = []
    for name, xml, arm in fixtures:
        m = mujoco.MjModel.from_xml_string(xml)
        if name != 'ill_conditioned':
            assert not np.any(m.dof_simplenum), name
            # Keep compiler-generated reference inverse weights within the
            # loader's Tier0 domain; they are unused with constraints disabled.
            # Both runtimes receive the same edited armature and saved MJB.
            m.dof_armature[:] = float(arm)
        path = args.out/(name+'.mjb')
        mujoco.mj_saveModel(m,str(path))
        (args.out/(name+'.xml')).write_text(xml)
        for loaded in (False, True):
            force = np.array([(-1)**k*1e-18 if loaded else 0. for k in range(m.nv)])
            line = ' '.join(map(str,[*m.qpos0, *np.zeros(m.nv), *force, .125, 4]))
            # Two resets exercise diagnostic clearing and policy retention.
            data = '2\n'+line+'\n'+line+'\n'
            c = mujoco.MjData(m); c.time=.125; c.qfrc_applied[:]=force
            mujoco.mj_forward(m,c)
            expected_acc = c.qacc.copy()
            warning = c.warning[mujoco.mjtWarning.mjWARN_INERTIA]
            first = int(warning.lastinfo) if warning.number else -1
            for _ in range(4): mujoco.mj_step(m,c)
            for policy in ('Compatible','Strict'):
                run=subprocess.run([str(args.probe),str(path),policy],input=data,
                    text=True,capture_output=True,timeout=60)
                key=f'{name}-{loaded}-{policy}'
                (args.out/(key+'.input')).write_text(data)
                (args.out/(key+'.output')).write_text(run.stdout+run.stderr)
                run.check_returncode()
                rows=parse_output(run.stdout)
                for row in rows:
                    if policy == 'Compatible':
                        assert row['forward']==row['step']=='SUCCESS',(key,row)
                        assert row['forward_clamped'][0]==row['step_clamped'][0]==first,(key,first,row)
                        for field, expected in [('qacc',expected_acc),('qpos',c.qpos),('qvel',c.qvel)]:
                            np.testing.assert_allclose(row[field],expected,atol=2e-10,rtol=2e-10,err_msg=key+' '+field)
                    else:
                        expected = ('SUCCESS' if arm=='1e-10' else
                                    'SINGULAR_INERTIA' if arm in ('0','1e-16') else 'ILL_CONDITIONED_INERTIA')
                        assert row['forward']==row['step']==expected,(key,row['forward'],row['step'],expected)
                        assert row['forward_clamped'][0]==row['step_clamped'][0]==-1
                        if expected!='SUCCESS':
                            assert np.array_equal(row['qpos'],m.qpos0)
                            assert np.array_equal(row['qvel'],np.zeros(m.nv))
                            assert row['time'][0]==.125
                results.append(dict(case=key,forward=rows[0]['forward'],step=rows[0]['step'],
                    armature_edit=arm,c_clamped=first,ada_clamped=int(rows[0]['forward_clamped'][0])))
    # A clamped solve can still exceed the prototype's acceleration domain.
    # It must report Numeric_Limit atomically, retaining the clamp diagnostic.
    path=args.out/'parallel_2_0.mjb'
    data='2\n0 0 0 0 1 -1 .125 1\n0 0 0 0 1 -1 .125 1\n'
    run=subprocess.run([str(args.probe),str(path),'Compatible'],input=data,
        text=True,capture_output=True,check=True,timeout=60)
    (args.out/'clamped_numeric_limit.input').write_text(data)
    (args.out/'clamped_numeric_limit.output').write_text(run.stdout+run.stderr)
    for row in parse_output(run.stdout):
        assert row['forward']==row['step']=='NUMERIC_LIMIT'
        assert row['forward_clamped'][0]==row['step_clamped'][0]==0
        assert np.array_equal(row['qpos'],[0,0]) and np.array_equal(row['qvel'],[0,0])
        assert row['time'][0]==.125
    results.append(dict(case='clamped_numeric_limit',forward='NUMERIC_LIMIT',step='NUMERIC_LIMIT',ada_clamped=0))
    for name, mass, position, velocity, force, clock, forward in [
        ('time_limit', '1', 0., 0., 0., 1e10, 'SUCCESS'),
        ('position_limit', '1', 1e10, 1., 0., .25, 'SUCCESS'),
        ('velocity_limit', '1', 0., 1e10, 1e10, .25, 'SUCCESS'),
        ('acceleration_limit', '.1', 0., 0., 1e10, .25, 'NUMERIC_LIMIT'),
    ]:
        xml=model_xml('<body><joint type="slide"/>'+inertia.replace('mass="1"',f'mass="{mass}"')+'</body>',gravity='0 0 0')
        m=mujoco.MjModel.from_xml_string(xml);path=args.out/(name+'.mjb')
        mujoco.mj_saveModel(m,str(path));(args.out/(name+'.xml')).write_text(xml)
        line=f'{position} {velocity} {force} {clock} 1\n';data='2\n'+line+line
        run=subprocess.run([str(args.probe),str(path),'Compatible'],input=data,
            text=True,capture_output=True,check=True,timeout=60)
        (args.out/(name+'.input')).write_text(data)
        (args.out/(name+'.output')).write_text(run.stdout+run.stderr)
        for row in parse_output(run.stdout):
            assert row['forward']==forward and row['step']=='NUMERIC_LIMIT'
            assert row['qpos'][0]==position and row['qvel'][0]==velocity and row['time'][0]==clock
            assert row['forward_clamped'][0]==row['step_clamped'][0]==-1
        results.append(dict(case=name,forward=forward,step='NUMERIC_LIMIT',ada_clamped=-1))
    (args.out/'results.json').write_text(json.dumps(dict(status='passed',oracle=mujoco.__version__,
        probe_sha256=digest(args.probe),cases=len(results),scenarios=2*len(results),results=results),indent=2)+'\n')
    print('Passed',len(results),'policy cases,',2*len(results),'scenarios')


if __name__=='__main__': main()
