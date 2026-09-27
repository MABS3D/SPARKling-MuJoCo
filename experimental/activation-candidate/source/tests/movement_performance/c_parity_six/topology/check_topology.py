#!/usr/bin/env python3
"""Check simple-path selection, C model metadata, stale M0, and cache ownership."""
import argparse, hashlib, json, os, shutil, subprocess, sys
from pathlib import Path
import mujoco
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[3]
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project, source_files
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--build',type=Path,help='Optional immutable integrated build snapshot')
p.add_argument('--toolchain-root',type=Path,required=True)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
src=a.out/'source';src.mkdir()
input_root=a.build/'source' if a.build else REPO
paths=sorted(input_root.rglob('*.ad?')) if a.build else source_files(REPO)
for path in paths:
    if path.suffix not in ('.ads','.adb'): continue
    target=src/path.relative_to(input_root);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,target)
for path in HERE.glob('*.ad?'):
    target=src/'tests'/path.name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,target)
models=[]
for fixture in sorted((HERE.parent/'fixtures').glob('simple*.xml')):
    m=mujoco.MjModel.from_xml_path(str(fixture))
    assert all(m.dof_simplenum>0),fixture
    dest=a.out/(fixture.stem+'.mjb');mujoco.mj_saveModel(m,str(dest))
    models.append(dict(xml=str(fixture),mjb=str(dest),nv=m.nv,simplenum=m.dof_simplenum.tolist(),rows=m.M_rownnz.tolist(),fixed=m.dof_M0.tolist()))
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
results=[]
for variant in ['checked','release']:
    work=a.out/variant;work.mkdir();project=isolated_project(src,work,'topology_probe')
    text=project.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("topology_probe.adb");\n   for Exec_Dir use "bin";')
    if variant=='release':
        text=text.replace('"-gnata"','"-gnatp", "-O3"').replace(', "-gnato", "-gnatVa"','')
    project.write_text(text)
    with (work/'build.log').open('w') as log:subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    binary=work/'bin/topology_probe'
    run=subprocess.run([str(binary),*[m['mjb'] for m in models]],text=True,capture_output=True,timeout=300)
    (work/'output.txt').write_text(run.stdout+run.stderr);run.check_returncode()
    results.append(dict(variant=variant,output=run.stdout,binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest()))
    print(variant,run.stdout.strip(),flush=True)
(a.out/'results.json').write_text(json.dumps(dict(status='passed',mujoco=mujoco.__version__,models=models,sources={str(p.relative_to(src)):hashlib.sha256(p.read_bytes()).hexdigest() for p in src.rglob('*.ad?')},results=results),indent=2)+'\n')
