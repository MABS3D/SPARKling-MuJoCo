"""Enumerate public reference symbols; never infer completion from name matches."""
import argparse, csv, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
headers=sorted(a.reference.glob('*.h'))
records={};hashes={};callbacks=[]
def group(s):
 for prefix,label in [('mjrf','render-filament'),('mjr_','render'),('mjv_','visualization'),('mjui_','ui'),('mjs_','specification-compiler'),('mjp_','plugin-resource'),('mju_','utility')]:
  if s.startswith(prefix):return label
 if s in ['mj_loadXML','mj_parseXML','mj_parseXMLString','mj_parse','mj_compile','mj_recompile','mj_saveXML','mj_saveXMLString','mj_saveLastXML','mj_makeSpec','mj_copySpec','mj_deleteSpec']:return 'specification-compiler'
 return 'engine-model-runtime'
for h in headers:
 raw=h.read_text();hashes[h.name]=hashlib.sha256(h.read_bytes()).hexdigest()
 # Blank comments without changing offsets/line numbers.
 text=re.sub(r'/\*.*?\*/|//[^\n]*',lambda m:''.join('\n' if c=='\n' else ' ' for c in m[0]),raw,flags=re.S)
 for m in re.finditer(r'(?m)^(?:MJAPI\s+)?(?:[A-Za-z_]\w*[ \t*]+)+(mj\w+)\s*\([^;{}]*\)\s*;',text):
  symbol=m[1];records[symbol]=dict(symbol=symbol,kind='function',header=h.name,line=text.count('\n',0,m.start())+1,group=group(symbol),declaration=' '.join(m[0].split()),ada_entry='',implementation='unmapped',linked='no public mapping recorded',tested='pending',proved='pending',remaining='audit and connect native implementation; add missing implementation as required')
 for m in re.finditer(r'(?m)^MJAPI\s+extern\b[^;]+;',text):
  d=m[0];fp=re.search(r'\(\*(\w+)\)',d)
  name=fp[1] if fp else re.search(r'(\w+)\s*(?:\[[^;]*\])?\s*;',d)[1]
  records[name]=dict(symbol=name,kind='callback-hook' if fp or name.startswith('mjcb_') else 'data',header=h.name,line=text.count('\n',0,m.start())+1,group='public-data-callbacks',declaration=' '.join(d.split()),ada_entry='',implementation='unmapped',linked='no public mapping recorded',tested='pending',proved='pending',remaining='native public state/callback design and lifecycle')
 if h.name=='mjplugin.h':
  for m in re.finditer(r'\(\*(\w+)\)\s*\(',text):callbacks.append(dict(field=m[1],header=h.name,line=text.count('\n',0,m.start())+1,status='public callback contract; native plugin runtime covers a subset, C ABI/resource dispatch pending'))
mapping={
 'mj_version':('MJ.API.Version','API smoke','constant'),
 'mj_versionString':('MJ.API.Version_String','API smoke','constant'),
 'mj_stateSize':('MJ.API.State.State_Size','state differential 2992-case corpus','exact prefix/size relation; state unit157 proof checks'),
 'mj_getState':('MJ.API.State.Get_State','state differential 2992-case corpus','state unit157 proof checks; see per-entry success/frame scope'),
 'mj_setState':('MJ.API.State.Set_State','state differential 2992-case corpus','state unit157 proof checks; see per-entry success/frame scope'),
 'mj_extractState':('MJ.API.State.Extract_State','state differential 2992-case corpus','state unit157 proof checks; see per-entry success/frame scope'),
 'mj_copyState':('MJ.API.State.Copy_State','state differential 2992-case corpus','state unit157 proof checks; see per-entry success/frame scope'),
 'mj_name2id':('MJ.API.Names.Name2id','330 loaded-name comparisons','pending'),
 'mj_id2name':('MJ.API.Names.Id2name','330 loaded-name comparisons','pending'),
 'mju_type2Str':('MJ.API.Model_Info.Type_Name','state/model-info differential','pending'),
 'mju_str2Type':('MJ.API.Model_Info.Name_Type','API smoke roundtrip','pending'),
 'mj_isSparse':('MJ.API.Model_Info.Is_Sparse','state/model-info differential','pending'),
 'mj_isPyramidal':('MJ.API.Model_Info.Is_Pyramidal','state/model-info differential','pending'),
 'mj_isDual':('MJ.API.Model_Info.Is_Dual','state/model-info differential','pending'),
 'mj_makeData':('MJ.API.Runtime.Make_Data','API smoke with freed source model','composition pending'),
 'mj_deleteData':('MJ.API.Runtime.Delete_Data','API smoke repeated deletion','composition pending'),
 'mj_resetData':('MJ.API.Runtime.Reset_Data','API smoke owned reset','composition pending'),
 'mj_step':('MJ.API.Runtime.Step','API smoke 100 steps; component trajectories separately','composition pending'),
 'mj_RungeKutta':('MJ.Data.Integrators.Step (RK4)','512 integrated trajectories; 4 methods','Integration_Kernels42; composition pending'),
 'mj_implicit':('MJ.Data.Integrators.Step (Implicit_Velocity/Implicit_Fast)','512 integrated trajectories; 4 methods','Integration_Kernels42; PCG/operators/composition pending'),
 'mj_discrete':('MJ.Data.Integrators.Step (Discrete)','512 integrated trajectories; including solver tolerances','Integration_Kernels42; PCG/operators/composition pending'),
 'mj_forward':('MJ.API.Runtime.Forward','API smoke; component trajectories separately','composition pending'),
 'mj_inverse':('MJ.Data.Inverse.Evaluate / MJ.Data.Constrained.Inverse.Current','2848 scenarios on 712 model configurations','Inverse_Kernels 35 proof + 9 flow; mass exact relation and composition pending'),
 'mj_invConstraint':('MJ.Inverse_Constraints.Evaluate','412 prepared-row cases, including cancellation; exact C values','constraint response/composition proof pending'),
 'mjd_transitionFD':('MJ.Dynamics_Derivatives.Transition_FD','960 scenarios on 80 models, including adhesion and dense/sparse elliptic contacts','Derivative_Kernels82 proof +14flow; workspace composition pending'),
 'mjd_inverseFD':('MJ.Dynamics_Derivatives.Inverse_FD','960 scenarios on 80 models, including adhesion and dense/sparse elliptic contacts','Derivative_Kernels82 proof +14flow; workspace composition pending'),
 'mj_loadModel':('MJ.API.MJB.Load','API and component probes','current closure proof pending'),
 'mj_ray':('MJ.Rays.Cast','1440 primitives and6480 scene queries','Ray_Kernels72; composition pending'),
 'mj_multiRay':('MJ.Rays.Cast_Many','batch lifecycle/atomicity','Ray_Kernels72; composition pending'),
}
for s,r in records.items():
 if r['group'] in ['render','render-filament','visualization','ui','specification-compiler','plugin-resource']:
  r.update(implementation='missing public entry',remaining='implement public subsystem; recovered compiler address passes/native plugin callbacks are only a subset')
 if s in mapping:
  entry,test,proof=mapping[s];r.update(ada_entry=entry,implementation='native candidate',linked='explicit Ada entry; C ABI is not provided',tested=test,proved=proof,remaining='complete reference domains, full composition proof and representative performance')
  if s in ['mj_getState','mj_setState','mj_extractState','mj_copyState','mj_stateSize']:r['remaining']='packed caller-owned state API; link all owned engine producers and prove whole-unit success/frame contracts'
  if s in ['mj_RungeKutta','mj_implicit','mj_discrete']:r['remaining']='opt-in smooth adapter; link constraints, advanced actuation, flex, sleep and plugin; warning/public ABI and full composition proof pending'
  if s=='mj_multiRay':r['remaining']='repeat-query adapter; C angular aperture and bounding-sphere acceleration still missing'
  if s=='mj_inverse':r['remaining']='owned force API; constrained rows require current forward preparation; inverse-discrete, sensor side effects, all producers and full composition proof pending'
  if s=='mj_invConstraint':r['remaining']='prepared-row interface, no automatic geometry/equality producer; prove full response and composed callers'
  if s in ['mjd_transitionFD','mjd_inverseFD']:r['remaining']='owned scratch workspace; Euler currently admitted; sensor Jacobians, inverse-discrete, history, all producer combinations and full success/frame/composition proof pending'
report=dict(reference_version='3.14.0',reference_commit='9ecbb9d7b5ee623f54745638d36799ff90e6f7cd',header_sha256=hashes,scope='All top-level stable public C headers, including non-MJAPI Filament functions and public callbacks/data. Experimental USD C++ headers require a separate inventory.',symbols=sorted(records.values(),key=lambda r:r['symbol']),plugin_callback_contracts=callbacks)
(a.out/'public-symbols.json').write_text(json.dumps(report,indent=2)+'\n')
fields=['symbol','kind','group','header','line','ada_entry','implementation','linked','tested','proved','remaining']
with (a.out/'public-symbols.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');w.writeheader();w.writerows(report['symbols'])
from collections import Counter
print(json.dumps({'symbols':len(records),'kinds':dict(Counter(r['kind'] for r in records.values())),'groups':dict(Counter(r['group'] for r in records.values())),'mapped_candidates':len(mapping),'callback_contracts':len(callbacks)},indent=2))
