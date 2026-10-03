"""Compound-body midphase: exact previous Ada order and independent native C.

Pass source-frozen before/after build directories; no source or Git mutation.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np

from check_scene import serialize, parse, match, native_contacts
from driver_cases import extract


def compound_xml(n, dense=False, plane=False, masks=False):
    pieces=[]
    for body in range(2):
        geoms=[]
        for i in range(n):
            x=1000 if i == n-1 and not dense else 0
            y=0 if dense else 2*(i % 16)
            z=0 if dense else 2*(i // 16)
            mask=f' contype="{1 << (i % 2)}" conaffinity="{1 << (i % 2)}"' if masks else ''
            geoms.append(f'<geom name="g{body}_{i}" type="sphere" size=".4" pos="{x} {y} {z}"{mask}/>')
        pieces.append(f'<body pos="{body*.6} 0 0"><freejoint/>'+''.join(geoms)+'</body>')
    floor='<geom type="plane" size="1000 1000 .1" pos="0 0 -.3"/>' if plane else ''
    return '<mujoco><worldbody>'+floor+''.join(pieces)+'</worldbody></mujoco>'


def cases():
    rng=np.random.default_rng(3140210)
    for n in [7,8,9,16,64,128]:
        for dense in [False,True]:
            if dense and n > 64:continue
            for masks in [False,True]:
                xml=compound_xml(n,dense,masks=masks)
                m=mujoco.MjModel.from_xml_string(xml)
                for frame in range(4):
                    d=mujoco.MjData(m)
                    if frame:
                        d.qpos[0:3]+=rng.uniform(-.04,.04,3)
                        d.qpos[7:10]+=rng.uniform(-.04,.04,3)
                    mujoco.mj_fwdPosition(m,d)
                    rows,ep,ex=extract(m,d)
                    yield f'compound-{n}-{dense}-{masks}-{frame}',serialize(rows),native_contacts(d),True
    # Same cache across refits, changing sweep axes/order, rotations and sleep.
    m=mujoco.MjModel.from_xml_string(compound_xml(64,plane=True))
    rows=[];wanted=[]
    for f in range(40):
        d=mujoco.MjData(m)
        angle=f*.006
        for j in range(2):
            a=int(m.jnt_qposadr[j]);d.qpos[a:a+3]+=[.025*np.sin(f),.03*np.cos(f),.01*np.sin(f*.2)]
            d.qpos[a+3:a+7]=[np.cos(angle/2),0,0,np.sin(angle/2)]
        mujoco.mj_fwdPosition(m,d);r,_,_=extract(m,d)
        rows.append(r);wanted.append(native_contacts(d))
    yield 'refits',serialize(rows[0],frames=rows[1:]),wanted,True
    base=rows[0];groups={int(r[1]) for r in base if r[0] != 0}
    group_ids=sorted(groups)
    for label,kw in [
        ('excluded',dict(exclusions=[tuple(group_ids)])),
        ('explicit-excluded',dict(exclusions=[tuple(group_ids)],explicit=[(1,65,0,0,3,1,1,.005,.0001,.0001)])),
        ('override',dict(override=.1)),
        ('zero-capacity',dict(capacity=0)),
        ('disabled',dict(enabled=False)),
    ]:
        yield label,serialize(base,**kw),None,False
    # Preserve large finite inputs; the endpoint BVH has no narrower domain.
    extreme=copy.deepcopy(base)
    for r in extreme:
        if r[0] != 0:r[12]=1e10-1; r[13]=r[1]*.2; r[14]=0
    yield 'large-coordinates',serialize(extreme),None,False
    sleeping=copy.deepcopy(base)
    for r in sleeping:r[24]=1
    yield 'sleeping',serialize(sleeping,sleep=True),None,False
    cm=mujoco.MjModel.from_xml_string(compound_xml(257,True));cd=mujoco.MjData(cm)
    mujoco.mj_kinematics(cm,cd)
    yield 'capacity-candidates',serialize(extract(cm,cd)[0]),None,False
    boundary=mujoco.MjModel.from_xml_string(compound_xml(2048));bd=mujoco.MjData(boundary)
    mujoco.mj_fwdPosition(boundary,bd)
    yield 'max-geometries',serialize(extract(boundary,bd)[0]),native_contacts(bd),True
    yield 'empty-after-max',serialize([]),[],True


def run(before,after,out):
    out.mkdir(parents=True,exist_ok=False)
    fixtures=list(cases());text=''.join(f[1] for f in fixtures)
    # Each moving input emits one result per frame.
    expected=[]
    for name,_,want,native in fixtures:
        if name=='refits':expected.extend((f'{name}-{i}',w,native) for i,w in enumerate(want))
        else:expected.append((name,want,native))
    (out/'input.txt').write_text(text)
    runs={}
    for label,path in [('before',before/'build/release/bin/scene_probe'),
                       ('checked',after/'build/validation/bin/scene_probe'),
                       ('release',after/'build/release/bin/scene_probe')]:
        r=subprocess.run([str(path),'bvh-stats'],input=text,text=True,capture_output=True,timeout=180)
        (out/(label+'.stdout')).write_text(r.stdout);(out/(label+'.stderr')).write_text(r.stderr)
        if r.returncode:raise RuntimeError((label,r.returncode,r.stderr[-2000:]))
        runs[label]=r.stdout.splitlines()
        if len(runs[label])!=len(expected):raise RuntimeError((label,len(runs[label]),len(expected)))
    failures=[]
    for i,(name,want,native) in enumerate(expected):
        if runs['before'][i]!=runs['checked'][i] or runs['before'][i]!=runs['release'][i]:
            failures.append(dict(case=name,reason='ordered complete Ada outputs differ'))
        if native:
            status,contacts,_,_=parse(runs['checked'][i])
            by_pair={}
            for c in want:by_pair.setdefault(c['pair'],[]).append(c)
            error=None
            if len(contacts)!=len(want):error=dict(reason='count',ada=len(contacts),c=len(want))
            for c in contacts:
                key=tuple(map(int,c[:2]));group=by_pair.pop(key,[])
                e=match(np.asarray([c]),group)
                if e:error=e;break
            if status!='SUCCESS' or error:failures.append(dict(case=name,reason='C contact fields',details=error))
    # Diagnostics are reported separately; stdout remains the original API.
    stats=(out/'checked.stderr').read_text().splitlines()
    active=sum(int(line.split()[1])>0 for line in stats if line.startswith('BVH '))
    if not active:failures.append(dict(reason='no case exercised the BVH'))
    result=dict(reference=mujoco.__version__,cases=len(expected),native_cases=sum(x[2] for x in expected),
                exact_ordered_before_after=len(expected)-len(failures),bvh_active_frames=active,
                failures=failures,driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                binaries={label:hashlib.sha256(path.read_bytes()).hexdigest() for label,path in
                  [('before',before/'build/release/bin/scene_probe'),('checked',after/'build/validation/bin/scene_probe'),
                   ('release',after/'build/release/bin/scene_probe')]})
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
    return not failures


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    raise SystemExit(0 if run(a.before,a.after,a.out) else 1)
