from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261025-direct-dot-r525';Z=D/'direct-dot.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 D.mkdir();shutil.copy2(__file__,D/'package.py');old=json.loads((E/'inventory.json').read_text());assert len(old['files'])==135;names=['local-dot-baseline-r510','local-dot-r511','local-dot-min-r512','local-dot-min-r513','local-dot-build-r514','direct-dot-r515','direct-dot-min-r516','direct-dot-r518','empty-block-min-r519','direct-dot-min-r520','direct-dot-build-r521','reduction-corpus-r522','direct-dot-r523'];roots=[Path('/var/tmp')/('sparkling-'+n+'-20261025') for n in names];manifest={};exclude={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;b=p.read_bytes();manifest[n]=hashlib.sha256(b).hexdigest();z.writestr(n,b)
  for root in roots:
   assert root.is_dir(),root
   for p in sorted(root.rglob('*')):
    if p.is_file() and not any(part in exclude for part in p.relative_to(root).parts):put(p,root.name+'/'+p.relative_to(root).as_posix())
  for n in ['engine_util_sparse.h','engine_util_sparse_avx.h','engine_core_smooth.c']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/n,'c317-review/'+n)
  put(R/'experimental/dynamics-derivatives-candidate/tests/check_solver_reductions.py','final-corpus/check_solver_reductions.py');put(R/'experimental/dynamics-derivatives-candidate/tests/reductions_probe.adb','final-corpus/reductions_probe.adb');put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(manifest);assert all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in manifest.items())
 results={}
 for name in ['local-dot-min-r512','local-dot-min-r513','direct-dot-min-r516','empty-block-min-r519','direct-dot-min-r520']:
  p=Path('/var/tmp')/('sparkling-'+name+'-20261025/results.json');results[name]=json.loads(p.read_text())
 corpus={n:json.loads((roots[11]/n/'results.json').read_text()) for n in ['baseline','direct']};assert all(x['passed'] for x in corpus.values());assert results['local-dot-min-r513']['obligations_closed'] and results['empty-block-min-r519']['obligations_closed'];assert results['direct-dot-min-r516']['exit']==results['direct-dot-min-r520']['exit']==99
 dump(D/'summary.json',dict(adopted=False,proof_results=results,corpus=corpus,local_codegen=json.loads((roots[4]/'results.json').read_text()),instruction_comparison=json.loads((roots[4]/'instruction-comparison.json').read_text()),direct_codegen=json.loads((roots[10]/'results.json').read_text()),direct_caller=json.loads((roots[10]/'caller-assembly.json').read_text()),direct_blocks=json.loads((roots[10]/'blocks-assembly.json').read_text()),scope='Local publication-only candidate closes 173 checks but does not change successful-path machine instructions. Direct-arithmetic candidate produces YMM blocks and passes extended tests, but full changed-loop proof remains unfinished; no new runtime adoption, timing or C-parity claim. Runtime count domains/order/contracts unchanged. Only tested corpus providers retained in working files. Existing accepted r503 Scale_Row stays unchanged.'))
 dump(D/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Compiler/prover caches and all mutable active r524 job outputs excluded. Completed copied SPARK reports and logs retained; active job uses immutable r523 source captured here. External toolchains/C shared library not embedded.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(manifest),zip_sha256=sha(Z),all_prior_inventory_entries=135,scope='Archive/source verification separate from unfinished direct-loop proof and unmeasured runtime performance.'))
 print('DIRECT DOT CHECKPOINT READY',Z.stat().st_size,len(manifest),flush=True)
if __name__=='__main__':main()
