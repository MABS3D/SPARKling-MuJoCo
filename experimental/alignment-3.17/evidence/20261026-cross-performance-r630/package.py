from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261026-cross-performance-r630';Z=D/'cross-performance.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 first=Path('/var/tmp/sparkling-cross-revisit-run-r623-20261025');full=Path('/var/tmp/sparkling-cross-revisit-full-r628-20261025');a=json.loads((first/'replicas/results.json').read_text());b=json.loads((full/'replicas/results.json').read_text());assert a['passed'] and len(a['records'])==9 and b['passed'] and len(b['records'])==30
 assert all(r['current_over_baseline']['ci95'][1]<1 for r in a['records']) and all(r['current_over_baseline']['ci95'][1]<1 for r in b['records'])
 base=Path('/var/tmp/sparkling-row-threshold-r606-20261025');h=json.loads((base/'sources.json').read_text());math='experimental/smooth/src/mj-smooth_math.adb';assert sha(R/math)==h[math]
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files']);assert len(prior)==180
 D.mkdir();shutil.copy2(__file__,D/'package.py');members={};excluded={'obj','analysis','__pycache__','.git'}
 roots=[first,Path('/var/tmp/sparkling-cross-revisit-full-r624-20261025'),Path('/var/tmp/sparkling-own-cache-cleanup-r626-20261025'),Path('/var/tmp/sparkling-backed-cache-cleanup-r627-20261025'),full,Path('/var/tmp/sparkling-exact-zip-duplicates-r629-20261026')]
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;v=p.read_bytes();members[n]=hashlib.sha256(v).hexdigest();i=zipfile.ZipInfo.from_file(p,n);i.compress_type=zipfile.ZIP_DEFLATED;z.writestr(i,v,compresslevel=6)
  for folder in roots:
   assert folder.is_dir()
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for n in ['sparkling-cross-revisit-run-r623.py','sparkling-cross-revisit-full-r624.py','sparkling-cross-revisit-gates-r625.py','sparkling-own-cache-cleanup-r626.py','sparkling-backed-cache-cleanup-r627.py','sparkling-cross-revisit-full-r628.py','sparkling-exact-zip-duplicates-r629.py']:put(Path('/tmp')/n,'recipes/'+n)
  for n in ['engine_core_util.c','engine_support.c','engine_inline.h']:put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/n,'c317-review/'+n)
  put(Path('/var/tmp/sparkling-cross-revisit-build-r622-20261025/build.json'),'inputs/build.json');put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(members) and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 def rows(d):return [{k:v for k,v in r.items() if k not in ['timings_seconds_per_step','statistics','same_code_replica_ratios']} for r in d['records']]
 dump(D/'summary.json',dict(adopted=False,original_targeted=rows(a),full=rows(b),reference='3.17.0',replicas=6,unchanged_public_math_sha256=sha(R/math),scope='Private Cross static-product-bounds candidate on the adopted threshold8 baseline. All9 targeted and all30 full-run CIs show lower total movement time, with workload-specific estimates retained; no unweighted model average. Both runs check exact Ada endpoints and C oracle tolerance. Normal native C SIMD/LTO reference, matched GCC16.1, no unsafe FP flags. Known own heavy tasks idle during accepted measurements. Earlier r624 full run interrupted at low host space and is not a complete acceptance result. Broader two-reference numerical integration and C14 math proof currently running separately in r625; no runtime adoption or full port/parity claim.'))
 dump(D/'archive-manifest.json',dict(files=members,count=len(members),zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Generated caches. Frozen source, full C17 proof and bit corpus are in the exact r620 bundle; original movement fixtures in r503. Native C library/toolchains identified by pinned hashes, not embedded. Active r625 outputs excluded; only its immutable runner retained.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(members),zip_sha256=sha(Z),source_still_private=True,prior_inventory_entries=180))
 (D/'README.md').write_text('''# Cross: reproduced integrated gain, adoption still pending

A private body-only candidate replaces six intermediate product subtype checks
with proved Static bounds. The same six rounded products, three subtractions,
public domain and complete functional postcondition remain. C evaluates the
same ordered expressions without these intermediate checks. No assumption,
suppression, new trusted production body or narrower input domain is introduced.
The compiler inlines Cross; no standalone symbol does not mean no executed work.

The minimum closes 86 checks and the whole C3.17 math unit closes 796, retaining
10/66 existing diagnostics separately. Both profiles pass 5,972 exact IEEE-bit
C cases, including signed zeros, subnormals, exponent boundaries and cancellation.
Those frozen inputs/reports are in the preceding r620 checkpoint.

The first six-copy run covers nine movement scenarios from free_ball, chain24
and branches24. All intervals are below parity with the current published
arithmetic baseline plus locally adopted threshold8. The complete six-copy run
then covers all30 supported scenarios; all endpoints pass, and all intervals
are below parity in that run. Each run uses 36 balanced blocks,8samples,
32warmups,100steps,CPU12, normalized argv0 and shared fixtures. Bootstrap samples
replicas then paired blocks. C is normal source-built3.17 AVX/LTO with the same
GCC16.1 toolchain, FP contraction off. Its shared-library placement is not varied
independently across C launcher copies. No own heavy jobs overlap accepted timing.
Individual estimates and raw data remain; there is no unweighted model average
or arbitrary slower-than-C allowance. Small-case uncertainty differed in the
interrupted attempt, which remains explicitly incomplete rather than discarded.

On the complete run, chain24 current/baseline ratios are about0.9191,0.9130,0.9191;
branches24 about0.9467,0.9542,0.9517. The first targeted run confirms both gains.
Chain24 still needs about2.09-2.10times C and branches24 about1.59times C.
This is useful progress, not overall C parity or complete MuJoCo coverage.

The first full run r624 was explicitly interrupted when C: reached about65MiB
free, before cache deletion or other heavy recovery work. All partial records
and its interruption reason are retained. After cleanup the exact same binary
hashes were used for the full r628 run. Known-heavy-process preflights are retained.
Only backed generated caches and losslessly stored, ignored raw ZIP duplicates
were removed; all source, proof receipts, binaries, logs and exact store bytes remain.
Tracked historical archives are untouched; WSL was not stopped or compacted.

The candidate remains private. Two-reference validation/release numerical
integration and the complete C3.14 math proof are live in r625, whose changing
outputs are deliberately excluded here. The immutable runner is retained.
The actual working Cross remains unchanged pending these gates. Whole dynamics
Gold, full engine migration and overall C performance parity are still unfinished.

Restore cross-performance.zip through tools/evidence_store.py before extraction.
Original fixtures and full proof/source inputs are exact-store dependencies in
r503/r620. This checkpoint remains local; no GitHub push is performed.
''')
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);inv['cross_performance_r630_prior_entries_preserved']=True;dump(E/'inventory.json',inv)
 print('CROSS PERFORMANCE CHECKPOINT READY',Z.stat().st_size,len(members),inv['count'],flush=True)
if __name__=='__main__':main()
