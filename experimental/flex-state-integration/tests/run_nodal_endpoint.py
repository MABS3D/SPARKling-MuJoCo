"""Freeze an owned-state endpoint against accepted geometry dependencies."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment
OWNED=[f'experimental/flex-state-integration/{folder}/{name}' for folder,name in [
 ('src','mj-flex_node_weights.ads'),('src','mj-flex_node_weights.adb'),
 ('src','mj-flex_state-nodal_contacts.ads'),('src','mj-flex_state-nodal_contacts.adb'),
 ('tests','flex_nodal_endpoint_probe.adb'),('tests','compare_nodal_endpoint.py'),('tests','compare_node_weights.py'),('tests','run_nodal_endpoint.py')]]
def main():
 p=argparse.ArgumentParser();p.add_argument('--base',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 snap=a.out/'source';base=json.loads((a.base/'manifest.json').read_text());hashes={}
 for name,h in base['sources'].items():
  data=(a.base/'source'/name).read_bytes()
  if hashlib.sha256(data).hexdigest()!=h:raise RuntimeError('base mismatch '+name)
  dest=snap/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data);hashes[name]=h
 for name in OWNED:
  data=(ROOT/name).read_bytes();(snap/name).write_bytes(data);hashes[name]=hashlib.sha256(data).hexdigest()
 pname='experimental/flex-state-integration/flex_state.gpr';project=snap/pname
 project.write_text(project.read_text().replace('flex_state_probe.adb','flex_nodal_endpoint_probe.adb'));hashes[pname]=hashlib.sha256(project.read_bytes()).hexdigest()
 rows=[];manifest=dict(sources=hashes,base=str(a.base),base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest(),steps=rows)
 env=environment();env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1')
 def run(name,args,timeout=360):
  cmd=['/var/tmp/sparkling-movement-env/bin/python',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout',str(timeout),'--',*args];start=time.monotonic()
  with (a.out/(name+'.log')).open('w') as f:r=subprocess.run(cmd,env=env,stdout=f,stderr=subprocess.STDOUT)
  rows.append(dict(name=name,exit=r.returncode,seconds=time.monotonic()-start,command=cmd));(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(rows[-1]),flush=True);return r.returncode
 env.update(FLEX_STATE_MODE='validation',FLEX_STATE_BUILD_ROOT=str(a.out/'proof'))
 run('proof-Weights',['gnatprove','-P',str(project),'-u','mj-flex_state-nodal_contacts.adb','-j1','--report=all','--checks-as-errors=on','--warnings=continue','--mode=prove','--no-inlining','--prover=cvc5,z3,altergo','--timeout=5','--memlimit=650','--steps=0','--proof=per_check','--counterexamples=off'],360)
 report=next((a.out/'proof').rglob('mj-flex_state-nodal_contacts.spark'),None)
 if report:
  shutil.copyfile(report,a.out/'proof-Weights.spark.json');d=json.loads(report.read_text());entries=[e for k in ['proof','flow','warn_error'] for e in d.get(k,[])];rows[-1].update(checks=sum(e.get('severity')=='info' for e in entries),open=sum(e.get('severity') not in ('info','warning') for e in entries),warnings=sum(e.get('severity')=='warning' for e in entries))
 else:rows[-1]['report_absent']=True
 if not rows[-1]['exit'] and not rows[-1].get('open',0) and not rows[-1].get('report_absent',False):
  for mode in ['validation','release']:
   env.update(FLEX_STATE_MODE=mode,FLEX_STATE_BUILD_ROOT=str(a.out/'build'))
   if run('build-'+mode,['gprbuild','-P',str(project),'-j1']):raise SystemExit(1)
   run('compare-'+mode,['/var/tmp/sparkling-movement-env/bin/python',str(snap/'experimental/flex-state-integration/tests/compare_nodal_endpoint.py'),'--root',str(ROOT),'--binary',str(a.out/'build'/mode/'bin/flex_nodal_endpoint_probe'),'--out',str(a.out/mode)],360)
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');raise SystemExit(any(r['exit'] or r.get('open',0) or r.get('report_absent',False) for r in rows))
if __name__=='__main__':main()
