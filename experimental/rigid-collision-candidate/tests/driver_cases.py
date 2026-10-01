"""Compiled C model metadata, filter paths and changing frames."""
import copy
import json
import subprocess

import mujoco
import numpy as np
from common import row,serialize

C_TO_KIND={0:'plane',2:'sphere',3:'capsule',4:'ellipsoid',5:'cylinder',6:'box'}

def extract(m,d):
    rows=[]
    for g in range(m.ngeom):
        body=int(m.geom_bodyid[g]);weld=int(m.body_weldid[body]);parent=int(m.body_weldid[m.body_parentid[weld]])
        rows.append(row((C_TO_KIND[int(m.geom_type[g])],m.geom_size[g]),d.geom_xpos[g],d.geom_xmat[g],body,weld,parent,
            bool(m.body_dofnum[weld]),int(m.geom_contype[g])&0xffffffff,int(m.geom_conaffinity[g])&0xffffffff,
            float(m.geom_margin[g]),float(m.geom_gap[g])))
    explicit=[(int(a),int(b),float(margin+gap)) for a,b,margin,gap in zip(m.pair_geom1,m.pair_geom2,m.pair_margin,m.pair_gap)]
    exclusions=[((int(s)&0xffffffff)>>16,int(s)&65535) for s in m.exclude_signature]
    return rows,explicit,exclusions

def pairs(d):return sorted({tuple(sorted(map(int,c.geom))) for c in d.contact})

def fixtures():
    cases=[]
    one='<geom name="g0" type="sphere" size=".4"/>'
    two='<geom name="g1" type="box" size=".4 .4 .4"/>'
    for name,world,contact,flags in [
        ('same-body','<body><freejoint/>'+one+two+'</body>','',''),
        ('fixed-only','<body>'+one+'</body><body>'+two+'</body>','',''),
        ('world-static','<geom type="plane" size="1 1 .1"/><body>'+one+'</body>','',''),
        ('world-dynamic','<geom type="plane" size="1 1 .1"/><body><freejoint/>'+one+'</body>','',''),
        ('parent-filter','<body name="a"><freejoint/>'+one+'<body name="b"><joint type="hinge"/>'+two+'</body></body>','',''),
        ('parent-disabled','<body name="a"><freejoint/>'+one+'<body name="b"><joint type="hinge"/>'+two+'</body></body>','','filterparent="disable"'),
        ('welded-child','<body><freejoint/>'+one+'<body>'+two+'</body></body>','',''),
        ('excluded','<body name="a"><freejoint/>'+one+'</body><body name="b"><freejoint/>'+two+'</body>','<exclude body1="a" body2="b"/>',''),
        ('explicit-bypasses-exclusion','<body name="a"><freejoint/>'+one+'</body><body name="b"><freejoint/>'+two+'</body>','<exclude body1="a" body2="b"/><pair geom1="g0" geom2="g1"/>',''),
        ('explicit-bypasses-masks','<body><freejoint/>'+one.replace('/>',' contype="0" conaffinity="0"/>')+'</body><body><freejoint/>'+two+'</body>','<pair geom1="g0" geom2="g1"/>',''),
        ('explicit-same-body','<body><freejoint/>'+one+two+'</body>','<pair geom1="g0" geom2="g1"/>',''),
        ('unsigned-mask','<body><freejoint/>'+one.replace('/>',' contype="-2147483648" conaffinity="0"/>')+'</body><body><freejoint/>'+two.replace('/>',' contype="0" conaffinity="-2147483648"/>')+'</body>','',''),
        ('margin-gap','<body><freejoint/>'+one.replace('/>',' margin=".02" gap=".03"/>')+'</body><body pos=".85 0 0"><freejoint/>'+two+'</body>','',''),
        ('explicit-margin-gap','<body><freejoint/>'+one+'</body><body pos=".85 0 0"><freejoint/>'+two+'</body>','<pair geom1="g0" geom2="g1" margin=".02" gap=".04"/>','')]:
        xml='<mujoco><option><flag '+flags+'/></option><worldbody>'+world+'</worldbody><contact>'+contact+'</contact></mujoco>'
        m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);mujoco.mj_fwdPosition(m,d)
        rows,e,x=extract(m,d)
        cases.append((name,serialize(rows,explicit=e,exclusions=x,filter_parent=not bool(flags)),pairs(d)))
    for nb,ng in [(1,64),(4,16),(16,8)]:
        world=[]
        for b in range(nb):
            geoms=''.join('<geom type="sphere" size=".15" pos="'+str((g%4)*.1)+' '+str(((g//4)%4)*.1)+' '+str((g//16)*.1)+'"/>' for g in range(ng))
            world.append('<body pos="'+str((b%4)*.7)+' '+str((b//4)*.7)+' 0"><freejoint/>'+geoms+'</body>')
        m=mujoco.MjModel.from_xml_string('<mujoco><worldbody>'+''.join(world)+'</worldbody></mujoco>');d=mujoco.MjData(m);mujoco.mj_fwdPosition(m,d)
        rows,e,x=extract(m,d);cases.append((f'grouped-{nb}-{ng}',serialize(rows),pairs(d)))
    return cases

def moving():
    rng=np.random.default_rng(31930);bodies=[]
    kinds=['sphere','capsule','ellipsoid','cylinder','box']
    for i in range(64):
        p=np.array([i%8,i//8,0.0])*.8
        bodies.append('<body pos="'+' '.join(map(str,p))+'"><freejoint/><geom type="'+kinds[i%5]+'" size=".35 .4 .45"/></body>')
    xml='<mujoco><option ccd_iterations="100"/><worldbody>'+''.join(bodies)+'</worldbody></mujoco>'
    m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);initial=d.qpos.copy();text='';want=[]
    for f in range(80):
        d.qpos[:]=initial
        for j in range(m.njnt):
            adr=int(m.jnt_qposadr[j]);d.qpos[adr:adr+3]+=.18*np.sin((f*.21+j)*np.array([1.,1.7,2.1]))
            q=np.array([1.,.12*np.sin(f*.1+j),.1*np.cos(f*.07+j),.06*np.sin(f*.03-j)]);q/=np.linalg.norm(q)
            d.qpos[adr+3:adr+7]=q
        # Force an axis change and a disordered endpoint list as well as coherent frames.
        if f in [20,40,60]:
            for j in range(m.njnt):
                adr=int(m.jnt_qposadr[j]);d.qpos[adr:adr+3]=rng.uniform(-4,4,3)
        mujoco.mj_fwdPosition(m,d);rows,e,x=extract(m,d);want.append(pairs(d))
        if f==0:text=serialize(rows,mode=4,repeats=80)
        else:
            values=[v for r in rows for v in [*r[12:24],r[24]]]
            text+=' '.join(format(v,'.17g') for v in values)+'\n'
    return text,want,xml

def check(out):
    entries=fixtures();motion,want,xml=moving();report={}
    (out/'filter-input.txt').write_text(''.join(item[1] for item in entries));(out/'motion-input.txt').write_text(motion)
    (out/'filter-expected.json').write_text(json.dumps({name:want for name,_,want in entries},indent=2)+'\n')
    (out/'motion-expected.json').write_text(json.dumps(want,indent=2)+'\n')
    def parse(line):
        values=line.split()
        if len(values)<2 or values[0]!='SUCCESS':return None
        result=sorted(tuple(map(int,t)) for t in zip(values[2::2],values[3::2]))
        if len(result)!=int(values[1]) or len(set(result))!=len(result):return None
        return result
    for mode in ['validation','release']:
        failures=[];probe=out/'build'/mode/'bin/rigid_probe'
        run=subprocess.run([str(probe)],input=''.join(item[1] for item in entries)+motion,text=True,capture_output=True,timeout=120)
        (out/(mode+'-driver-output.log')).write_text(run.stdout+run.stderr)
        expected=[item[2] for item in entries]+want;names=[item[0] for item in entries]+['frame-'+str(i) for i in range(len(want))]
        actual=run.stdout.splitlines()
        for i,(name,expected_pairs) in enumerate(zip(names,expected)):
            got=parse(actual[i]) if i<len(actual) else None
            if got!=expected_pairs:failures.append(dict(case=name,expected=expected_pairs,actual=got))
        report[mode]=dict(cases=len(expected),returncode=run.returncode,failures=failures)
        print(mode,'filter/moving cases',len(expected),'failures',len(failures),flush=True)
    (out/'driver-numerics.json').write_text(json.dumps(report,indent=2)+'\n')
    return not any(r['failures'] or r['returncode'] for r in report.values())
