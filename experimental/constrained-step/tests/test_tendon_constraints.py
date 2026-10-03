"""Native C vs the owned constrained step: no C rows/forces supplied to Ada."""
import argparse, hashlib, json, subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import parse, oracle

BODY = '''<body pos="0 0 .095"><joint name="x" type="slide" axis="1 0 0" frictionloss=".04"/>
<joint name="y" type="slide" axis="0 1 0"/><joint name="z" type="slide" axis="0 0 1" range="-.1 .2"/>
<geom type="sphere" size=".1" mass="1"/><site name="moving" pos=".05 .02 .04"/></body>'''
TERMS = '<joint joint="x" coef="1.2"/><joint joint="y" coef="-.7"/><joint joint="z" coef=".4"/>'

def xml(body, tendons, solver="Newton", flags="", extra="", plane=True):
    return f'''<mujoco><compiler angle="radian"/><option timestep=".001" solver="{solver}"
      iterations="250" tolerance="1e-12" jacobian="sparse" cone="pyramidal">
      <flag warmstart="disable" island="disable" {flags}/></option>
      <default><joint damping=".15"/><geom condim="3" friction=".6 .01 .003"/></default>
      <worldbody>{'<geom type="plane" size="5 5 .1"/>' if plane else ''}
      <site name="anchor" pos="-.4 -.1 .4"/>{body}</worldbody><tendon>{tendons}</tendon>{extra}</mujoco>'''

def fixtures():
    for solver in ["PGS", "CG", "Newton"]:
        for name, settings in [
            ("lower", 'limited="true" range=".12 .3" frictionloss=".07"'),
            ("upper", 'limited="true" range="-.3 -.12" frictionloss=".07"'),
            ("both", 'limited="true" range="-.01 .01" margin=".12" frictionloss=".07"'),
            ("inside", 'limited="true" range="-1 1" frictionloss=".07"'),
            ("only_limit", 'limited="true" range=".12 .3"'),
            ("direct", 'limited="true" range=".12 .3" frictionloss=".07" solreflimit="-60 -8" solreffriction="-20 -7"'),
        ]:
            tendon=f'<fixed {settings} solimplimit=".8 .97 .03 .4 2" solimpfriction=".7 .9 .05 .6 1">{TERMS}</fixed>'
            yield f"fixed_{solver}_{name}", xml(BODY, tendon, solver)
        spatial='<spatial limited="true" range=".15 .35" margin=".02" frictionloss=".08"><site site="anchor"/><site site="moving"/></spatial>'
        yield f"spatial_{solver}", xml(BODY, spatial, solver)
        free=BODY.replace('<joint name="x" type="slide" axis="1 0 0" frictionloss=".04"/>\n<joint name="y" type="slide" axis="0 1 0"/><joint name="z" type="slide" axis="0 0 1" range="-.1 .2"/>', '<joint name="free" type="free"/>')
        yield f"spatial_free_{solver}", xml(free, spatial, solver)
        ball=BODY.replace('<joint name="x" type="slide" axis="1 0 0" frictionloss=".04"/>\n<joint name="y" type="slide" axis="0 1 0"/><joint name="z" type="slide" axis="0 0 1" range="-.1 .2"/>', '<joint name="ball" type="ball"/>')
        # A nonzero COM lever keeps contact inverse weight within the solver's
        # pre-existing regularization domain; pure pivot-centered contacts are
        # tested as numerical rejection by the constraint solver itself.
        ball=ball.replace('<geom type="sphere"', '<geom pos=".04 0 0" type="sphere"')
        yield f"spatial_ball_{solver}", xml(ball, spatial, solver)
    fixed=f'<fixed limited="true" range=".12 .3" frictionloss=".07">{TERMS}</fixed>'
    spatial='<spatial limited="true" range=".15 .35" frictionloss=".08"><site site="anchor"/><site site="moving"/></spatial>'
    yield 'mixed_fixed_spatial', xml(BODY, fixed+spatial)
    for flag in ['limit', 'frictionloss', 'constraint']:
        yield 'disabled_'+flag, xml(BODY, fixed+spatial, flags=f'{flag}="disable"')
    for side, bounds in [('lower','-.125 1'), ('upper','-1 .125')]:
        yield 'exact_margin_'+side, xml(BODY, f'<fixed limited="true" range="{bounds}" margin=".125"><joint joint="x" coef="1"/></fixed>')
    static='<site name="a" pos="1 0 0"/><site name="b" pos="2 0 0"/>'
    yield 'zero_chain', xml(static+BODY, '<spatial limited="true" range=".1 .2" frictionloss=".1"><site site="a"/><site site="b"/></spatial>')
    wrapbody='<geom name="wrap" type="sphere" pos="0 0 .3" size=".12" contype="0" conaffinity="0"/>'+BODY
    yield 'spatial_wrap', xml(wrapbody, spatial.replace('<site site="moving"/>','<geom geom="wrap"/><site site="moving"/>'))
    repeated='<fixed limited="true" range=".1 .4" frictionloss=".06"><joint joint="x" coef="1"/><joint joint="x" coef="2"/><joint joint="z" coef=".5"/></fixed>'
    yield 'fixed_repeated_disabled', xml(BODY, repeated, flags='constraint="disable"')
    yield 'fixed_spring_armature', xml(BODY, fixed.replace('frictionloss=".07"','frictionloss=".07" stiffness="3" damping=".1" armature=".02"'))
    yield 'inactive_general_power', xml(BODY, fixed.replace('frictionloss=".07"','frictionloss=".07" solimplimit=".8 .95 .03 .5 3" solimpfriction=".8 .95 .03 .5 3"'), flags='constraint="disable"')

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--samples',type=int,default=6);p.add_argument('--steps',type=int,default=100);p.add_argument('--only');a=p.parse_args()
    assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
    rng=np.random.default_rng(202610021);records=[];failures=[]
    for name,source in fixtures():
        if a.only and a.only not in name:continue
        m=mujoco.MjModel.from_xml_string(source);f=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(f));(a.out/(name+'.xml')).write_text(source)
        data=[];refs=[]
        for i in range(a.samples):
            q=m.qpos0.copy()
            if i:mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.008)
            v=rng.uniform(-.08,.08,m.nv);applied=rng.uniform(-.1,.1,m.nv);ctrl=np.zeros(m.nu)
            loads=rng.uniform(-.04,.04,(m.nbody,6));act=np.zeros(m.na)
            data.extend([0.,*q,*v,*applied,*ctrl,*act,*loads.ravel()])
            ref=oracle(m,q,v,applied,a.steps,ctrl,loads,act)
            # The generic parser's indexed assignment loses duplicate slots.
            # Sum the native sparse Jacobian's columns for mathematical J.
            d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.qfrc_applied[:]=applied;d.xfrc_applied[:]=loads;mujoco.mj_forward(m,d)
            J=np.zeros((d.nefc,m.nv))
            for r in range(d.nefc):
                start=d.efc_J_rowadr[r];count=d.efc_J_rownnz[r]
                np.add.at(J[r],d.efc_J_colind[start:start+count],d.efc_J[start:start+count])
            ref['jac']=J;refs.append(ref)
        payload=f'{a.samples} {a.steps}\n'+' '.join(format(x,'.17g') for x in data)+'\n'
        run=subprocess.run([str(a.binary),str(f),'loads'],input=payload,text=True,capture_output=True,timeout=180)
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        if run.returncode or run.stdout.startswith('create'):
            failures.append(dict(model=name,error=(run.stdout+run.stderr)[-1600:]));print('FAIL',name,failures[-1],flush=True);continue
        actual=parse(run.stdout,m.nv,m.na)
        assert len(actual)==len(refs)
        for i,(x,y) in enumerate(zip(actual,refs)):
            errors={}
            for k,expected in y.items():
                if x[k].shape!=expected.shape:errors[k]=dict(passed=False,shape_ada=x[k].shape,shape_c=expected.shape);continue
                delta=float(np.max(abs(x[k]-expected))) if expected.size else 0.
                tol=2e-10 if k in ['counts','free','jac','aref','reg'] else 3e-6
                errors[k]=dict(max_abs=delta,passed=bool(np.allclose(x[k],expected,atol=tol,rtol=1e-8 if tol>1e-8 else 2e-12)))
            row=dict(model=name,sample=i,passed=all(v['passed'] for v in errors.values()),errors=errors);records.append(row)
            if not row['passed']:failures.append(row);print('FAIL',name,i,{k:v for k,v in errors.items() if not v['passed']},flush=True)
        print(name,'checked',flush=True)
    result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),steps=a.steps,cases=len(records),passed=sum(r['passed'] for r in records),failures=failures,records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'failures',len(failures))
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
