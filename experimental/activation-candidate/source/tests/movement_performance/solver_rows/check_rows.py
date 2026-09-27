#!/usr/bin/env python3
"""Exercise SIMD lanes/tails and rejection in checked and identical release flags."""
import argparse, hashlib, importlib.util, json, os, shutil, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parents[2]/'experimental/smooth/tools'))
from prove_fragments import isolated_project
spec=importlib.util.spec_from_file_location('builder',HERE.parent/'dynamics_optimization/build.py')
builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
p.add_argument('--toolchain-root',type=Path,required=True)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
src=a.out/'source';shutil.copytree(a.build/'source',src)
shutil.copy2(HERE/'rows_probe.adb',src/'tests/movement_performance/rows_probe.adb')
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
results=[]
for variant in ['checked','release']:
    work=a.out/variant;work.mkdir();project=isolated_project(src,work,'rows_probe')
    text=project.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("rows_probe.adb");\n   for Exec_Dir use "bin";')
    if variant=='release':
        start=text.index('        ("-gnat2022"');stop=text.index(';',start)
        text=text[:start]+'('+', '.join('"'+f+'"' for f in builder.FLAGS)+')'+text[stop:]
        text=text.replace('end Fragment;','   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
    project.write_text(text)
    with (work/'build.log').open('w') as log:subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    binary=work/'bin/rows_probe'
    run=subprocess.run([str(binary)],text=True,capture_output=True,timeout=60)
    (work/'output.txt').write_text(run.stdout+run.stderr)
    run.check_returncode()
    results.append(dict(variant=variant,output=run.stdout.strip(),binary_sha256=builder.digest(binary)))
    print(variant,run.stdout.strip(),flush=True)
(a.out/'results.json').write_text(json.dumps(dict(status='passed',source_build=str(a.build),sources={str(p.relative_to(src)):builder.digest(p) for p in src.rglob('*.ad?')},results=results),indent=2)+'\n')
