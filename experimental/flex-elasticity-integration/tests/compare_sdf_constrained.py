"""Isolated-model SDF/flex movement corpus; the official C library is unmodified."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
import xml.etree.ElementTree as ET
import mujoco
import compare_constrained as base

VERTICES = '-.2 -.2 -.2 .2 -.2 -.2 .2 .2 -.2 -.2 .2 -.2 -.2 -.2 .2 .2 -.2 .2 .2 .2 .2 -.2 .2 .2'

def fixture(solver='Newton', cone='pyramidal', condim=3, *, free=False, pinned=False,
            moving=False, mixed=False, starts=4, dim=2, disabled=None, offset=False, centered=False):
    tree=ET.fromstring(base.fixture(dim=dim,mode=('stretch' if free else 'both') if dim==2 else 'none',free=free,pinned=pinned))
    option=tree.find('option');option.attrib.update(solver=solver,cone=cone,jacobian='sparse',
        iterations='200',tolerance='1e-12',sdf_initpoints=str(starts),sdf_iterations='10')
    flags=option.find('flag');flags.attrib.clear();flags.attrib.update(warmstart='disable',island='disable')
    if disabled:flags.set(disabled,'disable')
    asset=ET.SubElement(tree,'asset')
    if offset:ET.SubElement(asset,'mesh',dict(name='unused',vertex=VERTICES,scale='.5 .5 .5'))
    ET.SubElement(asset,'mesh',dict(name='field',vertex=VERTICES))
    world=tree.find('worldbody');parent=world
    if offset:
        ET.SubElement(world,'geom',dict(type='sdf',mesh='unused',pos='5 5 5',contype='0',conaffinity='0'))
    if moving:
        parent=ET.SubElement(world,'body',dict(name='moving_field',pos='.3 .3 -.18',quat='.999 .01 .015 .005'))
        ET.SubElement(parent,'freejoint')
    ET.SubElement(parent,'geom',dict(type='sdf',mesh='field',pos='0 0 0' if moving else ('0 0 -.18' if centered else '.3 .3 -.18'),
        mass='2',condim=str(condim),friction='.6 .015 .004',margin='.002',gap='.001'))
    contact=tree.find('deformable/flex/contact');contact.attrib.update(contype='1',conaffinity='1',
        internal='false',selfcollide='none',condim=str(condim))
    if mixed:
        ET.SubElement(world,'geom',dict(type='plane',size='2 2 .1',pos='0 0 -.245',condim=str(condim)))
        body=ET.SubElement(world,'body',dict(pos='.55 .31 -.17'))
        ET.SubElement(body,'freejoint');ET.SubElement(body,'geom',dict(type='sphere',size='.08',mass='1',condim=str(condim)))
    return ET.tostring(tree,encoding='unicode')

def fixtures():
    for solver in ('PGS','CG','Newton'):
        for condim in (1,3,6):
            yield f'element_sdf_{solver}_{condim}',fixture(solver=solver,condim=condim)
    for name,options in [('elliptic',dict(cone='elliptic',condim=6)),('free',dict(free=True)),
                         ('pinned',dict(pinned=True)),('moving',dict(moving=True)),
                         ('mixed',dict(mixed=True)),('offset',dict(offset=True)),
                         ('starts1',dict(starts=1)),('starts12',dict(starts=12))]:
        yield 'element_sdf_'+name,fixture(**options)
    for dim in (1,3):yield f'sdf_dim{dim}_no_contacts',fixture(dim=dim)
    for flag in ('midphase','contact','constraint'):
        yield 'sdf_disabled_'+flag,fixture(disabled=flag)
    yield 'element_sdf_disabled_midphase_centered',fixture(disabled='midphase',centered=True)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=2)
    p.add_argument('--steps',type=int,default=100);p.add_argument('--only');p.add_argument('--worker',action='store_true')
    p.add_argument('--upstream',type=Path,default=Path(__file__).resolve().parents[3]/'mujoco')
    a=p.parse_args()
    chosen=[(name,xml) for name,xml in fixtures() if not a.only or (name==a.only if a.worker else a.only in name)]
    if not chosen:raise ValueError('no fixtures selected')
    if a.worker:
        base.fixtures=lambda:iter(chosen)
        sys.argv=[sys.argv[0],'--binary',str(a.binary),'--out',str(a.out),'--samples',str(a.samples),'--steps',str(a.steps),'--diagnostic']
        base.main();return
    if mujoco.__version__!='3.14.0':raise RuntimeError('wrong reference')
    commit=subprocess.check_output(['git','-C',str(a.upstream),'rev-parse','HEAD'],text=True).strip()
    dirty=subprocess.check_output(['git','-C',str(a.upstream),'status','--porcelain','--untracked-files=no'],text=True).strip()
    if commit!='9ecbb9d7b5ee623f54745638d36799ff90e6f7cd' or dirty:raise RuntimeError('reference source must be the unmodified pinned release')
    a.out.mkdir(parents=True,exist_ok=False);records=[];failures=[];models=[]
    result=dict(reference=mujoco.__version__,reference_commit=commit,reference_status=dirty,
        steps=a.steps,samples=a.samples,complete=False,
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        library_sha256=hashlib.sha256((Path(mujoco.__file__).parent/'libmujoco.so.3.14.0').read_bytes()).hexdigest(),
        sources={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in [Path(__file__),Path(base.__file__),Path(__file__).with_name('compare.py')]},
        records=records,failures=failures,models=models)
    for name,_ in chosen:
        folder=a.out/name
        command=[sys.executable,str(Path(__file__).resolve()),'--worker','--only',name,
            '--binary',str(a.binary.resolve()),'--out',str(folder.resolve()),'--samples',str(a.samples),'--steps',str(a.steps)]
        with (a.out/(name+'.log')).open('w') as log:
            try:code=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=240).returncode
            except subprocess.TimeoutExpired:code=124
        receipt=folder/'results.json'
        if receipt.is_file():
            data=json.loads(receipt.read_text());records.extend(data['records']);failures.extend(data['failures'])
            if code and not data['failures']:failures.append(dict(model=name,error='worker incomplete',exit=code))
        else:failures.append(dict(model=name,error='worker ended before C/Ada receipt',exit=code))
        models.append(dict(model=name,exit=code,command=command,receipt=str(receipt)))
        result.update(cases=len(records),passed=sum(r['passed'] for r in records))
        (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(name,'exit',code,flush=True)
    result['complete']=True
    result['artifact_sha256']={str(f.relative_to(a.out)):hashlib.sha256(f.read_bytes()).hexdigest()
        for f in sorted(a.out.rglob('*')) if f.is_file() and f.name!='results.json'}
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))

if __name__=='__main__':main()
