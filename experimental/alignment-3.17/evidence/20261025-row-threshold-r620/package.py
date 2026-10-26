from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261025-row-threshold-r620';Z=D/'row-threshold.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def root(n):return Path('/var/tmp')/('sparkling-'+n+'-20261025')
def main():
 adoption=json.loads((root('adopt-threshold-r618')/'complete.json').read_text());assert adoption['passed'];owner='experimental/smooth/src/mj-solver_kernels.adb';expected=json.loads((root('row-threshold-r606')/'sources.json').read_text());assert sha(R/owner)==expected[owner]
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files']);assert len(prior)==159
 D.mkdir();shutil.copy2(__file__,D/'package.py');manifest={};excluded={'obj','analysis','__pycache__','.git'}
 names=['row-threshold-r606','row-threshold-min-r607','row-threshold-unit-r608','row-threshold-corpus-r609','row-threshold-build-r610','row-threshold-replicas-r611','row-threshold-replicas-r612','row-threshold-repeat-r613','row-threshold-gates-r614','row-threshold-asm-r615','adopt-threshold-r618','cross-revisit-r616','cross-revisit-min-r617','cross-revisit-unit-r619','cross-revisit-bits-r621','cross-revisit-build-r622']
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;nbytes=p.read_bytes();manifest[n]=hashlib.sha256(nbytes).hexdigest();info=zipfile.ZipInfo.from_file(p,n);info.compress_type=zipfile.ZIP_DEFLATED;z.writestr(info,nbytes,compresslevel=6)
  for name in names:
   folder=root(name);assert folder.is_dir(),folder
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for n in ['engine_core_smooth.c','engine_util_blas_avx.h','engine_core_util.c','engine_support.c']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/n,'c317-review/'+n)
  for name in ['row-threshold-r606','row-threshold-gates-r614','adopt-threshold-r618','cross-revisit-r616','cross-revisit-bits-r621','cross-revisit-build-r622']:
   p=Path('/tmp')/('sparkling-'+name+'.py');put(p,'recipes/'+p.name)
  put(Path('/tmp/sparkling-row-threshold-gates-resume-r614.py'),'recipes/sparkling-row-threshold-gates-resume-r614.py')
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(manifest);assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in manifest.items())
 cross_unit=json.loads((root('cross-revisit-unit-r619')/'results.json').read_text());cross_min=json.loads((root('cross-revisit-min-r617')/'results.json').read_text());cross_bits=json.loads((root('cross-revisit-bits-r621')/'results.json').read_text());assert cross_unit['obligations_closed'] and cross_min['obligations_closed'] and cross_bits['passed'] and cross_bits['complete']
 dump(D/'cross-private.json',dict(minimum=cross_min,whole_unit=cross_unit,boundary=cross_bits,assembly=json.loads((root('cross-revisit-build-r622')/'cross-assembly.json').read_text()),adopted=False,integrated_performance_pending=True,scope='Re-evaluation of prior private Cross candidate under latest threshold8/reduction-closure baseline. Both proof scopes close with existing diagnostics; all5972C-bit cases/profile pass. Compiler inlines Cross, so absent standalone body does not mean absent work. No runtime adoption or speedup claim before replicated integrated measurements.'))
 full=json.loads((root('row-threshold-replicas-r612')/'results.json').read_text());repeat=json.loads((root('row-threshold-repeat-r613')/'results.json').read_text())
 summary=dict(adoption=adoption,source_binding=json.loads((root('adopt-threshold-r618')/'source-binding.json').read_text()),assembly=json.loads((root('row-threshold-asm-r615')/'results.json').read_text()),full=[{k:v for k,v in r.items() if k not in ['timings_seconds_per_step','statistics','same_code_replica_ratios']} for r in full['records']],repeat=[{k:v for k,v in r.items() if k not in ['timings_seconds_per_step','statistics','same_code_replica_ratios']} for r in repeat['records']],disqualified_run=json.loads((root('row-threshold-replicas-r611')/'qualification.json').read_text()),scope='Locally adopted threshold8 versus prior16. Both reference closures have156 closed unit checks with5 existing diagnostics each;13 numerical groups plus exact14905-case disjoint corpus/profile pass. Two six-copy integrated comparisons confirm chain24 gains of roughly1.2-1.8%, with individual intervals retained, not full C parity. Original30-case run and three-case independent creation-seed repeat retained. No own heavy compiler/prover/archive/hash work overlapped accepted timings. Initial run interrupted and disqualified because own earlier Git status was still live. Public contracts, FP expressions and evaluation order unchanged; ELF text differs only in threshold compare immediate 15 to 7, data/rodata identical. Full port and overall performance parity remain unfinished.')
 dump(D/'summary.json',summary);dump(D/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Compiler/prover caches, Python caches and .git. Sources, copied SPARK reports, numerical corpora, binaries and raw timing records retained. Native C shared library and external toolchain hashes identify external inputs; prior r503 bundle holds original movement fixtures.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(manifest),zip_sha256=sha(Z),actual_owner_hash_verified=True,prior_inventory_entries=len(prior)))
 (D/'README.md').write_text('''# Earlier SIMD dispatch for disjoint factor rows

The actual solver now selects its existing vector row backend at eight elements,
previously sixteen. The reviewed C3.17 mju_addToScl AVX implementation starts at
four. Arithmetic, ordered FP expressions, domains, rejection flags, unaffected
entries and all public contracts remain unchanged. No assumption, suppression,
new trusted production body or deallocator change is introduced.

The minimum closes 40 checks; the full kernel unit independently closes 156 checks
on each exact C3.14/C3.17 dependency closure. Five inherited reassociation warnings
per unit remain explicit; strict warning-free passed is false, while obligations
are closed. Both 14,905-case disjoint-row corpora pass, as do all 13 broader numerical
groups covering validation/release, raw mass, derivatives, reverse layouts, compact
cache and direct CRB. Adopted source manifests match the verified builds exactly.

The full 30-case movement experiment and independent chain24 repeat use six
byte-identical copies per role, 36 balanced blocks, 8 samples, 32 warmups, 100 steps,
CPU 12, normalized argv0 and shared fixtures. Ada outputs match exactly; C outputs
meet the recorded tolerance. C is the normal source-built 3.17 SIMD/LTO reference,
FP contraction off, compiled with the same GCC 16.1 toolchain. Its shared-library
placement is not varied independently across launcher copies. No own heavy jobs
overlap accepted measurements. The initial r611 run was interrupted and explicitly
disqualified because an earlier own Linux Git status process was still scanning.
Its qualification, incomplete outputs and failure record remain available.

Across chain24 states the first median time ratios are 0.98766, 0.98331, 0.98463;
the repeat gives 0.98281, 0.98701, 0.98173. Each 95% interval lies below 1. Other first-run
workload intervals include 1; individual regressions/uncertainty remain in the
summary and raw evidence. These are workload-specific measurements, with no
unweighted aggregate or arbitrary noise allowance. Chain24 still takes about
2.3 times normal C, so overall parity and full MuJoCo completion remain pending.

ELF .text differs in exactly one byte, the dispatch immediate 15 to 7; instruction
addresses/sizes and read-only/writable data match. This is compiler evidence,
separate from formal proofs and timing. The 837-check reduction proof checkpoint
retains its original scope under unchanged called contracts; it was not rerun here.

A further private Cross candidate replaces six intermediate subtype checks by
proved Static bounds. Its minimum closes 86 checks; the whole math unit closes
796, retaining 10/66 existing diagnostics respectively. Both profiles pass 5,972
exact-bit C cases. The normal movement builder is ready, but integrated timing
and broader integration gates remain pending. Cross is inlined in the candidate;
its absent standalone symbol does not imply that its work disappeared. Sources,
reports and executables are preserved separately in cross-private.json and the
archive. The actual working math body remains unchanged.

Restore row-threshold.zip through tools/evidence_store.py before extraction.
Exact frozen sources, proof reports, commands, binaries, numerical outputs and
raw performance samples are retained; generated caches are excluded. The C3.14 proof launcher initially lacked the helper-module Python path and
exited before proof startup. Its original log and the environment correction
are retained; completed numerical groups were verified unchanged and not rerun.
The change is local and no new GitHub push is performed by this checkpoint.
''')
 for p in sorted(D.iterdir()):
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);inv['row_threshold_r620_prior_entries_preserved']=True;dump(E/'inventory.json',inv)
 print('THRESHOLD CHECKPOINT READY',Z.stat().st_size,len(manifest),len(inv['files']),flush=True)
if __name__=='__main__':main()
