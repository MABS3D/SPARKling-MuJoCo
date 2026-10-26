from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence'
D=E/'20261026-row-window-r790';Z=D/'row-window.zip'
O=Path('/var/tmp/sparkling-adopt-row-window-r789-20261026')
G=Path('/var/tmp/sparkling-row-window-gate-repair-r787-20261026')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 accepted=json.loads((O/'complete.json').read_text());gate=json.loads((G/'complete.json').read_text());bindings=json.loads((O/'source-binding.json').read_text())
 assert accepted['passed'] and gate['passed'] and len(gate['gates'])==14
 assert all(sha(R/n)==h for n,h in bindings['owners'].items())
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 def in_range(name):
  m=re.search(r'-r(\d+)(?:-20261026)?(?:\.[^.]+)?$',name)
  return bool(m and 751<=int(m[1])<=789)
 for p in sorted(Path('/var/tmp').iterdir()):
  if p.is_dir() and p.name.startswith('sparkling-') and in_range(p.name):roots.append(p)
 assert len(roots)>30
 members={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for folder in roots:
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not set(p.relative_to(folder).parts)&excluded:put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   if in_range(p.name):put(p,'recipes/'+p.name)
  for p in sorted(Path('/var/tmp').glob('sparkling-*.log')):
   if in_range(p.name):put(p,'loose-logs/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
 dump(D/'archive-manifest.json',dict(files=members,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),roots=[str(p) for p in roots],excluded='Generated compiler/prover/Python caches only. Frozen source, copied complete SPARK reports, logs, binaries, bit/row corpora, raw timings, failed precursor flow attempts and original failed warning-count gate retained. External pinned reference/toolchains identified by hashes.'))
 dump(D/'summary.json',dict(adoption=accepted,source_binding=bindings,numerical_gates=gate['gates'],proofs=gate['proofs'],inherited_warning_delta=gate['inherited_warning_delta'],codegen=json.loads(Path('/var/tmp/sparkling-row-window-codegen-r788-20261026/results.json').read_text()),timings=json.loads((O/'timing-summary.json').read_text()),scope='Checked ordinary single-array sliding and complete equivalent scalar coefficient domain chain. Whole kernel222 and direct solver caller MINIMUM86 per reference, not full inertia-phase or global factorization model. Four kernel and twelve caller inherited warnings retained; obsolete five-warning metadata in earlier receipts is corrected here. All14 numerical groups,6140 scalar bits and59621 rows per profile pass; replicated target9/repeat3/full30 support chain24-specific gains, not full C parity. Local adoption only.'))
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),runtime_owners_verified=True,both_actual_source_closures_match_verified_manifests=True))
 (D/'README.md').write_text('''# Checked row windows and explicit coefficient domains

The working packed-row update now passes a single checked constrained array
formal with origin zero. Ordinary Ada parameter sliding avoids widened vector
index arithmetic; there are no pointers, unchecked conversions, copies,
suppressed checks or assumptions. Original generic origins/counts, ordered
floating expression, complete rejection predicate and untouched frame remain.
Scale input/output and row coefficients use base Real with their original
admitted ranges as explicit proved Pre/Post. The local solver coefficient also
uses Real so an automatic constraint check is not merely moved to that local.
The inverse subtype, pivot behavior, deallocators and backend threshold remain.

Proof diagnosis starts with scalar and nested helper minima, then the wrapper,
whole kernel and solver caller. Fresh exact C3.14 and C3.17 closures each close
all222 whole-kernel checks and86 checks of Solve_Compatible_Buffers. The latter
is a subprogram minimum, not a complete inertia-phase proof or a global L'DL
functional theorem. Four inherited kernel and twelve inherited caller warnings
remain separate from closed obligations; strict warning-free passed is false.
The previous kernel had five warnings. Replacing its source-index expression
removes one reassociation warning; the four retained warnings match exact new
lines. The original fresh gate rejected the successful222-check reports because
it expected five warnings. That failed driver and completed reports are retained;
the correction validates the exact diagnostic delta and completes caller proofs.
Earlier private timing qualification text saying five warnings is obsolete.

All14 numerical groups pass on the supported reference closures. Both checked
and release profiles pass6140 exact native C scalar-multiplication bit cases and
59621 exact row/frame/rejection cases, including high origins,65535/65536 and
numeric limits. The initial input-only Scale trial did not establish a gain;
the complete scalar chain showed only partial confirmation. Neither precursor
was independently adopted. Failed flow attempts and their ghost correction
are preserved without narrowing the runtime domain.

Three six-copy integrated comparisons use the latest adopted external-load
baseline, normal native C3.17 SIMD/LTO and matching floating flags: nine targeted
scenarios, an independent three-state chain24 repeat, and all30 supported
movement scenarios. Every numeric endpoint passes. All nine chain24 state/run
estimates take about1.7-2.6% less time, each95% interval below one. Full-run
chain24 takes about2.4-2.6% less time and remains2.01-2.04 times C's time.
Other workload intervals often include no change; no slowdown is confirmed.
There is no unweighted aggregate, every-case gain or C-parity claim. Fixtures
include applied body loads; a separate no-body-load timing claim is not made.

The actual final timed binaries retain YMM multiplication/addition and remove
four vector-index widening sites in Add_Long_Row. All call sites in this helper
are ordinary language-check handlers; no data-copy/allocation call appears.
The new diagnostic instruction count excludes objdump byte continuation lines;
older precursor counts included those lines. Counts do not establish speedup.
Pinned C mj_factorI and its AVX row update use the same packed row operation.

Fresh actual working manifests exactly match the verified C3.14/C3.17 sources.
Full port, whole dynamics Gold, coordinated production migration and overall
C parity remain unfinished. Production is still pinned to3.14. This adoption
remains local, with no new commit/push. Restore row-window.zip with
tools/evidence_store.py restore using its repository-relative path.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
