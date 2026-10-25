from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261025-direct-dot-contracts-r556';Z=D/'direct-dot-contracts.zip'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def root(n):return Path('/var/tmp')/('sparkling-'+n+'-20261025')
def main():
 old=json.loads((E/'inventory.json').read_text());assert len(old['files'])==143
 for n in ['direct-dot-min-r543','small-model-min-r560','small-row-min-r564']:assert json.loads((root(n)/'results.json').read_text())['obligations_closed']
 assert json.loads((root('direct-dot-gates-r555')/'complete.json').read_text())['passed'];assert json.loads((root('direct-dot-unit-r554')/'results.json').read_text())['exit']==99
 roots=['direct-dot-min-r524','direct-dot-triage-r526','direct-dot-r528','multiply-work-min-r529','add-lane-min-r530','direct-dot-triage-r531','direct-dot-build-r532','direct-dot-r534','fast-product-min-r535','direct-dot-triage-r536','direct-dot-build-r537','direct-dot-r538','fast-advance-min-r539','direct-dot-triage-r540','direct-dot-r541','direct-dot-triage-r542','direct-dot-min-r543','direct-dot-build-r544','direct-dot-corpus-r545','direct-dot-r546','direct-dot-triage-r547','direct-dot-r548','direct-dot-triage-r549','direct-dot-r551','reveal-valid-min-r552','direct-dot-triage-r553','direct-dot-unit-r554','direct-dot-gates-r555','direct-dot-replicas-r557','direct-dot-shared-build-r558','direct-dot-r559','small-model-min-r560','small-row-min-r561','direct-dot-replicas-r562','direct-dot-r563','small-row-min-r564','direct-dot-r565']
 D.mkdir();shutil.copy2(__file__,D/'package.py');manifest={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;data=p.read_bytes();manifest[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for name in roots:
   folder=root(name);assert folder.is_dir(),folder
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   if any(tag in p.name for tag in ['r528','r534','r537','r538','r541','r546','r548','r551','r555','r557','r558','r559','r563','r565','r566','r567']):put(p,'recipes/'+p.name)
  for name in ['engine_util_sparse.h','engine_util_sparse_avx.h','engine_core_smooth.c']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/name,'c317-review/'+name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(manifest);assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in manifest.items())
 proofs={n:json.loads((root(n)/'results.json').read_text()) for n in roots if (root(n)/'results.json').exists() and ('min-' in n or 'triage-' in n or 'unit-' in n)}
 timings={n:json.loads((root(n)/'results.json').read_text()) for n in ['direct-dot-replicas-r557','direct-dot-replicas-r562']};assert all(v['passed'] for v in timings.values())
 assert len(timings['direct-dot-replicas-r557']['records'])==30 and len(timings['direct-dot-replicas-r562']['records'])==15
 baseline=json.loads((root('local-dot-baseline-r510')/'sources.json').read_text());owners=['experimental/smooth/src/mj-solver_reductions.ads','experimental/smooth/src/mj-solver_reductions.adb'];assert all(sha(R/n)==baseline[n] for n in owners)
 dump(D/'summary.json',dict(runtime_adopted=False,active_owner_hashes={n:sha(R/n) for n in owners},proofs=proofs,numerical=json.loads((root('direct-dot-gates-r555')/'complete.json').read_text()),corpus=json.loads((root('direct-dot-corpus-r545')/'results.json').read_text()),assembly=json.loads((root('direct-dot-build-r544')/'actual-assembly.json').read_text()),normal_builder_bridge=json.loads((root('direct-dot-shared-build-r558')/'bridge.json').read_text()),baseline_rebuild=json.loads((root('direct-dot-shared-build-r558')/'baseline-rebuild-comparison.json').read_text()),timing=timings,scope='Closed 197-check direct-block minimum and 53-check ghost small-row minimum, with inherited diagnostics separate. Full direct unit hit 900-second watchdog, without completed report. Two-reference 13 numerical gates and bit-exact lane/count corpus pass. Thirty three-copy and fifteen six-copy integrated cases do not show multi-DOF benefit; runtime candidate remains private. Hinge gains and free-ball/chain uncertainty/regressions retained per workload. New fused compiler-boundary candidate inputs only are frozen; its active proof/build outputs are excluded. Full port, dynamics Gold and C parity remain unfinished.'))
 dump(D/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Compiler/prover caches obj/analysis, Python caches and .git. Active r566/r567 outputs excluded. Frozen candidate r565 inputs included. Prior baseline r510 and immutable movement fixtures are in the previous r525/r503 archives; external toolchains and C shared library identified by hashes, not embedded.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(manifest),zip_sha256=sha(Z),prior_inventory_entries=len(old['files']),active_runtime_owners_unchanged=True,scope='Storage/source checks distinct from scoped proof, compiler/numeric behavior and integrated timing.'))
 print('DIRECT CONTRACTS CHECKPOINT',Z.stat().st_size,len(manifest),flush=True)
if __name__=='__main__':main()
