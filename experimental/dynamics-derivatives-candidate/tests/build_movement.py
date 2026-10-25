"""Build a paired full-movement diagnostic with checks retained and exact pins."""
import argparse,hashlib,json,shutil,subprocess,os
from pathlib import Path
import mujoco
from build import ROOT,environment,FOLDERS,compiler_flags,linker_flags,solver_kernel_switches

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--baseline',type=Path,required=True);p.add_argument('--current',type=Path,required=True)
 p.add_argument('--no-lto',action='store_true',help='Diagnostic control; release LTO defaults on')
 p.add_argument('--out',type=Path,required=True);p.add_argument('--align',type=int,choices=[16,32,64]);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 assert mujoco.__version__=='3.17.0' and mujoco.mj_version()==3_017_000
 env=environment();flags=compiler_flags('release',lto=not a.no_lto);link=linker_flags('release',lto=not a.no_lto)
 if a.align:flags += ['-falign-functions='+str(a.align),'-falign-loops='+str(a.align)]
 builds={};snapshots={}
 for name,original in [('baseline',a.baseline),('current',a.current)]:
  work=a.out/name;work.mkdir();source=work/'source';shutil.copytree(original/'source',source)
  hashes=json.loads((original/'sources.json').read_text());assert all(digest(source/n)==v for n,v in hashes.items())
  benchmark=ROOT/'experimental/dynamics-derivatives-candidate/tests/movement_all_probe.adb'
  rel='experimental/dynamics-derivatives-candidate/tests/'+benchmark.name
  shutil.copy2(benchmark,source/rel);hashes[rel]=digest(benchmark)
  (work/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n');snapshots[name]=dict(original=str(original),sources_sha256=digest(work/'sources.json'))
  folders=[source/f for f in FOLDERS]
  project=work/'movement.gpr';project.write_text('project Movement is\n for Source_Dirs use ('+', '.join('"'+str(f)+'"' for f in folders)+');\n for Object_Dir use "obj";\n for Exec_Dir use "bin";\n for Create_Missing_Dirs use "True";\n for Main use ("movement_all_probe.adb");\n package Compiler is\n'+solver_kernel_switches('release',flags)+' for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in flags)+');\n end Compiler;\n package Linker is\n for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in link)+');\n end Linker;\nend Movement;\n')
  command=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','600','--','gprbuild','-P',str(project),'-j1']
  with (work/'build.log').open('w') as log:r=subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT)
  if r.returncode:raise RuntimeError((work/'build.log').read_text()[-4000:])
  assert all(digest(source/n)==v for n,v in hashes.items())
  binary=work/'bin/movement_all_probe';builds[name]=dict(command=command,flags=flags,link_flags=link,lto=not a.no_lto,binary=str(binary),binary_sha256=digest(binary))
  print(name,'built',flush=True)
 c=a.out/'movement_all_c.c';shutil.copy2(Path(__file__).with_name(c.name),c)
 library=Path(mujoco.__file__).parent/'libmujoco.so.3.17.0'
 cpp=Path(subprocess.check_output(['g++','-print-file-name=libstdc++.so'],env=env,text=True).strip()).resolve()
 binary=a.out/'movement_c'
 command=['gcc','-std=c11','-O3','-march=native','-ffp-contract=off','-DREFERENCE_VERSION=3017000','-I'+str(library.parent/'include'),str(c),str(library),str(cpp),'-Wl,-rpath,'+str(library.parent)+':'+str(cpp.parent),'-o',str(binary)]
 with (a.out/'c-build.log').open('w') as log:subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
 builds['c']=dict(command=command,binary=str(binary),binary_sha256=digest(binary),library=str(library),library_sha256=digest(library),cpp_runtime=str(cpp),cpp_runtime_sha256=digest(cpp),library_build_flags='Unknown: official 3.17 wheel; this is diagnostic, not matched-build C parity acceptance.')
 tool={name:subprocess.check_output([name,'--version'],env=env,text=True).splitlines()[0] for name in ['gcc','gprbuild']}
 record=dict(reference='3.17.0',reference_commit='800a109a4bdd02cb60404d565db4ae16fb04a53b',builds=builds,snapshots=snapshots,toolchain=tool,scope='Integrated smooth Euler diagnostic, including ball/free joints and external loads. No suppressed Ada checks or unsafe FP flags. Wheel C compiler flags unknown; no full port or final C parity claim.')
 (a.out/'build.json').write_text(json.dumps(record,indent=2)+'\n');shutil.copy2(Path(__file__),a.out/'builder.py')
if __name__=='__main__':main()
