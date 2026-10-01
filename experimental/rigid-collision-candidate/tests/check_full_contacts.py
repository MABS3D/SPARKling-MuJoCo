"""Isolate material mixing/finalization against actual mj_collision contacts.

The supplied geometric precontacts come from the native oracle. Geometry is
tested separately by check_contacts/check_advanced; this does not hide its
known numerical differences or claim a scene driver is implemented in Ada.
"""
import argparse,json,subprocess
from pathlib import Path
import mujoco,numpy as np
from common import build
from check_contacts import library

def model(explicit):
    contact='<contact><pair geom1="a" geom2="b"/></contact>' if explicit else ''
    # Conservative immutable broadphase bounds retain all sampled candidates.
    m=mujoco.MjModel.from_xml_string('<mujoco><worldbody><body><freejoint/><geom name="a" type="sphere" size=".4" margin="5" gap="5"/></body><body><freejoint/><geom name="b" type="sphere" size=".6" margin="5" gap="5"/></body></worldbody>'+contact+'</mujoco>')
    return m,mujoco.MjData(m)

def packed(c):
    return np.r_[c.dist,c.pos,c.frame,c.dim,c.friction,c.solref,c.solreffriction,c.solimp,
                 c.includemargin,c.exclude,c.adhesion,c.geom,c.efc_address,c.mu,c.H]

def run(out,samples):
    rng=np.random.default_rng(3141401);models=[model(False),model(True)];lib=library(out)
    texts=[];expected=[];descriptions=[];coverage=dict(explicit=0,override=0,adhesive_gap=0,excluded_gap=0,direct_reference=0,zero_mix=0)
    for i in range(samples):
        explicit=bool(i%3==0);override=bool(i%5==0);m,d=models[explicit]
        m.geom_priority[:]=rng.integers(-1,3,2);m.geom_condim[:]=rng.choice([1,3,4,6],2)
        m.geom_solmix[:]=rng.choice([0.,1e-16,.1,1.,3.],2)
        m.geom_solref[:]=rng.uniform(.005,2,(2,2))
        if i%4==0:m.geom_solref[i%2]*=-1;coverage['direct_reference']+=1
        m.geom_solimp[:]=rng.uniform(.1,.9,(2,5));m.geom_solimp[:,2]=.01;m.geom_solimp[:,4]=2
        m.geom_friction[:]=rng.uniform(0,2,(2,3))
        if i%7==0:m.geom_friction[:,1:]=0
        m.geom_adhesion[:]=rng.choice([0.,0.,.05,.7],2)
        m.geom_margin[:]=rng.uniform(0,.4,2);m.geom_gap[:]=rng.uniform(0,.4,2)
        m.opt.enableflags=(int(mujoco.mjtEnableBit.mjENBL_OVERRIDE) if override else 0)
        m.opt.o_margin=float(rng.uniform(0,.3));m.opt.o_solref[:]=[.02,.8]
        m.opt.o_solimp[:]=[.7,.95,.001,.5,2];m.opt.o_friction[:]=rng.uniform(0,1,5)
        margin=float(m.geom_margin.sum());gap=float(m.geom_gap.sum())
        if explicit:
            m.pair_dim[0]=int(rng.choice([1,3,4,6]));m.pair_solref[0]=[.03,.7]
            m.pair_solreffriction[0]=([-.2,-.1] if i%2 else [0.,0.])
            m.pair_solimp[0]=[.75,.9,.01,.5,2];m.pair_friction[0]=rng.uniform(0,2,5)
            m.pair_adhesion[0]=float(rng.choice([0.,.2]));m.pair_margin[0]=rng.uniform(0,.4);m.pair_gap[0]=rng.uniform(0,.4)
            margin=float(m.pair_margin[0]);gap=float(m.pair_gap[0])
        detection=(float(m.opt.o_margin) if override else margin)+gap
        direction=rng.normal(size=3);direction/=np.linalg.norm(direction)
        d.qpos[:]=0;d.qpos[3]=d.qpos[10]=1
        # Native SAP with override expands by o_margin/2 per geometry and
        # omits gap. Keep automatic override pairs inside that admission;
        # explicit override pairs still exercise contacts in the gap.
        admitted=(float(m.opt.o_margin) if override and not explicit else detection)
        distance=float(rng.uniform(.1,1+admitted-.001));d.qpos[7:10]=direction*distance
        mujoco.mj_kinematics(m,d);mujoco.mj_comPos(m,d);mujoco.mj_collision(m,d)
        want=np.array([packed(c) for c in d.contact[:d.ncon]]).reshape(-1,71)
        raw=np.zeros(500);n=lib.rigid_contacts(m._address,d._address,0,1,detection,raw)
        if n!=len(want):raise RuntimeError(('native driver/narrowphase disagree',i,n,len(want)))
        values=[n,*raw[:10*n]]
        for g in [0,1]:values += [int(m.geom_priority[g]),int(m.geom_condim[g]),m.geom_solmix[g],m.geom_adhesion[g],*m.geom_solref[g],*m.geom_solimp[g],*m.geom_friction[g]]
        values += [margin,gap,int(explicit)]
        if explicit:values += [int(m.pair_dim[0]),m.pair_adhesion[0],*m.pair_solref[0],*m.pair_solreffriction[0],*m.pair_solimp[0],*m.pair_friction[0]]
        values += [int(override),m.opt.o_margin,*m.opt.o_solref,*m.opt.o_solimp,*m.opt.o_friction]
        texts.append(' '.join(format(float(v),'.17g') if isinstance(v,(float,np.floating)) else str(v) for v in values)+'\n');expected.append(want)
        descriptions.append(dict(explicit=explicit,override=override,sample=i))
        coverage['explicit']+=explicit;coverage['override']+=override;coverage['zero_mix']+=bool(np.any(m.geom_solmix<1e-15))
        for c in d.contact[:d.ncon]:
            coverage['adhesive_gap']+=bool(c.adhesion and c.dist>=c.includemargin)
            coverage['excluded_gap']+=bool(c.exclude)
    reports={}
    for profile in ['validation','release']:
        r=subprocess.run([str(out/'build'/profile/'bin/full_contact_probe')],input=''.join(texts),text=True,capture_output=True,timeout=120)
        lines=r.stdout.splitlines();failures=[]
        for i,want in enumerate(expected):
            words=lines[i].split() if i<len(lines) else ['MISSING']
            if words[0]!='SUCCESS':error=dict(reason='status',output=words)
            else:
                actual=np.array(list(map(float,words[2:]))).reshape(-1,71)
                if actual.shape!=want.shape:error=dict(reason='shape',ada=list(actual.shape),c=list(want.shape))
                elif not np.isfinite(actual).all():error=dict(reason='nonfinite')
                elif np.any(np.abs(actual-want)>2e-12*(1+np.abs(want))):error=dict(reason='values',ada=actual.tolist(),c=want.tolist())
                else:error=None
            if error:failures.append(dict(index=i,**descriptions[i],**error,input=texts[i]))
        reports[profile]=dict(cases=samples,returncode=r.returncode,stderr=r.stderr,coverage=coverage,failures=failures)
        print(profile,'full parameters/frame',samples,'failures',len(failures),flush=True)
    (out/'full-contact-numerics.json').write_text(json.dumps(reports,indent=2)+'\n');(out/'full-contact-input.txt').write_text(''.join(texts))
    return not any(r['failures'] or r['returncode'] for r in reports.values())

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=2000);p.add_argument('--reuse',action='store_true');a=p.parse_args();out=a.out.resolve()
    if not a.reuse:build(out)
    raise SystemExit(0 if run(out,a.samples) else 1)
