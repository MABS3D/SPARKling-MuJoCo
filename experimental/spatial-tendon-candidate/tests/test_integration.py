"""Actual MJB -> Data.Create -> Forward/Forces -> Euler comparison with C."""
import sys, json, subprocess, hashlib, re
from datetime import datetime, timezone
import numpy as np
import mujoco as mj
from common import ROOT, REPO, SCRATCH, environment, source_hashes
sys.path.insert(0, str(REPO / 'experimental/smooth/tools'))
from compare_numerics import parse_output, reference, fixtures as base_fixtures


def fixtures():
    yield 'static_zero_dof', '<mujoco><option><flag constraint="disable"/></option><worldbody><site name="a" pos="-1 .1 0"/><site name="b" pos="1 .1 0"/><geom name="g" type="sphere" size=".3"/></worldbody><tendon><spatial stiffness="2" springlength="1"><site site="a"/><geom geom="g"/><site site="b"/></spatial></tendon></mujoco>'
    for kind in ('sphere', 'cylinder'):
        for moving in (False, True):
            for side in ('outer', 'inside', 'none'):
                inertia = '<inertial pos=".1 0 .05" mass="1.4" diaginertia=".2 .3 .4"/>'
                geom = f'<geom name="wrap" type="{kind}" size=".4 .8" contype="0" conaffinity="0"/><site name="side" pos="0 {0 if side == "inside" else .6} 0"/>'
                if moving:
                    geom = f'<body pos=".04 0 .1"><joint axis="1 2 3" damping=".02" armature=".1"/>{inertia}{geom}</body>'
                body = f'''{geom}<site name="start" pos="-1 .1 .1"/>
                <body pos="1 .1 .2"><joint name="j" type="slide" axis="0 1 0" damping=".03" armature=".1"/>
                <joint type="hinge" axis="0 0 1" stiffness=".2" armature=".1"/>{inertia}<site name="end" pos=".1 .05 0"/></body>'''
                route = f'<site site="start"/><geom geom="wrap" {"" if side == "none" else "sidesite=\"side\""}/><site site="end"/>'
                tendon = f'<spatial stiffness="2 .02 .01" damping=".03 .003 .001" springlength="1.4 1.6">{route}</spatial>'
                xml = f'''<mujoco><compiler angle="radian"/><option timestep=".001" gravity="0 0 -1" integrator="Euler"><flag constraint="disable"/></option>
                <worldbody>{body}</worldbody><tendon>{tendon}</tendon><actuator><motor joint="j" gear=".7"/></actuator></mujoco>'''
                yield f'{kind}_{moving}_{side}', xml
                if not moving and side == 'outer':
                    for flag in ('spring', 'damper', 'eulerdamp'):
                        yield f'{kind}_disable_{flag}', xml.replace('constraint="disable"', f'constraint="disable" {flag}="disable"')
                    pulley = route + '<pulley divisor="2"/>' + route
                    yield kind + '_pulley', xml.replace(route, pulley)
                    yield kind + '_multiple_tendons', xml.replace(tendon, tendon * 3)
                    # Two wraps separated by a site, geometry rotations, and a
                    # nontrivial inertial offset all exercise the engine adapter.
                    extra = f'<geom name="wrap2" type="{kind}" pos=".7 .1 0" quat=".9 .1 .2 .3" size=".2 .8"/><site name="middle" pos=".45 .5 .1"/>'
                    route2 = route.replace('<site site="end"/>', '<site site="middle"/><geom geom="wrap2"/><site site="end"/>')
                    yield kind + '_two_wraps', xml.replace('<worldbody>','<worldbody>'+extra).replace(route,route2)


def main():
    out = ROOT / 'evidence/integration'
    out.mkdir(parents=True, exist_ok=True)
    work = SCRATCH / 'integration-tests'; work.mkdir(exist_ok=True)
    env = environment(); env['SPARKLING_BUILD_ROOT'] = str(SCRATCH / 'integration-build')
    with (out/'build.log').open('w') as log:
        subprocess.run(['gprbuild','-p','-P',str(REPO/'experimental/smooth/tests/probes.gpr'),'-j2'], env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    probe = SCRATCH / 'integration-build/bin/smooth_probe'
    rng = np.random.default_rng(20260930)
    files = [p for directory in ('src','experimental/smooth/src', 'experimental/spatial-tendon-candidate/src')
             for p in (REPO/directory).rglob('*') if p.suffix in ('.ads','.adb')]
    before = {str(p.relative_to(REPO)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    results = []
    for name,xml in [*fixtures(), *base_fixtures().items()]:
        m = mj.MjModel.from_xml_string(xml)
        path = work / (name+'.mjb'); mj.mj_saveModel(m,str(path))
        requests=[]; expected=[]
        for sample in range(12):
            q = rng.uniform(-.08,.08,m.nq)
            v = rng.uniform(-.05,.05,m.nv)
            ctrl = rng.uniform(-.1,.1,m.nu)
            applied = rng.uniform(-.1,.1,m.nv)
            clock=.125; steps=20 if sample else 100
            requests.append(' '.join(map(str,[*q,*v,*ctrl,*applied,clock,steps])))
            ref=reference(m,q,v,ctrl,applied,clock,steps)
            d=mj.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=ctrl;d.qfrc_applied[:]=applied;mj.mj_forward(m,d)
            x=np.where(d.ten_length>m.tendon_lengthspring[:,1],d.ten_length-m.tendon_lengthspring[:,1],
                       np.where(d.ten_length<m.tendon_lengthspring[:,0],d.ten_length-m.tendon_lengthspring[:,0],0))
            spring=-x*((m.tendon_stiffness+m.tendon_stiffnesspoly[:,0]*x)+m.tendon_stiffnesspoly[:,1]*(x*x))
            velocity=d.ten_velocity
            damper=-velocity*((m.tendon_damping+m.tendon_dampingpoly[:,0]*np.abs(velocity))+m.tendon_dampingpoly[:,1]*(velocity*velocity))
            if m.opt.disableflags & mj.mjtDisableBit.mjDSBL_SPRING:spring[:]=0
            if m.opt.disableflags & mj.mjtDisableBit.mjDSBL_DAMPER:damper[:]=0
            ref.update(tendon_length=d.ten_length.copy(),tendon_velocity=velocity.copy(),tendon_force=spring+damper)
            expected.append(ref)
        text=str(len(requests))+'\n'+'\n'.join(requests)+'\n'
        run = subprocess.run([str(probe),str(path)],input=text,text=True,capture_output=True,timeout=120)
        (out/(name+'.output')).write_text(run.stdout+run.stderr)
        (out/(name+'.input')).write_text(text)
        (out/(name+'.xml')).write_text(xml)
        assert run.returncode == 0, (name, run.stderr,run.stdout[-1500:])
        rows=parse_output(run.stdout)
        error={}
        for row,ref in zip(rows,expected,strict=True):
            assert row['forward']=='SUCCESS' and row['step']=='SUCCESS', (name,row)
            for key,value in ref.items():
                actual=np.asarray(row[key]); value=np.asarray(value)
                assert actual.size == value.size,(key,actual,value)
                actual=actual.reshape(value.shape)
                if value.size:
                    maximum=float(np.max(np.abs(actual-value)))
                    error[key]=max(error.get(key,0),maximum)
                    assert np.allclose(actual,value,rtol=3e-10,atol=3e-11),(name,key,maximum,actual,value)
        results.append(dict(name=name,cases=len(rows),dofs=m.nv,tendons=m.ntendon,max_abs_error=error))
        print(name, 'PASS', error.get('qacc',0),error.get('qvel',0),flush=True)
    rejections=[]
    xml=dict(fixtures())['sphere_False_outer']
    for name,model_xml,status in [
        ('armature', re.sub(r'<geom geom="wrap"[^>]*/>', '', xml).replace('<spatial ', '<spatial armature=".1" '), 'UNSUPPORTED_FEATURE'),
        ('tendon_actuator', xml.replace('<spatial ', '<spatial name="t" ').replace('<motor joint="j" gear=".7"/>','<motor tendon="t"/>'), 'UNSUPPORTED_ACTUATOR')]:
        m=mj.MjModel.from_xml_string(model_xml);path=work/(name+'.mjb');mj.mj_saveModel(m,str(path))
        run=subprocess.run([str(probe),str(path)],text=True,capture_output=True,timeout=30)
        assert run.returncode==0 and run.stdout.strip()=='create '+status,(name,run.stdout,run.stderr)
        rejections.append(dict(name=name,result=status))
    m=mj.MjModel.from_xml_string(xml);path=work/'spatial_domain_limit.mjb';mj.mj_saveModel(m,str(path))
    q=np.zeros(m.nq);q[0]=1e10
    data='1\n'+' '.join(map(str,[*q,*np.zeros(m.nv+m.nu+m.nv),.125,1]))+'\n'
    run=subprocess.run([str(probe),str(path)],input=data,text=True,capture_output=True,timeout=30)
    (out/'domain_limit.output').write_text(run.stdout+run.stderr)
    assert run.returncode==0,(run.stdout,run.stderr)
    row,=parse_output(run.stdout)
    assert row['forward']==row['step']=='NUMERIC_LIMIT',row
    assert np.array_equal(row['qpos'],q) and np.array_equal(row['qvel'],np.zeros(m.nv)) and row['time'][0]==.125
    rejections.append(dict(name='spatial_domain_limit',result='NUMERIC_LIMIT',state_atomic=True))
    after = {str(p.relative_to(REPO)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    assert before == after, 'Sources changed during integration test; rerun'
    hashes=source_hashes()
    for directory in ('src','experimental/smooth/src'):
        for p in (REPO/directory).rglob('*'):
            if p.suffix in ('.ads','.adb'):
                hashes[str(p.relative_to(REPO))]=hashlib.sha256(p.read_bytes()).hexdigest()
    (out/'results.json').write_text(json.dumps(dict(timestamp=datetime.now(timezone.utc).isoformat(),reference=mj.__version__,results=results,rejections=rejections,source_sha256=hashes),indent=2)+'\n')

if __name__=='__main__':main()
