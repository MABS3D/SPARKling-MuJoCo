from pathlib import Path
import json,hashlib,subprocess,sys
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');sys.path.insert(0,str(repo/'experimental/advanced-step/tests'));from build import environment
here=Path(__file__).resolve().parent;kernel=Path('/var/tmp/sparkling-services-controller-stage-caller2-r19-20261003/source')
files=[here/'stage_probe.adb',here/'stage_probe.gpr',Path(__file__),*[kernel/n for n in ['src/mj.ads','src/mj-types.ads','experimental/advanced-step/src/mj-advanced_state.ads','experimental/advanced-step/src/mj-advanced_state.adb']]]
def digest(f):return hashlib.sha256(f.read_bytes()).hexdigest()
source={str(f):digest(f) for f in files};result={'sources':source,'scope':'6720 comparisons of previous Ada Stage body versus new kernel; bit patterns, advance flag and exception class. Includes cases outside the index precondition only for backward-error-behavior diagnosis. Not a C physics corpus or proof outside the stated precondition.','modes':[]}
for mode in ['validation','release']:
 env=environment();env['STAGE_MODE']=mode
 cmds=[['gprbuild','-P',str(here/'stage_probe.gpr'),'-j1'],[str(here/'build'/mode/'bin/stage_probe')]]
 r={'mode':mode,'commands':cmds};result['modes'].append(r)
 for label,cmd in zip(['build','probe'],cmds):
  proc=subprocess.run([sys.executable,str(repo/'tools/guarded.py'),'--cap-mb','1200','--min-free-mb','700','--timeout','120','--',*cmd],cwd=here,env=env,text=True,capture_output=True)
  (here/(mode+'-'+label+'.log')).write_text(proc.stdout+proc.stderr);r[label+'_exit']=proc.returncode
  if label=='probe':r['output']=proc.stdout;r['binary_sha256']=digest(Path(cmd[0]))
  (here/'results.json').write_text(json.dumps(result,indent=2)+'\n')
  if proc.returncode:raise SystemExit(proc.returncode)
 r['passed']=[line for line in r.get('output','').splitlines() if line.startswith(('RESULT','FAIL'))]==['RESULT 6720 6720'];assert r['passed'],r
 print(mode,r['output'].strip(),flush=True)
result['sources_unchanged']=all(digest(Path(n))==h for n,h in source.items());assert result['sources_unchanged'];result['passed']=all(r['passed'] for r in result['modes']);(here/'results.json').write_text(json.dumps(result,indent=2)+'\n')
