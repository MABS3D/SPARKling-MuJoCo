#!/usr/bin/env python3
"""Proof diagnostics on smallest subprograms, then fresh entire units."""
from pathlib import Path
import argparse,hashlib,json,os,re,resource,shutil,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experimental/smooth/tools'))
from prove_fragments import isolated_project
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);ap.add_argument('--unit',default='mj-adhesion');ap.add_argument('--phase',choices=['small','whole'],default='small');ap.add_argument('--only');ap.add_argument('--seconds',type=int,default=5);ap.add_argument('--jobs',type=int,default=1);ap.add_argument('--provers',default='cvc5,z3,altergo');args=ap.parse_args()
out=args.out.resolve();out.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env['PATH']=':'.join(str(next((tc/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':'+env['PATH']
resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
snapshot=out/'source';snapshot.mkdir(exist_ok=True)
for rel in ['src','experimental/smooth/src','experimental/actuation-integration/src','experimental/frictionless-contact-candidate/src','experimental/collision/src']:
 shutil.copytree(ROOT/rel,snapshot/rel,dirs_exist_ok=True)
hashes={str(p.relative_to(snapshot)):hashlib.sha256(p.read_bytes()).hexdigest() for p in snapshot.rglob('*') if p.is_file()}
(out/'source-sha256.json').write_text(json.dumps(hashes,indent=2))
p=isolated_project(snapshot,out,args.unit)
source=snapshot/('experimental/smooth/src' if args.unit=='mj-activation' or args.unit.startswith('mj-data') or args.unit=='mj-smooth_actuation' else 'experimental/actuation-integration/src')
items=[]
if args.phase=='whole':items=[(args.unit+'.adb',None,'whole')]
else:
 for suffix in ['ads','adb']:
  path=source/(args.unit+'.'+suffix)
  for line,s in enumerate(path.read_text().splitlines(),1):
   m=re.match(r'\s*(function|procedure) (\w+)\b',s)
   if not m or (args.only and m[2]!=args.only):continue
   if suffix=='ads' and (m[1]=='procedure' or m[2] in {'Select_Rows','Add','Project','Apply_Force','Moment_For','Evaluate','Step','Exact_Factor','Next_Value','Prepare','Active_Column','Gap_Column','Normalize','Column_For'}):continue
   items.append((path.name,line,m[2]))
records=[]
for file,line,name in items:
 label=f'{file}-{line or "whole"}-{name}'
 reports=out/(args.unit+'-obj')/'gnatprove'
 if reports.exists():
  for f in reports.glob('*.spark'):f.unlink()
 cmd=[sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3800','--timeout','300','--','gnatprove','-P',str(p),'-u',args.unit+'.adb','--prover='+args.provers,f'--timeout={args.seconds}','--steps=0','--memlimit=512','--proof=per_check','--counterexamples=off','--checks-as-errors=on','--report=all','--warnings=continue','-j'+str(args.jobs)]
 if line:cmd.append(f'--limit-subp={file}:{line}')
 start=time.time();r=subprocess.run(cmd,env=env,cwd=ROOT,capture_output=True,text=True);(out/(label+'.log')).write_text(r.stdout+r.stderr)
 structured={f.name:json.loads(f.read_text()) for f in reports.glob('*.spark')}
 (out/(label+'.spark.json')).write_text(json.dumps(structured,indent=2))
 proof=[x for j in structured.values() for x in j.get('proof',[])];flow=[x for j in structured.values() for x in j.get('flow',[])]
 bad=[x for x in proof+flow if x.get('severity') in ['error','low','medium','high']]
 row=dict(name=name,file=file,line=line,exit=r.returncode,seconds=time.time()-start,checks=len(proof),flow=len(flow),open=len(bad),source_hashes=hashes,command=cmd)
 records.append(row);(out/'results.json').write_text(json.dumps(records,indent=2));print(label,{k:row[k] for k in ['exit','checks','open']},flush=True)
 if args.phase=='whole':
  for j in structured.values():
   assert not j.get('skip_proof') and not j.get('skip_flow_proof') and not j.get('pragma_assume')
   assert j.get('progress')=='PROGRESS_PROOF' and j.get('stop_reason')=='STOP_REASON_NONE'
 if r.returncode:print('\n'.join(s for s in (r.stdout+r.stderr).splitlines() if 'error:' in s or 'medium:' in s or 'high:' in s or 'low:' in s)[-3000:],flush=True)

sys.exit(0 if records and all(r["exit"]==0 and r["open"]==0 for r in records) else 1)
