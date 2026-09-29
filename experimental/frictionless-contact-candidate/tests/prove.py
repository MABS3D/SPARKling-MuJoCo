#!/usr/bin/env python3
"""Small subprograms first; accept only subsequent complete-unit reports."""
from pathlib import Path
import argparse,hashlib,json,os,re,resource,shutil,subprocess,sys,time
from evidence import HERE,ROOT,snapshot,provenance,digest
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);ap.add_argument('--only',help='subprogram name filter for diagnostic runs');ap.add_argument('--phase',choices=['small','whole','all'],default='all');args=ap.parse_args()
out=args.out.resolve();out.mkdir(parents=True,exist_ok=True)
source_hashes=snapshot()
(out/'sources.json').write_text(json.dumps(source_hashes,indent=2)+'\n')
env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH']=':'.join(str(next((tc/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':'+env['PATH']
env['CONTACT_BUILD_ROOT']=str(out/'build')
(out/'environment.json').write_text(json.dumps(provenance(env),indent=2)+'\n')
resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
common=['gnatprove','-P',str(HERE/'contact.gpr'),'--prover=cvc5,z3,altergo','--timeout=10','--steps=0','--proof=per_check','-j2','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
reports=out/'build/validation/obj/gnatprove';records=[]
def run(unit,label,extra):
 cmd=[sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3800','--timeout','900','--',*common,'-u',unit+'.ads',*extra]
 (reports/(unit+'.spark')).unlink(missing_ok=True)
 start=time.time();p=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,text=True)
 (out/(label+'.log')).write_text(p.stdout+p.stderr)
 report=reports/(unit+'.spark');count={}
 if report.exists():
  d=json.loads(report.read_text());shutil.copyfile(report,out/(label+'.spark.json'))
  bad=[m for s in ['proof','flow','warn_error'] for m in d.get(s,[]) if m.get('severity') not in ['info','warning']]
  count={'checks':sum(m.get('severity')=='info' for s in ['proof','flow'] for m in d.get(s,[])),'open':len(bad),'warnings':sum(m.get('severity')=='warning' for sec in ['flow','proof','warn_error'] for m in d.get(sec,[]))}
  if label.startswith('whole-'):
   assert not d['skip_proof'] and not d['skip_flow_proof'] and not d['pragma_assume']
   assert all(x=='all' for x in d['spark'].values())
   assert d['progress']=='PROGRESS_PROOF' and d['stop_reason']=='STOP_REASON_NONE'
   assert report.stat().st_mtime>=start-2
   directory=HERE/'src' if unit!='mj-collision' else ROOT/'experimental/collision/src'
   prefix='MJ.'+unit.removeprefix('mj-').replace('-','.')
   declared=set()
   for filename in [directory/(unit+'.ads'),directory/(unit+'.adb')]:
    in_model=False
    for line in filename.read_text().splitlines():
     if 'package Model with' in line:in_model=True
     if 'end Model;' in line:in_model=False
     m=re.match(r'\s*(function|procedure) (\w+)\b',line)
     if m:declared.add((prefix+('.Model' if in_model else '')+'.'+m[2]).lower())
   names={d['entities'][k]['name'].lower() for k,v in d['spark'].items() if v=='all'}
   assert declared<=names,('missing complete-unit coverage',declared-names)
   count['subprograms']=sorted(declared)
   count['report_sha256']=digest(report)
   assert count['warnings']==0, 'review warnings before accepting evidence'
  assert source_hashes==snapshot(),'source changed during proof run' 
 records.append({'label':label,'code':p.returncode,'seconds':time.time()-start,'command':cmd,**count})
 (out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
 print(label,p.returncode,count,flush=True)
 if p.returncode and not count:
  raise RuntimeError((p.stdout+p.stderr)[-6000:])
 if p.returncode or count.get('open',0):
  print('\n'.join(x for x in p.stdout.splitlines() if re.search(r'error:|medium:|high:|low:',x))[-6000:],flush=True)
  return False
 return True
ok=True
if args.phase in ['all','small']:
 for unit in ['mj-contact_rows','mj-contact_slider']:
  for suffix in ['ads','adb']:
   lines=(HERE/'src'/(unit+'.'+suffix)).read_text().splitlines()
   for i,line in enumerate(lines,1):
    m=re.match(r'\s*(function|procedure) (\w+)\b',line)
    if not m:continue
    if args.only and m[2]!=args.only:continue
    if suffix=='ads' and not (next(j for j,l in enumerate(lines) if 'package Model' in l) < i-1 < next(j for j,l in enumerate(lines) if 'end Model' in l)):continue
    ok=run(unit,f'small-{unit}-{suffix}-{i}-{m[2]}',[f'--limit-subp={unit}.{suffix}:{i}']) and ok
if args.phase in ['all','whole']:
 for unit in ['mj-contact_rows','mj-contact_slider','mj-collision']:
  (reports/(unit+'.spark')).unlink(missing_ok=True)
  ok=run(unit,'whole-'+unit,[]) and ok
assert source_hashes==snapshot()
(out/'acceptance.json').write_text(json.dumps({'passed':ok,'phase':args.phase,'diagnostic_filter':args.only,'sources_unchanged':True},indent=2)+'\n')
sys.exit(0 if ok else 1)
