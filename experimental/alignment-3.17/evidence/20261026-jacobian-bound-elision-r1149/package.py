from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-jacobian-bound-elision-r1149';Z=D/'jacobian-bound-elision.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 q=json.loads((V/'sparkling-jacobian-guaranteed-qualification-r1141-20261026/qualification-full.json').read_text());assert q['passed'] and set(q['whole_jacobians'])=={'317','314'}
 timings={}
 for name,count in [('sparkling-jacobian-guaranteed-target-r1142-20261026',9),('sparkling-jacobian-guaranteed-repeat-r1145-20261026',3)]:
  t=json.loads((V/name/'replicas/results.json').read_text());assert t['passed'] and t['replicas']==6 and len(t['records'])==count;timings[name]=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in t['records']]
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1127<=int(m[1])<=1145:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
   if m and 1127<=int(m[1])<=1145:put(p,'logs/'+p.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. All included roots terminal. Frozen sources, copied complete reports, failed initial test-private-descendant compile and low-resource whole proof, raw test/timing outputs and binaries retained. Later spatial Dot1146 and its active minima excluded.'))
 dump(D/'summary.json',dict(adopted=False,qualification=q,timings=timings,scope='Original Jacobian Column full Pre/Post and admitted domains retained. Angular bound follows from original direction Pre; slide linear bound follows likewise. Computed hinge linear bound remains checked. Original exact Column15, whole Jacobians115 and whole external-load caller42 close independently per reference; counts not additive. Two unchanged-spec integer reassociation warnings retained. Whole Jacobian Build bounds/world-prefix Post does not prove full topology-to-matrix functional refinement.6576 exact native-C boundary cases per role/profile pass;432 activation and1152 supported integration scenarios per profile/reference pass. Target9 and independent chain3 with six replicas do not demonstrate a reproducible integrated improvement. No full30 or C-parity claim; candidate remains private. Root runtime remains893.'))
 (D/'README.md').write_text("""# Proved Jacobian bound-check elimination, not adopted

The original Column precondition limits Direction to1.00001. Angular is therefore
bounded in both branches, and Linear is bounded in the slide branch. The candidate
removes only those implied executable checks; the hinge cross-product result is
still checked. Original Pre/Post, all admitted inputs, exact output formulas and
Ok semantics are unchanged. No assumption, suppression, FP reordering or new
inline directive is added. This is a single-owner change from actual893.

Both references close Column15, whole Jacobians115 and whole External_Loads42
semantic checks independently; counts are not additive. Whole-unit low-resource
proof initially times out on an integer-index assertion. The Build67 minimum
and both whole-unit retries close with more resources/per_path, on identical
source. Two integer operator-reassociation warnings on declarations byte-identical
to baseline remain explicit and unsuppressed. Whole Jacobian Build still specifies
bounds/world-prefix preservation; complete topology-to-matrix refinement remains
pending and no whole dynamics Gold is claimed.

Both reference/profile activation432 and integration1152 suites pass; unchanged
baseline receipts are reused under exact source/provider hashes.6576 boundary
cases per role/profile match native C3.17 sub3/cross output bits and original
acceptance, including signed zeros, subnormals, cancellation and admitted extrema.
The initial test harness fails to compile because its child needs a private
specification; that failed attempt remains separate. Test-only bit conversions
are outside production and proof trust.

Static inlined acceleration floating-compare sites fall48 to36, which is not
performance evidence. Targeted nine-case movement and an independent chain24
three-state repeat use six replicas and normal native C3.17 with strict matched
FP. One initial chain interval is below1; the other initial chain intervals and
all repeat chain intervals include1. Initial chain medians are about0.25-0.65%
lower; repeat medians about0.07-0.33% lower. This does not establish a reproducible
integrated gain, so no adoption or full30 run follows. All raw timings and
intervals remain. Root runtime893, complete port/migration/dynamics Gold and
overall C parity remain unfinished. Restore jacobian-bound-elision.zip through
the exact store. Subsequent spatial Dot work1146 is excluded.
""")
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),no_runtime_adoption=True,both_reference_whole_unit_scopes_closed=True,failed_attempts_retained=True,no_integrated_gain_claim=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
