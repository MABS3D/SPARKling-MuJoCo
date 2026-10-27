from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-row-input-bound-adoption-r1321';Z=D/'row-input-bound-adoption.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
a=V/'sparkling-adopt-row-input-r1319-20261027/results.json';adopt=json.loads(a.read_text());assert adopt['passed'] and adopt['locally_adopted'];bridge=V/'sparkling-adopt-row-input-r1319-20261027/unchanged-math-proof-dependencies.json';assert json.loads(bridge.read_text())['passed'];q=V/'sparkling-row-input-qualification-r1313-20261027/results.json';qualification=json.loads(q.read_text());assert qualification['passed'];D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1299<=int(m[1])<=1319:roots.append(p)
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  comm=(p/'comm').read_text().strip();cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
  assert not (any(str(r) in cmd for r in roots) and comm in {'gnatprove','gnatwhy3','gprbuild','gcc','cc1','lto1','cvc5','z3','alt-ergo'}),(p.name,comm)
  assert not ('benchmark_replicas.py' in cmd and comm.startswith('python')),(p.name,cmd)
 except (OSError,PermissionError):pass
members={};reports=[]
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):
     n='generated-reports/'+root.name+'/'+p.relative_to(root).as_posix();put(p,n);reports.append(n)
 for p in sorted(V.glob('sparkling-*.log')):
  m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
  if m and 1299<=int(m[1])<=1319:put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],generated_proof_reports_preserved=reports,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All included jobs terminal. Generated obj/analysis caches excluded except available complete SPARK and Why3 reports; all frozen source, runners, binaries, numeric data and raw timings retained.'))
dump(D/'summary.json',dict(adoption=adopt,qualification=qualification,unchanged_math_proof_dependencies=json.loads(bridge.read_text()),scope='Single-owner runtime Add_Row arithmetic preserves original full domains and exact ordered functional/rejection/frame model. Both-reference minimum37/whole231/caller-minimum86 close, with4/12 inherited warnings matching diagnostic categories and source statements. Fourteen numerical groups, both-reference/profile activation/integration,66306 row cases per profile and7374 native row-bit cases per role/profile pass. All nine chain state/run intervals across target9/repeat9/full30 are below1. Full30 ball regression is preserved despite non-reproduction in independent ball/spatial_ball followup6; no no-regression or aggregate percentage claim. Actual fresh C14/C17 source manifests match qualified inputs. Prior Direct/Compact/RNE proof reuse has explicit unchanged dependency closures. Complete inertia phase/global factorization functional proof, whole dynamics Gold, full port/migration and C parity remain open.'))
(D/'README.md').write_text('''# Locally adopted proved Add_Row input-bound elision

The sole runtime owner is Solver_Kernels.adb. Add_Row replaces the checked
Add_Product runtime call with the identical Previous + Operand * Multiplier
expression on base Real values. Former operand/result bounds and exact equality
to the unchanged typed Add_Product model are proved Static facts. All public
specifications, admitted/null/nonzero-origin domains, full-row rejection, source
preservation and existing integer reduction/compiler workaround remain. No new
threshold, forced inline, pointer cast, assumption or suppression is introduced.

Both references close Add_Row37, whole kernel231 and actual solver CALLER
MINIMUM86. C17 Add_Prefix_Row14 also closes. Counts are not additive. Four kernel
and twelve caller warnings match prior diagnostics and identical source statements.
Generic runners report passed=false solely from their strict warning gate; complete
coverage, no open obligations and obligations_closed are reviewed explicitly.
The caller scope preserves safety/bounds and the clamp diagnostic; it does not
prove global factorization equations or close the entire inertia phase.

Both-reference/profile activation432 and integration1152 suites and all14 numerical
groups pass. The unchanged checked/release row corpus covers66306 cases per profile,
including every rejected SIMD/tail lane and maximum coefficients. New baseline/
candidate native-C comparisons cover7374 cases per role/profile: all output bits,
original rejection predicate and unchanged source bits must match, with null and
near-max/nonzero origins, signed zero, subnormal, cancellation and extreme inputs.
Test-only bit transport is outside production/proof trust. Normal strict release
flags and the existing per-file solver256 preference are retained; client inlining
uses ordinary native width as in production. Cases are not universal C equivalence.

Target9, independent repeat9 and full30 use six identical executable replicas per
role, balanced orders and normal native C3.17 SIMD/LTO. All numeric endpoints pass.
All nine chain24 state/run intervals are below1: targeted/repeat gains1.6-1.8%, full
run1.3-1.5%. Full-run ball medians are1.6-1.8% slower, with intervals above1. An
additional independent ball/spatial_ball followup6 has ball medians near unchanged
and intervals including1. The original regression is retained, not erased or
proved impossible. Other model uncertainties remain; no unweighted percentage
average or universal absence-of-regressions claim follows. Full-run chain time is
still1.82 times C; ball is1.24-1.26 times C in the full/dedicated measurements.

The actual owner is adopted only after these gates. Fresh actual C14/C17 sources
match qualified1299 contents completely; manifest ordering is normalized only
after every digest is checked. All eight Direct, eighteen Compact and twelve RNE
transitive source inputs remain identical to actual1294, with explicit bindings
for prior122/501/163 proofs. Full project manifests differ across the unrelated
solver-body delta and are not called identical for that reuse. Whole dynamics
Gold, full port/latest-engine migration and global C parity remain unfinished.
No commit or push is performed. Restore row-input-bound-adoption.zip through
tools/evidence_store.py.
''');dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),actual_adoption_and_source_bindings_verified=True,all_nine_chain_intervals_below_one=True,full_ball_regression_and_independent_followup_both_retained=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
