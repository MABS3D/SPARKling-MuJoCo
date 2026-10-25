from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261025-reduction-closure-r605';Z=D/'reduction-closure.zip'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def root(n):return Path('/var/tmp')/('sparkling-'+n+'-20261025')
def main():
 actual=root('adopt-ghost-r602');assert json.loads((actual/'complete.json').read_text())['passed'];assert json.loads((actual/'endpoint-check/results.json').read_text())['passed'];assembly=json.loads((actual/'movement/instruction-comparison.json').read_text());assert assembly['all_changed_are_exception_source_line_arguments'];inv=json.loads((E/'inventory.json').read_text());assert len(inv['files'])==149
 proofs={}
 for n in ['ghost-unit-r595','ghost314-unit-r597']:
  p=root(n)/'results.json';d=json.loads(p.read_text());assert d['obligations_closed'] and d['checks']==837 and not d['open'];proofs[n]=d
 owners=['experimental/smooth/src/mj-solver_reductions.ads','experimental/smooth/src/mj-solver_reductions.adb'];h=json.loads((root('ghost-reductions-r592')/'sources.json').read_text());assert all(sha(R/n)==h[n] for n in owners)
 names=['direct-dot-unit-r566','direct-dot-build-r567','fused-dot-corpus-r568','direct-dot-r569','model-tail-min-r570','lane-model-min-r571','tail-model-min-r572','forward-min-r573','direct-dot-r574','empty-row-min-r575','forward-min-r576','forward-paths-r577','ghost-reductions-r578','ghost-forward-min-r579','ghost-forward-effort-r580','ghost-unit-r581','ghost-reductions-corpus-r582','ghost-runtime-build-r583','ghost-reductions-r584','tail-model-min-r585','unfold-tail-min-r586','unfold-tail-paths-r587','two-terms-min-r588','ghost-unit-r589','ghost314-r590','ghost314-unit-r591','ghost-reductions-r592','dot-four-min-r593','ghost-unit-r595','ghost314-r596','ghost314-unit-r597','pc-sampler-r600','profile-r601','adopt-ghost-r602']
 D.mkdir();shutil.copy2(__file__,D/'package.py');manifest={};exclude={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;b=p.read_bytes();manifest[n]=hashlib.sha256(b).hexdigest();info=zipfile.ZipInfo.from_file(p,n);info.compress_type=zipfile.ZIP_DEFLATED;z.writestr(info,b,compresslevel=6)
  for n in names:
   folder=root(n);assert folder.is_dir(),folder
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in exclude for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  # Invalid gprofng experiments may contain environment dumps: retain only
  # explicitly selected non-sensitive command/output/qualification files.
  for n in ['sampling-profile-r594','sampling-profile-r598','sampling-profile-r599']:
   folder=root(n)
   for p in sorted(folder.iterdir()):
    if p.is_file() and (p.suffix in ['.json','.py','.stdout','.stderr','.txt']):put(p,folder.name+'/'+p.name)
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   if any('r'+str(i) in p.name for i in range(566,605)):put(p,'recipes/'+p.name)
  for n in ['engine_core_smooth.c','engine_forward.c','engine_util_sparse_avx.h','engine_util_blas_avx.h']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/n,'c317-review/'+n)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(manifest);assert all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in manifest.items())
 profile={role:json.loads((root('profile-r601')/(role+'.summary.json')).read_text()) for role in ['baseline','c']};assert all(v['collection_valid'] for v in profile.values())
 dump(D/'summary.json',dict(adopted='ghost-only reduction proof/model refactoring',runtime_optimizations_adopted=False,owners={n:sha(R/n) for n in owners},whole_proofs=proofs,actual_adoption=json.loads((actual/'complete.json').read_text()),actual_source_binding=json.loads((actual/'source-binding.json').read_text()),assembly=assembly,sections=json.loads((actual/'movement/section-comparison.json').read_text()),actual_endpoints=json.loads((actual/'endpoint-check/results.json').read_text()),calibration=json.loads((root('pc-sampler-r600')/'calibration.summary.json').read_text()),profiles=profile,invalid_profiles=['gprofng 2.42 timer reset at 1ms and 10ms: unusable','bundled 2.46.1 collector shared library absent: no data'],scope='837 closed whole-unit checks under each exact production 3.14/candidate 3.17 dependency closure, warnings separate. Original runtime arithmetic/domain/dispatch and all prior postconditions retained, tail bound strengthened. Four exact-bit reduction corpora and all 30 actual movement endpoints pass. Only eight exception source-line immediates differ in full program instructions; data/rodata unchanged. Native PC samples rank solver/preparation/compact mass above dot on chain24 state0; profiler is a calibrated test tool and not a trusted production/proof body or timing acceptance result. Whole dynamics Gold, full port and C parity remain pending.'))
 dump(D/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Compiler/prover caches, Python caches, .git; failed gprofng .er trees excluded to avoid environment dumps. Raw custom PC records/maps/timer metadata and all successful frozen sources, proof reports, binaries and numeric results retained. External toolchains/C shared library identified by hashes, not embedded. Earlier r556/r503 archives hold prior inputs/fixtures.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(manifest),zip_sha256=sha(Z),actual_owner_hashes_verified=True,whole_scope_checks_per_reference=837,prior_inventory_entries=149,scope='Archive/source integrity separate from formal, numerical and sampled performance claims.'))
 print('REDUCTION CLOSURE ARCHIVE READY',Z.stat().st_size,len(manifest),flush=True)
if __name__=='__main__':main()
