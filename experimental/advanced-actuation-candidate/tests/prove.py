#!/usr/bin/env python3
from pathlib import Path
import argparse,hashlib,json,os,re,resource,subprocess,time,shutil
here=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--unit',default='mj-actuator_curves');ap.add_argument('--subprogram');ap.add_argument('--out',type=Path,required=True);ap.add_argument('--timeout',type=int,default=2);ap.add_argument('--provers',default='z3,cvc5');a=ap.parse_args()
a.out.mkdir(parents=True,exist_ok=True)
manifest={str(f.relative_to(here)):hashlib.sha256(f.read_bytes()).hexdigest() for d in ['base','src'] for f in (here/d).glob('*.ad*')}
(a.out/'sources.json').write_text(json.dumps(manifest,indent=2)+'\n')
tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy()
env['PATH']=':'.join(str(next((tc/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':/usr/bin:/bin'
env['ACTUATION_BUILD_ROOT']=str(a.out/'build')
resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
cmd=['gnatprove','-P',str(here/'actuation.gpr'),'-u',a.unit+'.ads','--prover='+a.provers,'--timeout='+str(a.timeout),'--steps=0','--proof=per_check','-j2','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
if a.subprogram:
 f=here/'src'/(a.unit+'.adb'); lines=f.read_text().splitlines()
 line=next(i for i,l in enumerate(lines,1) if re.match(r'\s*(function|procedure) '+a.subprogram+r'\b',l))
 cmd.append(f'--limit-subp={f.name}:{line}')
start=time.time()
cmd=['python3',str(here.parents[1]/'tools/guarded.py'),'--cap-mb','3000','--min-free-mb','2000','--timeout','600','--',*cmd]
r=subprocess.run(cmd,env=env,cwd=here,capture_output=True,text=True,timeout=650)
(a.out/'run.log').write_text(r.stdout+r.stderr)
report=a.out/'build/validation/obj/gnatprove'/(a.unit+'.spark')
info={'exit_code':r.returncode,'seconds':time.time()-start,'command':cmd,'subprogram':a.subprogram}
if report.exists():
 d=json.loads(report.read_text());shutil.copyfile(report,a.out/'report.spark.json')
 info.update(checks=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in d.get(k,[])),open=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[]) if x.get('severity') not in ['info','warning']],warnings=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[]) if x.get('severity')=='warning'])
 info['skip_proof']=d.get('skip_proof');info['skip_flow_proof']=d.get('skip_flow_proof');info['pragma_assume']=d.get('pragma_assume');info['spark']=d.get('spark');info['progress']=d.get('progress');info['stop_reason']=d.get('stop_reason')
 info['fresh']=report.stat().st_mtime>=start-2
 info['covered']=[d['entities'][k]['name'] for k,v in d.get('spark',{}).items() if v=='all']
info['sources_unchanged']=manifest=={str(f.relative_to(here)):hashlib.sha256(f.read_bytes()).hexdigest() for folder in ['base','src'] for f in (here/folder).glob('*.ad*')}
if not a.subprogram and report.exists():
 prefix='MJ.'+a.unit.removeprefix('mj-').replace('-','.')
 declared=set()
 for suffix in ['ads','adb']:
  in_model=False
  for line in (here/'src'/(a.unit+'.'+suffix)).read_text().splitlines():
   if 'package Model with' in line:in_model=True
   if 'end Model;' in line:in_model=False
   match=re.match(r'\s*(function|procedure) (\w+)\b',line)
   if match:declared.add((prefix+('.Model' if in_model else '')+'.'+match[2]).lower())
 info['coverage_ok']=declared<=set(x.lower() for x in info['covered'])
 info['missing_coverage']=sorted(declared-set(x.lower() for x in info['covered']))
 info['all_in_spark']=all(v=='all' for v in info.get('spark',{}).values())
if a.subprogram and report.exists():
 info['coverage_ok']=any(x.lower().endswith('.'+a.subprogram.lower()) for x in info['covered'])
 info['all_in_spark']=all(v=='all' for v in info.get('spark',{}).values())
# These small bodies and their callees were inspected: they contain no calls to
# elementary functions. GNAT emits whole-file runtime-model warnings even with
# --limit-subp. Retain them in the evidence, and review only those outside the
# selected declaration/body; never waive such warnings for a complete unit.
pure_targets={('mj-actuator_geometry','Product'),('mj-actuator_geometry','Multiply'),
              ('mj-actuator_geometry','Mat_Vector'),('mj-actuator_geometry','SO3_Force'),
              ('mj-advanced_actuators','Slots'),('mj-actuator_transmissions','Reset')}
ranges={}
if (a.unit,a.subprogram) in pure_targets:
 for suffix in ['ads','adb']:
  f=here/'src'/(a.unit+'.'+suffix);lines=f.read_text().splitlines();ranges[f.name]=[]
  starts=[i for i,line in enumerate(lines,1) if re.match(r'\s*(function|procedure) \w+\b',line)]
  for pos,first in enumerate(starts):
   if re.match(r'\s*(function|procedure) '+a.subprogram+r'\b',lines[first-1]):
    last=starts[pos+1]-1 if pos+1<len(starts) else len(lines)
    ranges[f.name].append((first,last))
def warning_review(w):
 if w.get('rule') in ['contracts-recursive','numeric-variant']:return 'explicit recursive model contract/termination obligation retained'
 name=Path(w.get('file','')).name;line=w.get('line',0)
 if w.get('rule')=='imprecise-call' and ranges and (here/'src'/name).is_file() and not any(lo<=line<=hi for lo,hi in ranges.get(name,[])):
  return 'outside selected pure subprogram; remains pending for complete unit'
 return None
info['warning_review']=[{'file':w.get('file'),'line':w.get('line'),'rule':w.get('rule'),'review':warning_review(w)} for w in info.get('warnings',[])]
info['reviewed_warnings']=all(x['review'] for x in info['warning_review'])
info['passed']=r.returncode==0 and not info.get('open') and info.get('fresh',False) and info['sources_unchanged'] and not any(info.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume']) and info.get('coverage_ok',True) and info.get('all_in_spark',True) and info['reviewed_warnings'] and info.get('progress')=='PROGRESS_PROOF' and info.get('stop_reason')=='STOP_REASON_NONE'
(a.out/'result.json').write_text(json.dumps(info,indent=2)+'\n')
print(json.dumps({'passed':info['passed'],'checks':info.get('checks'),'open':[{k:x.get(k) for k in ['file','line','rule','message']} for x in info.get('open',[])],'seconds':info['seconds']},indent=2),flush=True)
raise SystemExit(0 if info['passed'] else 1)
