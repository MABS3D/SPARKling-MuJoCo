#!/usr/bin/env python3
"""Frozen release build for activation workload comparisons (MuJoCo 3.14.0)."""
import argparse, hashlib, json, os, platform, shutil, subprocess, sys
from pathlib import Path
import mujoco
REPO=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--toolchain-root',type=Path,required=True)
p.add_argument('--c-library',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
assert mujoco.__version__=='3.14.0'
flags=['-gnat2022','-gnatn','-gnatp','-O3','-march=native','-flto','-ffat-lto-objects','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno','-ffunction-sections','-fdata-sections']
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
src=out/'source';src.mkdir()
for folder in ['src','experimental/smooth/src']:shutil.copytree(REPO/folder,src/folder)
for rel in ['tests/movement_performance/movement_bench.adb','tests/movement_performance/movement_c.c']:
 target=src/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(REPO/rel,target)
project=isolated_project(src,out,'movement_bench')
s=project.read_text().replace('project Fragment is','project Fragment is\n for Main use ("movement_bench.adb");\n for Exec_Dir use "bin";')
i=s.index('        ("-gnat2022"');j=s.index(';',i);s=s[:i]+'('+','.join('"'+f+'"' for f in flags)+')'+s[j:]
s=s.replace('end Fragment;',' package Linker is\n for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n end Linker;\nend Fragment;');project.write_text(s)
cmd=['gprbuild','-P',str(project),'-j2']
with (out/'build.log').open('w') as log:subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
cpp=Path(subprocess.check_output(['g++','-print-file-name=libstdc++.so'],env=env,text=True).strip()).resolve();lib=a.c_library.resolve()
cc=['gcc','-std=c11',*flags[3:],'-I'+str(Path(mujoco.__file__).parent/'include'),str(src/'tests/movement_performance/movement_c.c'),str(lib),str(cpp),'-Wl,-rpath,'+str(lib.parent)+':'+str(cpp.parent),'-o',str(out/'movement_c')]
with (out/'c-build.log').open('w') as log:subprocess.run(cc,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
manifest=dict(oracle=mujoco.__version__,platform=platform.platform(),cpu=Path('/proc/cpuinfo').read_text(),tools={t:subprocess.check_output([t,'--version'],env=env,text=True).splitlines()[0] for t in ['gcc','gprbuild','gnatprove']},builds={'ada':dict(binary=str(out/'bin/movement_bench'),sha256=sha(out/'bin/movement_bench'),flags=flags,command=cmd),'c':dict(binary=str(out/'movement_c'),binary_sha256=sha(out/'movement_c'),library=str(lib),library_sha256=sha(lib),cpp_runtime=str(cpp),cpp_runtime_sha256=sha(cpp),command=cc)},sources={str(p.relative_to(src)):sha(p) for p in src.rglob('*') if p.is_file() and p.suffix in ['.ads','.adb','.c']})
(out/'manifest.json').write_text(json.dumps(manifest,indent=2));print(out)
