"""Shared scene selection followed by one contact generation, native C oracle."""
import argparse
import copy
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np

from common import build, row
from check import scenes, rotation
from driver_cases import fixtures, moving, extract
from check_advanced import CUBE, model, mesh_asset


def fmt(values):
    return ' '.join(format(float(x), '.17g') if isinstance(x, (float, np.floating)) else str(int(x)) for x in values)+'\n'


def serialize(rows, explicit=(), exclusions=(), filter_parent=True, sleep=False,
              enabled=True, override=None, capacity=65536, frames=(), assets=None):
    text=fmt([0,len(rows),len(explicit),len(exclusions),len(frames)+1,
              filter_parent,sleep,enabled,override is not None,override or 0,capacity])
    for i,r in enumerate(rows):
        text+=fmt(r)
        if assets and i in assets:text+=fmt(assets[i])
    for p in explicit:text+=fmt(p)
    for p in exclusions:text+=fmt(p)
    for frame in frames:text+=fmt([x for r in frame for x in r[12:25]])
    return text


def declared(pairs):
    return [(*p[:2],p[2],0,3,1,1,.005,.0001,.0001) for p in pairs]


def legacy(text):
    """Preserve the existing filter fixtures, including unsigned masks."""
    v=text.split();n,ne,nx=map(int,v[1:4]);j=7
    rows=[[float(x) if 7<=k<=23 else int(x) for k,x in enumerate(v[j+25*i:j+25*(i+1)])] for i in range(n)]
    j+=25*n
    ep=[(int(v[j+3*i]),int(v[j+3*i+1]),float(v[j+3*i+2])) for i in range(ne)];j+=3*ne
    ex=[tuple(map(int,v[j+2*i:j+2*i+2])) for i in range(nx)]
    return rows,declared(ep),ex,bool(int(v[5])),bool(int(v[6]))


def parse(line):
    v=line.split()
    if len(v)<4:raise ValueError('short scene output')
    n,selected,calls=map(int,v[1:4])
    contacts=np.asarray(list(map(float,v[4:]))).reshape(-1,23)
    if len(contacts)!=n:raise ValueError('incomplete contact prefix')
    return v[0],contacts,selected,calls


def pair_set(contacts):return sorted({tuple(map(int,r[:2])) for r in contacts})


def native_contacts(d):
    out=[]
    for c in d.contact:
        a,b=map(int,c.geom);normal=np.asarray(c.frame).reshape(3,3)[0].copy()
        if a>b:a,b=b,a;normal=-normal
        out.append(dict(pair=(a,b),distance=float(c.dist),position=np.asarray(c.pos).copy(),normal=normal,
                        dim=int(c.dim),fri=np.asarray(c.friction).copy(),include=float(c.includemargin),excluded=int(c.exclude)))
    return out


def match(contacts,want):
    if len(contacts)!=len(want):return dict(reason='count',actual=len(contacts),expected=len(want))
    remaining=list(range(len(want)))
    for r in contacts:
        found=None
        for j in remaining:
            c=want[j]
            if tuple(map(int,r[:2]))!=c['pair']:continue
            if abs(r[2]-c['distance'])>2e-6 or np.max(np.abs(r[3:6]-c['position']))>2e-6:continue
            if np.max(np.abs(r[6:9]-c['normal']))>2e-6:continue
            if int(r[17])!=c['dim'] or np.max(np.abs(r[18:23]-c['fri']))>1e-10:continue
            if abs(r[15]-c['include'])>1e-12 or int(r[16])!=c['excluded']:continue
            found=j;break
        if found is None:return dict(reason='contact fields',actual=r.tolist())
        remaining.remove(found)
    return None


def run(out):
    inputs=[];expect=[]
    def add(name,text,pairs=None,contacts=None,status='SUCCESS',unique_pair_calls=False):
        inputs.append(text);expect.append(dict(name=name,pairs=pairs,contacts=contacts,status=status,unique_pair_calls=unique_pair_calls))
    for name,(_,d,rows,pairs,_) in scenes():
        add('scene-'+name,serialize(rows),pairs)
    for name,text,pairs in fixtures():
        rows,ep,ex,parent,sleep=legacy(text)
        add('filter-'+name,serialize(rows,ep,ex,parent,sleep),pairs)
    motion,want,_=moving();v=motion.split();n=int(v[1]);count=int(v[4]);rows,_,_,parent,sleep=legacy(motion)
    j=7+25*n;frames=[]
    for f in range(1,count):
        frame=copy.deepcopy(rows)
        for i in range(n):
            frame[i][12:24]=map(float,v[j:j+12]);frame[i][24]=int(v[j+12]);j+=13
        frames.append(frame)
    inputs.append(serialize(rows,filter_parent=parent,sleep=sleep,frames=frames))
    expect.extend(dict(name='moving-'+str(i),pairs=p,contacts=None,status='SUCCESS',unique_pair_calls=False) for i,p in enumerate(want))

    rng=np.random.default_rng(3140202)
    # Fields of complete contacts, for unambiguous primitive cases.
    for kind in ['sphere','capsule','ellipsoid','cylinder','box']:
        for i in range(20):
            xml=f'<mujoco><worldbody><geom type="plane" size="2 2 .1"/><body pos="0.12 -0.07 {rng.uniform(-.05,.65)}"><freejoint/><geom type="{kind}" size=".4 .5 .6"/></body></worldbody></mujoco>'
            m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
            q=np.array([1.,*rng.uniform(-.25,.25,3)]);q/=np.linalg.norm(q);d.qpos[3:7]=q
            mujoco.mj_fwdPosition(m,d);rows,ep,ex=extract(m,d)
            # Tangential seeds can select a different basis; compare the normal
            # and separately check the orthogonality of the complete frame.
            add(f'full-plane-{kind}-{i}',serialize(rows,declared(ep),ex),contacts=native_contacts(d),unique_pair_calls=True)

    # Configured margins/gaps, excluded contacts and explicit material fields.
    for explicit in [False,True]:
        for override in [None,0.0,.15]:
            pair='<contact><pair geom1="a" geom2="b" margin=".03" gap=".04" condim="6" friction=".7 .6 .03 .002 .003"/></contact>' if explicit else ''
            xml='<mujoco><worldbody><body><freejoint/><geom name="a" type="sphere" size=".4" margin=".02" gap=".04"/></body><body pos=".86 0 0"><freejoint/><geom name="b" type="sphere" size=".4" margin=".03" gap=".02"/></body></worldbody>'+pair+'</mujoco>'
            m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
            if override is not None:
                m.opt.enableflags|=int(mujoco.mjtEnableBit.mjENBL_OVERRIDE);m.opt.o_margin=override
            mujoco.mj_fwdPosition(m,d);rows,_,ex=extract(m,d)
            ep=[(0,1,.03,.04,6,.7,.6,.03,.002,.003)] if explicit else []
            add(f'margins-{explicit}-{override}',serialize(rows,ep,ex,override=override),contacts=native_contacts(d),unique_pair_calls=True)

    # Off-center hulls: selected using a containing box, generated from vertices.
    for reverse in [False,True]:
        for i in range(10):
            kinds=['mesh','sphere'] if not reverse else ['sphere','mesh']
            m,d=model(*kinds,CUBE)
            m.geom_margin[:]=.01
            for g,k in enumerate(kinds):
                if k=='sphere':
                    qadr=int(m.jnt_qposadr[int(m.body_jntadr[int(m.geom_bodyid[g])])])
                    d.qpos[qadr:qadr+3]=[1.25+.04*i,-.05+.01*i,.07]
            mujoco.mj_fwdPosition(m,d)
            vertices,_=mesh_asset(m,kinds.index('mesh'));rows=[];assets={}
            for g,k in enumerate(kinds):
                body=int(m.geom_bodyid[g]);weld=int(m.body_weldid[body])
                r=row(('sphere' if k=='sphere' else 'box',m.geom_size[g]),d.geom_xpos[g],d.geom_xmat[g],body,weld,0,True,margin=.01)
                if k=='mesh':
                    r[0]=6
                    # Equivalent world-space geometry with an off-center local
                    # hull. Using only Rigid.Size would miss these candidates.
                    shift=np.array([3+.02*i,.2,-.1])
                    r[12:15]=np.asarray(r[12:15])-np.asarray(r[15:24]).reshape(3,3)@shift
                    assets[g]=[len(vertices),*(vertices+shift).reshape(-1),0]
                rows.append(r)
            add(f'hull-sphere-{reverse}-{i}',serialize(rows,assets=assets),contacts=native_contacts(d),unique_pair_calls=True)

    # Heightfield both ID orders; a sphere on flat terrain has one native contact.
    for reverse in [False,True]:
        for z in [.35,.5,.7,1.2]:
            kinds=['hfield','sphere'] if not reverse else ['sphere','hfield']
            m,d=model(*kinds,CUBE);m.hfield_data[:]=.25
            sphere=kinds.index('sphere');body=int(m.geom_bodyid[sphere]);qadr=int(m.jnt_qposadr[int(m.body_jntadr[body])])
            d.qpos[qadr:qadr+3]=[.12,.07,z];mujoco.mj_fwdPosition(m,d)
            rows=[];assets={}
            for g,k in enumerate(kinds):
                body=int(m.geom_bodyid[g]);weld=int(m.body_weldid[body])
                r=row(('sphere' if k=='sphere' else 'box',[.4,.6,.5]),d.geom_xpos[g],d.geom_xmat[g],body,weld,0,k=='sphere')
                if k=='hfield':
                    r[0]=7;assets[g]=[int(m.hfield_nrow[0]),int(m.hfield_ncol[0]),*m.hfield_size[0],*m.hfield_data]
                rows.append(r)
            add(f'terrain-{reverse}-{z}',serialize(rows,assets=assets),contacts=native_contacts(d),unique_pair_calls=True)

    # Atomic capacity failure, disabled contact path, explicit dedup and sleep.
    base=[row(('sphere',[.4,.4,.4]),p,np.eye(3).reshape(9),i+1,i+1,0,True) for i,p in enumerate([[0,0,0],[.6,0,0]])]
    add('capacity-zero',serialize(base,capacity=0),status='CAPACITY_LIMIT')
    add('disabled',serialize(base,enabled=False),[])
    add('explicit-dedup',serialize(base,explicit=[(1,0,0,0,6,.7,.6,.03,.002,.003)]),[(0,1)],unique_pair_calls=True)
    asleep=copy.deepcopy(base)
    for r in asleep:r[24]=1
    add('sleep-auto',serialize(asleep,sleep=True),[])
    add('sleep-explicit',serialize(asleep,explicit=[(0,1,0,0,3,1,1,.005,.0001,.0001)],sleep=True),[])
    add('duplicate-explicit',serialize(base,explicit=[(0,1,0,0,3,1,1,.005,.0001,.0001)]*2),status='INVALID_INPUT')
    dense=[row(('sphere',[.4,.4,.4]),[0,0,0],np.eye(3).reshape(9),i+1,i+1,0,True) for i in range(364)]
    add('candidate-capacity',serialize(dense),status='CAPACITY_LIMIT')
    invalid=copy.deepcopy(base);invalid[0][15]=1.2
    add('invalid-rotation',serialize(invalid),status='INVALID_INPUT')
    xml='<mujoco><worldbody>'+''.join(f'<body pos="{.6*i} 0 0"><freejoint/><geom name="g{i}" type="sphere" size=".4"/></body>' for i in range(3))+'</worldbody><contact><pair geom1="g1" geom2="g2" condim="6" friction=".2 .3 .04 .006 .007"/><pair geom1="g1" geom2="g0" condim="1" friction=".8 .9 .05 .008 .009"/></contact></mujoco>'
    m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);mujoco.mj_fwdPosition(m,d)
    rows,_,_=extract(m,d)
    ep=[(1,2,0,0,6,.2,.3,.04,.006,.007),(1,0,0,0,1,.8,.9,.05,.008,.009)]
    add('explicit-input-ordinal',serialize(rows,explicit=ep),contacts=native_contacts(d))

    reports={}
    (out/'scene-contact-input.txt').write_text(''.join(inputs))
    for profile in ['validation','release']:
        r=subprocess.run([str(out/'build'/profile/'bin/scene_probe')],input=''.join(inputs),text=True,capture_output=True,timeout=180)
        (out/(profile+'-scene-contacts.log')).write_text(r.stdout+r.stderr)
        lines=r.stdout.splitlines();fail=[]
        for i,expected in enumerate(expect):
            try:
                status,contacts,selected,calls=parse(lines[i])
                error=None
                if status!=expected['status']:error=dict(reason='status',actual=status,expected=expected['status'])
                elif status!='SUCCESS' and len(contacts):error=dict(reason='failure exposed contacts')
                elif status=='SUCCESS':
                    if calls>selected:error=dict(reason='duplicate generation',selected=selected,calls=calls)
                    elif expected['unique_pair_calls'] and calls>1:error=dict(reason='pair generated twice',calls=calls)
                    elif expected['pairs'] is not None and pair_set(contacts)!=expected['pairs']:error=dict(reason='pairs',actual=pair_set(contacts),expected=expected['pairs'])
                    elif expected['contacts'] is not None:error=match(contacts,expected['contacts'])
                    if error is None and len(contacts):
                        frames=contacts[:,6:15].reshape(-1,3,3)
                        if not np.isfinite(contacts).all() or np.max(np.abs(frames@frames.transpose(0,2,1)-np.eye(3)))>1e-8:error=dict(reason='invalid frame')
            except (ValueError,IndexError) as e:error=dict(reason=str(e),output=lines[i] if i<len(lines) else 'MISSING')
            if error:fail.append(dict(index=i,case=expected['name'],**error))
        reports[profile]=dict(cases=len(expect),lines=len(lines),returncode=r.returncode,stderr=r.stderr,failures=fail)
        print(profile,'unified scenes',len(expect),'failures',len(fail),flush=True)
    (out/'scene-contact-numerics.json').write_text(json.dumps(reports,indent=2)+'\n')
    return not any(r['returncode'] or r['failures'] or r['lines']!=r['cases'] for r in reports.values())


if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);a.add_argument('--reuse',action='store_true');args=a.parse_args()
    out=args.out.resolve()
    if not args.reuse:build(out)
    raise SystemExit(0 if run(out) else 1)
