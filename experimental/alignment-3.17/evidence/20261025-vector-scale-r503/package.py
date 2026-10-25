from pathlib import Path
import hashlib,json,shutil,subprocess,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';O=E/'20261025-vector-scale-r503';Z=O/'vector-scale.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 actual=Path('/var/tmp/sparkling-adopt-vector-scale-r502-20261025');assert json.loads((actual/'complete.json').read_text())['passed'];O.mkdir();shutil.copy2(__file__,O/'package.py');inventory=json.loads((E/'inventory.json').read_text());assert len(inventory['files'])==125;owners=['experimental/smooth/src/mj-solver_kernels.ads','experimental/smooth/src/mj-solver_kernels.adb'];candidate=Path('/var/tmp/sparkling-vector-scale-r496-20261025');h=json.loads((candidate/'sources.json').read_text());assert all(sha(R/n)==h[n] for n in owners);assert all(sha(candidate/'source'/n)==v for n,v in h.items())
 folders=[Path('/var/tmp')/('sparkling-'+n+'-20261025') for n in ['scale-outline-baseline-r485','scale-outline-r486','scale-outline-min-r487','scale-outline-run-r488','inverse-init-r490','inverse-init-min-r491','inverse-init-r493','inverse-init-min-r494','inverse-init-run-r495','vector-scale-r496','vector-scale-min-r497','vector-scale-whole-r498','vector-scale-run-r499','vector-scale-gates-r501','adopt-vector-scale-r502']]
 manifest={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;data=p.read_bytes();manifest[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for folder in folders:
   assert folder.is_dir(),folder
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for name in ['sparkling-scale-outline-r486.py','sparkling-scale-outline-run-r488.py','sparkling-inverse-init-r490.py','sparkling-inverse-init-run-r492.py','sparkling-inverse-init-proof-r493.py','sparkling-inverse-init-run-r495.py','sparkling-vector-scale-r496.py','sparkling-vector-scale-run-r499.py','sparkling-inverse-init-gates-r500.py','sparkling-vector-scale-gates-r501.py','sparkling-adopt-vector-scale-r502.py']:put(Path('/tmp')/name,'recipes/'+name)
  for name in ['engine_core_smooth.c','engine_util_blas.c','engine_util_blas_avx.h']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/name,'c317-review/'+name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(manifest);assert all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in manifest.items())
 trials={}
 for name,root in [('outlined-only',folders[3]),('no-dummy-fill',folders[8]),('vector-scale',folders[12])]:
  sessions=[]
  for i in [1,2]:
   d=json.loads((root/f'session{i}/results.json').read_text());assert d['passed'] and d['source_and_binary_unchanged'] and len(d['records'])==30;sessions.append(dict(session=i,records=[{k:x[k] for k in ['model','state','statistics','current_over_baseline','current_over_c','checked_values','max_abs_c']} for x in d['records']]))
  trials[name]=dict(complete=json.loads((root/'complete.json').read_text()),sessions=sessions)
 dump(O/'summary.json',dict(adopted='vector-scale',source_binding=json.loads((actual/'source-binding.json').read_text()),actual_default=json.loads((actual/'complete.json').read_text()),trials=trials,gates=json.loads((folders[13]/'complete.json').read_text()),plain_no_fill_proof=json.loads((folders[5]/'results.json').read_text()),initialized_no_fill_proof=json.loads((folders[7]/'results.json').read_text()),unexecuted_recipes=['r492 no-fill coordinator (failed plain-flow precursor)','r500 no-fill promotion gates (rejected performance)'],scope='Exact ordered Scale_Row multiplication/rejection/frame contracts and numerical/performance evidence in supported smooth Euler. Small ball/tendon movement regressions explicit; no all-workload C parity, whole dynamics Gold or full port completion. No-dummy-fill proof is scoped safety/initialization, not full functional factorization; it is not adopted.'))
 dump(O/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Only obj/analysis/__pycache__/.git components. Frozen sources, copied SPARK reports, logs, builds, binaries, all raw trajectory samples and fixtures remain. External toolchains/reference shared libraries identified by hashes, not embedded.'))
 dump(O/'verification.json',dict(passed=True,zip_sha256=sha(Z),archive_members_verified=len(manifest),actual_owner_hashes_verified=True,private_actual_source_and_binary_bridges_verified=True,prior_inventory_entries=125,scope='Archive/source verification separate from proof, numeric correctness and measured performance.'));print('ARCHIVE READY',Z.stat().st_size,len(manifest),flush=True)
if __name__=='__main__':main()
