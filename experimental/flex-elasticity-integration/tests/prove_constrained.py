"""Report bounded proof/flow scopes against an immutable integrated closure."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment

def main():
 p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--scope',action='append',choices=['flow','state-flow','elastic-flow','sdf-flow','Evaluate','Step','whole',
  'weight-distance','weight-inverse','weight-normalize','weight-whole','sdf-admission','sdf-mesh-admission','sdf-body-admission','sdf-load','sdf-flex','bvh-whole'])
 a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False);snap=a.build.resolve()/'source'
 manifest=json.loads((a.build/'manifest.json').read_text())
 for name,h in manifest['sources'].items():
  if hashlib.sha256((snap/name).read_bytes()).hexdigest()!=h:raise RuntimeError('Snapshot mismatch: '+name)
 (a.out/'sources.json').write_text(json.dumps(manifest,indent=2)+'\n');rows=[]
 for scope in a.scope or ['flow','state-flow']:
  unit=('mj-bvh' if scope.startswith('bvh-') else 'mj-flex_contact_weights' if scope.startswith('weight-') else 'mj-flex_state' if scope=='state-flow' else 'mj-data-flex_elasticity' if scope=='elastic-flow' else 'mj-sdf_scene' if scope.startswith('sdf-') else 'mj-data-constrained-flex')
  env=environment();env.update(FLEX_BUILD_ROOT=str(a.out.resolve()/scope),FLEX_MODE='validation')
  cmd=['gnatprove','-P',str(snap/'experimental/flex-elasticity-integration/flex_constrained.gpr'),'-u',unit+'.adb','-j1','--report=all','--checks-as-errors=on','--warnings=continue','--no-inlining']
  if scope.endswith('flow'):cmd+=['--mode=flow']
  else:
   cmd+=['--mode=prove','--prover=cvc5,z3,altergo','--timeout='+('15' if scope=='bvh-whole' else '3'),'--memlimit=650','--steps=0','--proof=per_check','--counterexamples=off']
   if scope not in ('whole','weight-whole','bvh-whole'):
    path=snap/('experimental/sdf-step/src' if scope.startswith('sdf-') else 'experimental/flex-elasticity-integration/src')/f'{unit}.adb'
    subp={'weight-distance':'Distance','weight-inverse':'Inverse_Distance','weight-normalize':'Normalize','sdf-admission':'Geometry_Model_Valid','sdf-mesh-admission':'Mesh_Polygons_Valid','sdf-body-admission':'Body_Geometry_Valid','sdf-load':'Load','sdf-flex':'Collide_Flex'}.get(scope,scope)
    line=next(i for i,text in enumerate(path.read_text().splitlines(),1) if re.match(r'\s*(?:procedure|function) '+subp+r'\b',text))
    cmd+=['--limit-subp='+unit+'.adb:'+str(line)]
  started=time.monotonic()
  with (a.out/(scope+'.log')).open('w') as log:
   run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','900' if scope=='bvh-whole' else '180','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
  report=next((q for q in (a.out/scope).rglob('*.spark') if q.stem==unit),None);entries=[]
  if report:
   data=json.loads(report.read_text());shutil.copyfile(report,a.out/(scope+'.spark.json'))
   entries=[e for category in ('flow','proof','warn_error') for e in data.get(category,[])]
  opened=sum(e.get('severity') not in ('info','warning') for e in entries)
  row=dict(scope=scope,exit=run.returncode,seconds=time.monotonic()-started,command=cmd,checks=sum(e.get('severity')=='info' for e in entries),open=opened,warnings=sum(e.get('severity')=='warning' for e in entries),passed=run.returncode==0 and report is not None and opened==0)
  rows.append(row);print(json.dumps(row),flush=True)
  (a.out/'results.json').write_text(json.dumps(dict(scopes=rows,limits='Flow, bounded minimal proofs and complete functional proofs are distinct scopes.'),indent=2)+'\n')
 raise SystemExit(any(not r['passed'] for r in rows))
if __name__=='__main__':main()
