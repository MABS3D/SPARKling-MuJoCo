#!/usr/bin/env python3
"""Build a checked probe injecting factor-row failures and checking atomicity/retry."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parents[2]/'experimental/smooth/tools'))
from prove_fragments import isolated_project
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--build',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--toolchain-root',type=Path,required=True)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
src=a.out/'source';shutil.copytree(a.build/'source',src)
for path in HERE.glob('mj-data-solver_checks.ad?'):
    shutil.copy2(path,src/'experimental/smooth/src'/path.name)
probe=src/'experimental/smooth/tests/smooth_probe.adb'
text='with MJ.Data.Solver_Checks;\n'+probe.read_text()
needle='         Set_State (D, Q, V, Input_Time, Result); Check;'
assert text.count(needle)==1
probe.write_text(text.replace(needle,needle+'\n         if C = 1 then MJ.Data.Solver_Checks.Check (D); end if;'))
project=isolated_project(src,a.out,'smooth_probe')
project.write_text(project.read_text().replace('project Fragment is',
    'project Fragment is\n   for Main use ("smooth_probe.adb");\n   for Exec_Dir use "bin";'))
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
with (a.out/'build.log').open('w') as log:
    subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(a.out/'manifest.json').write_text(json.dumps(dict(source_build=str(a.build),sources={str(p.relative_to(src)):sha(p) for p in src.rglob('*.ad?')},probe_sha256=sha(a.out/'bin/smooth_probe')),indent=2)+'\n')
