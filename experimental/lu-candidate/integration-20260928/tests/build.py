from pathlib import Path
import os,subprocess,sys
root=Path(__file__).resolve().parents[1];r=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy();env['PATH']=':'.join(str(p) for part in ['gnat','gprbuild','gnatprove'] for p in (r/part).glob('*/bin'))+':'+env['PATH']
p=subprocess.run(['gprbuild','-P',str(root/'lu.gpr'),'-j2']+sys.argv[1:],env=env,capture_output=True,text=True);(root/'evidence/build.log').write_text(p.stdout+p.stderr);print(p.stdout+p.stderr);raise SystemExit(p.returncode)
