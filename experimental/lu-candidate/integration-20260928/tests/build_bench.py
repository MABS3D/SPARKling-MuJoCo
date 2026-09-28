from pathlib import Path
import os, subprocess, json, hashlib
root=Path(__file__).resolve().parents[1]
tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env=os.environ.copy()
env['PATH']=':'.join(str(p) for part in ['gnat','gprbuild','gnatprove'] for p in (tc/part).glob('*/bin'))+':'+env['PATH']
p=subprocess.run(['gprbuild','-P',str(root/'bench.gpr'),'-j2'],env=env,capture_output=True,text=True)
(root/'evidence/bench-build.log').write_text(p.stdout+p.stderr)
p.check_returncode()
compiler=str(next((tc/'gnat').glob('*/bin/gcc')))
subprocess.run([compiler,'-O3','-march=native','-ffp-contract=off',str(root/'tests/bench.c'),'-L'+str(root/'bin'),'-l:reference.so','-Wl,-rpath,$ORIGIN','-o',str(root/'bin/c_bench')],check=True)
(root/'evidence/bench-source.json').write_text(json.dumps({str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in (root/'src').glob('*')},indent=2))
