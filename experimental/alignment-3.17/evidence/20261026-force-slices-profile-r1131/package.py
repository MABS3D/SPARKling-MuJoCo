from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-force-slices-profile-r1131';Z=D/'force-slices-profile.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 q=json.loads((V/'sparkling-force-slice-qualification-r1123-20261026/results.json').read_text());assert q['passed']
 t=json.loads((V/'sparkling-force-slice-target-r1124-20261026/replicas/results.json').read_text());assert t['passed'] and t['replicas']==6 and len(t['records'])==9
 f=json.loads((V/'sparkling-profile-force-slices-r1126-20261026/results.json').read_text());assert f['passed']
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1098<=int(m[1])<=1126:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
   if m and 1098<=int(m[1])<=1126:put(p,'logs/'+p.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. Included roots terminal before packaging. Frozen sources, complete copied reports, failed attempts, raw numerical/timing/profile outputs, executables, native-C hashes and recipes retained. Later Jacobian candidate1127 and its jobs excluded.'))
 dump(D/'summary.json',dict(adopted=False,qualification=q,target_timing=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in t['records']],profile=f,scope='Private1109 scalar-contract and direct checked slice-view force loop. Full original scalar input domains expressed as equivalent Pre with original result bound proved in Post; identical ordered FP expression. Exact acceptance, first-failed prefix and untouched tail proved; 11 scalar,20 sequence and65 buffer semantic checks per reference, counts not additive. Whole inertia FLOW passes but Fill_Total minimum has three explicit open frame/configuration/readiness checks; its actual buffer call Pre is proved. Both references/profiles432 activation and1152 integration pass,6540 native-C exact scalar bits per role/profile pass. Target9 six-replica movement finds no demonstrated reproducible gain and one free_ball interval is just above1, unconfirmed by repeat. No full30 or independent repeat. Flat PC profile chain24 includes setup/output/signal costs and is descriptive, not acceptance timing or causal phase accounting. Actual runtime893 and complete-port/dynamics-Gold/migration/C-parity gaps unchanged.'))
 (D/'README.md').write_text("""# Private force slices and refreshed PC profile

Exact1109 sources close11 scalar,20 sequence-model and65 buffer semantic checks
on C3.17/C3.14. Counts concern separate scopes and are not additive. The scalar
function keeps the complete former input domains as explicit Pre and proves the
former return bound in Post. Contract-respecting calls preserve exact FP order;
invalid-outside-Pre runtime exception behavior is not claimed identical. Direct
checked slice views add no pointer cast, production helper, dispatch or new inline
policy. Exact acceptance, first-rejected prefix and untouched tail are proved.
Whole inertia FLOW closes on both references; it is not whole dynamics Gold.

The C3.17 Fill_Total minimum proves its actual buffer call Pre, but has three
other open obligations: the state-image frame, configuration-equality lemma Pre
and Solver_Ready_Properties Pre. No baseline proof comparator was run, so this
checkpoint does not establish that those gaps are unchanged from baseline.
Both references and standard profiles pass432 activation and1152 integration
scenarios. Native C3.17 scalar bit controls pass6540 cases per role/profile.

Targeted nine-case six-replica movement uses actual893, private1109 and normal
native C3.17 with matched strict FP flags and separate numeric endpoints. It
finds no demonstrated reproducible integrated gain. Chain24 intervals include
no change; one free_ball interval barely exceeds1 and has no independent repeat.
All intervals and raw samples are retained. No full30, aggregate speedup or
C-parity claim follows; the candidate remains unadopted.

The refreshed chain24/state0 flat-PC profile has valid timer metadata and10000
checked numeric sample endpoints per role. PC samples include setup/output and
signal overhead; fractions are descriptive, not exact phase times or integrated
acceptance timings. Solve_Acceleration includes external-load projection as well
as force preparation and dispatch. Its hot addresses must be mapped to actual
instructions before attributing cost. Earlier1098 postcondition failures and
successful controls retain separate source bindings. Later Jacobian work1127
is excluded. Runtime remains893; full port, migration, dynamics Gold and overall
C parity remain unfinished. Restore force-slices-profile.zip via the exact store.
""")
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),no_runtime_adoption=True,three_caller_opens_retained=True,no_integrated_gain_claim=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
