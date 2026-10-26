from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-inertia-component-controls-r1210';Z=D/'inertia-component-controls.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 q=json.loads((V/'sparkling-inertia-component-qualification-r1185-20261026/results.json').read_text());q2=json.loads((V/'sparkling-inertia-separate-qualification-r1191-20261026/results.json').read_text());assert q['passed'] and q2['passed'];timings={}
 for name in ['sparkling-inertia-component-target-r1186-20261026','sparkling-inertia-separate-target-r1192-20261026']:
  t=json.loads((V/name/'replicas/results.json').read_text());assert t['passed'] and t['replicas']==6 and len(t['records'])==9;timings[name]=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in t['records']]
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1173<=int(m[1])<=1192:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
   if m and 1173<=int(m[1])<=1192:put(p,'logs/'+p.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated caches only. Included jobs terminal; all complete SPARK reports, exact sources, bit/numeric/movement outputs and binaries retained. Later1193 private-profile-preserving helper work and active1207 proof excluded. Native C/toolchains identified by pinned hashes.'))
 dump(D/'summary.json',dict(adopted=False,component_qualification=q,separate_fill_qualification=q2,timings=timings,scope='Original full scalar domains moved from Angular/Linear parameter/result subtypes into explicit equivalent Pre/Post. All term/pair/triple/output bounds proved statically. Exact FP formulas retained. C17/C14 complete math388, angular46/linear19/multiply24 and C17 real Assemble_Row37 close.6864 native C bit cases per role/profile and both-profile/reference activation432/integration1152 pass. Initial9 movement improves free_ball/chain but has hinge regressions; no adoption. Separate ordinary No_Inline(Fill) retains formulas and passes C17 Fill51 plus numeric suites; math reuse is explicitly bridged, not mislabeled identical full-manifest proofs. Its9 movement gains are retained but hinge medians remain above baseline with wide intervals. No independent repeat/full30 or causal no-inlining attribution. Public generic subtype-profile compatibility is not asserted for1173. Root runtime remains adopted1171.'))
 (D/'README.md').write_text("""# Private component-contract and separate-Fill controls

The1173 candidate expresses the complete former Angular/Linear scalar input and
result subtype bounds as equivalent explicit Pre/Post, using base Real values.
All former term, pair, triple and wrapper result bounds become proved Static
assertions. Exact C mju_mulInertVec FP order and public Multiply contract remain.
No assumption, suppression or new forced-inline directive is added. Invalid calls
outside Pre and arbitrary generic subtype-profile compatibility are not claimed
identical; later work1193 preserves the public specification and is excluded here.

Both references close complete math388, Angular46, Linear19 and Multiply24 checks;
C17 Assemble_Row37 also closes. Counts are not additive. Both profiles/references
pass activation432/integration1152 suites and6864 native C exact bit cases per
role/profile. Initial targeted9 six-replica supported movement with normal native
C3.17 improves free_ball about2.8-4.2% and chain24 about2.4-2.5%, but hinge medians
increase about2.7-2.9%, with each initial interval above1. The candidate is private.
No broad raw-mass/derivative gate, full compact-unit proof, repeat or full30 is
claimed for this candidate.

An ordinary No_Inline(Fill) control1187 adds exactly that directive to1173, changing
no executable statement, formula or contract. C17 Fill51 closes with two inherited
recursive-model warnings; exact-source numeric suites pass both profiles. Earlier
math/bit proofs concern identical math inputs with one unrelated directive delta,
explicitly recorded as a source bridge rather than equal full manifests. Its9-case
run improves free_ball about3.9-4.7% and chain24 about2.9-3.0%. Hinge medians remain
about2.2-3.3% above baseline, with wide intervals including1. No absent regression,
causal inlining mechanism, adoption, repeat or full30 claim follows.

The initial static count reported zero Fill compares because the separate symbol
was absent, not because every check was removed. This incomplete diagnostic is
preserved separately. The corrected report marks missing symbols as null and
records parent symbols; Fill-only before/after counts are not comparable after
compiler inlining changes. Performance claims use raw integrated timings only.
Root runtime remains1171. Complete port, dynamics Gold, migration and overall
C parity remain unfinished. Restore inertia-component-controls.zip via the exact
store. All unsuccessful diagnoses and raw controls are retained.
""")
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),no_runtime_adoption=True,mixed_performance_retained=True,corrected_symbol_diagnostic_retained=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
