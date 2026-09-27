#!/usr/bin/env python3
"""Rebuild final sources after ghost-only edits and compare executable sections."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
spec = importlib.util.spec_from_file_location('builder', HERE.parent/'dynamics_optimization/build.py')
b = importlib.util.module_from_spec(spec); spec.loader.exec_module(b)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--build', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--toolchain-root', type=Path, required=True)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
snapshot = a.out/'source'; snapshot.mkdir()
for directory in ['src','experimental/smooth/src']:
    for source in (REPO/directory).rglob('*.ad?'):
        target = snapshot/source.relative_to(REPO); target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,target)
for source in [HERE.parent/'movement_bench.adb', REPO/'experimental/smooth/tests/smooth_probe.adb']:
    target=snapshot/source.relative_to(REPO);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,target)
metadata=json.loads((a.build/'build.json').read_text())
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
identities={}
for variant in ['current','checked']:
    work=a.out/variant;work.mkdir();src=work/'source';shutil.copytree(snapshot,src)
    main='movement_bench' if variant=='current' else 'smooth_probe'
    project=b.isolated_project(src,work,main)
    text=project.read_text().replace('project Fragment is',f'project Fragment is\n   for Main use ("{main}.adb");\n   for Exec_Dir use "bin";')
    if variant=='current':
        start=text.index('        ("-gnat2022"');stop=text.index(';',start)
        text=text[:start]+'('+', '.join('"'+f+'"' for f in b.FLAGS)+')'+text[stop:]
        text=text.replace('end Fragment;','   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
    project.write_text(text)
    command=['gprbuild','-P',str(project),'-j2']
    with (work/'build.log').open('w') as log:
        subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    binary=work/'bin'/main;previous=a.build/variant/'bin'/main
    sections={}
    for section in ['.text','.rodata']:
        old=work/('prior'+section);new=work/('final'+section)
        subprocess.run(['objcopy','--dump-section',section+'='+str(old),str(previous)],check=True)
        subprocess.run(['objcopy','--dump-section',section+'='+str(new),str(binary)],check=True)
        sections[section]=dict(prior_sha256=b.digest(old),final_sha256=b.digest(new),identical=old.read_bytes()==new.read_bytes())
    identities[variant]=dict(prior_binary=b.digest(previous),final_binary=b.digest(binary),identical=b.digest(previous)==b.digest(binary),sections=sections)
    metadata['builds'][variant]=dict(command=command,binary=str(binary),binary_sha256=b.digest(binary),sources={str(p.relative_to(src)):b.digest(p) for p in src.rglob('*.ad?')})
    print(variant,identities[variant],flush=True)
(a.out/'baseline').symlink_to(a.build.resolve()/'baseline')
(a.out/'movement_c').symlink_to(a.build.resolve()/'movement_c')
metadata['sources']={str(p.relative_to(snapshot)):b.digest(p) for p in snapshot.rglob('*.ad?')}
metadata['final_rebuild_from']=str(a.build)
metadata['harness'][str(Path(__file__).relative_to(REPO))]=b.digest(Path(__file__))
(a.out/'build.json').write_text(json.dumps(metadata,indent=2)+'\n')
(a.out/'identity.json').write_text(json.dumps(identities,indent=2)+'\n')
