from pathlib import Path
import os,sys,subprocess,json,hashlib,shutil
root=Path(__file__).resolve().parents[1];repo=root/'work'
sys.path.insert(0,str(repo/'experimental/smooth/tools'))
from prove_fragments import isolated_project
out=root/sys.argv[1];out.mkdir()
snapshot=out/'source'
for name in ('src','experimental/smooth'):
 shutil.copytree(repo/name,snapshot/name)
(snapshot/'tests').mkdir()
shutil.copy2(repo/'tests/movement_performance/movement_bench.adb',snapshot/'tests/movement_bench.adb')
env=os.environ.copy();tool=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH']=':'.join(str(next((tool/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
flags=['-gnat2022','-gnatn','-gnatp','-O3','-march=native','-flto','-ffat-lto-objects','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno','-ffunction-sections','-fdata-sections']
for main in ('movement_bench',):
 p=isolated_project(snapshot,out,main)
 s=p.read_text().replace('project Fragment is',f'project Fragment is\n   for Main use ("{main}.adb");\n   for Exec_Dir use "bin";')
 a=s.index('        ("-gnat2022"');b=s.index(';',a)
 s=s[:a]+'('+', '.join('"'+f+'"' for f in flags)+')'+s[b:]
 s=s.replace('end Fragment;','   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
 p.write_text(s)
 with (out/'build.log').open('w') as log: subprocess.run(['gprbuild','-P',str(p),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
manifest={'flags':flags,'source_hashes':{str(p.relative_to(snapshot)):hashlib.sha256(p.read_bytes()).hexdigest() for p in snapshot.rglob('*.ad?')},'binary_sha256':hashlib.sha256((out/'bin/movement_bench').read_bytes()).hexdigest(),'compiler':subprocess.check_output(['gcc','--version'],env=env,text=True)}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2));print(out,flush=True)
