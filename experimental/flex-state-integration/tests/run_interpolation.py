"""Small immutable closure; serial guarded builds, comparisons and minimal proofs."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment
COMMON=['src/mj.ads','src/mj-types.ads',*[f'experimental/rigid-collision-candidate/src/{n}' for n in
 ('mj-rigid_geometry.ads','mj-contact_geometry.ads','mj-contact_geometry.adb')]]
OWNED=[f'experimental/flex-state-integration/{folder}/{name}' for folder,name in
 [('src','mj-flex_interpolation.ads'),('src','mj-flex_interpolation.adb'),('tests','flex_interpolation_probe.adb'),('tests','compare_interpolation.py')]]
SCOPES=['Flat_Bound','Phi','Basis_At','Basis','Cell_Of','Local_Of','Cell_For','Index_Of','Lookup','Add_Node','Add_Bounded','Ordered_Component','Same_Add','Sum_Step','Advance_Node','Interpolate','whole']
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--base',type=Path,required=True)
 p.add_argument('--scope',action='append',choices=SCOPES);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 snap=a.out/'source';snap.mkdir();base=json.loads((a.base/'manifest.json').read_text())['sources'];hashes={}
 for name in COMMON+OWNED:
  src=(a.base/'source' if name in COMMON else ROOT)/name;data=src.read_bytes();digest=hashlib.sha256(data).hexdigest()
  if name in COMMON and base[name]!=digest:raise RuntimeError('Base mismatch: '+name)
  (snap/Path(name).name).write_bytes(data);hashes[name]=digest
 project=snap/'interpolation.gpr'
 project.write_text('''project Interpolation is
 Mode := external ("INTERP_MODE", "validation");
 Root := external ("INTERP_BUILD_ROOT");
 for Source_Dirs use (".");
 for Object_Dir use Root & "/" & Mode & "/obj";
 for Exec_Dir use Root & "/" & Mode & "/bin";
 for Main use ("flex_interpolation_probe.adb");
 for Create_Missing_Dirs use "True";
 Flags := ("-gnat2022", "-ffp-contract=off");
 case Mode is
 when "release" => Flags := Flags & ("-O3", "-gnatn", "-march=native");
 when others => Flags := Flags & ("-O1", "-g", "-gnata", "-gnato", "-gnatVa");
 end case;
 package Compiler is
 for Default_Switches ("Ada") use Flags;
 end Compiler;
end Interpolation;
''')
 hashes['interpolation.gpr']=hashlib.sha256(project.read_bytes()).hexdigest()
 env=environment();rows=[];manifest=dict(sources=hashes,base=str(a.base),base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest(),steps=rows)
 def run(name,args,timeout=180):
  command=['/var/tmp/sparkling-movement-env/bin/python',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout',str(timeout),'--',*args]
  start=time.monotonic()
  with (a.out/(name+'.log')).open('w') as f:r=subprocess.run(command,env=env,stdout=f,stderr=subprocess.STDOUT)
  row=dict(name=name,exit=r.returncode,seconds=time.monotonic()-start,command=command);rows.append(row)
  (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(row),flush=True);return r.returncode
 for mode in ['validation','release']:
  env.update(INTERP_MODE=mode,INTERP_BUILD_ROOT=str(a.out/'build'))
  if run('build-'+mode,['gprbuild','-P',str(project),'-j1']):raise SystemExit(1)
  run('compare-'+mode,['/var/tmp/sparkling-movement-env/bin/python',str(snap/'compare_interpolation.py'),'--binary',str(a.out/'build'/mode/'bin/flex_interpolation_probe'),'--out',str(a.out/mode)])
 for scope in a.scope or SCOPES:
  if scope=='whole' and any(r['name'].startswith('proof-') and
    (r['exit'] or r.get('open',0) or r.get('report_absent',False)) for r in rows):
   manifest['whole_deferred']='Repair the failed minimal scopes before the fresh whole proof.'
   (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');break
  env.update(INTERP_MODE='validation',INTERP_BUILD_ROOT=str(a.out/'proof'/scope))
  args=['gnatprove','-P',str(project),'-u','mj-flex_interpolation.adb','-j1','--report=all','--checks-as-errors=on','--warnings=continue','--mode=prove','--no-inlining','--prover=cvc5,z3,altergo','--timeout=5','--memlimit=650','--steps=0','--proof=per_check','--counterexamples=off']
  if scope!='whole':
   line=next(i for i,t in enumerate((snap/'mj-flex_interpolation.adb').read_text().splitlines(),1) if re.match(r'\s*(?:function|procedure) '+scope+r'\b',t))
   args+=['--limit-subp=mj-flex_interpolation.adb:'+str(line)]
  run('proof-'+scope,args,360 if scope=='whole' else 180)
  report=next((a.out/'proof'/scope).rglob('mj-flex_interpolation.spark'),None)
  if report:
   shutil.copyfile(report,a.out/('proof-'+scope+'.spark.json'));data=json.loads(report.read_text())
   entries=[e for k in ['proof','flow','warn_error'] for e in data.get(k,[])]
   rows[-1].update(checks=sum(e.get('severity')=='info' for e in entries),open=sum(e.get('severity') not in ('info','warning') for e in entries),warnings=sum(e.get('severity')=='warning' for e in entries))
  else:rows[-1]['report_absent']=True
  (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 raise SystemExit(any(r['exit'] or r.get('open',0) or r.get('report_absent',False) for r in rows))
if __name__=='__main__':main()
