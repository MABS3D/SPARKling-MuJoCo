from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-force-windows-and-init-r1102';Z=D/'force-windows-and-init.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 q=json.loads((V/'sparkling-force-sequence-qualification-r1096-20261026/results.json').read_text());assert q['passed'];a=json.loads((V/'sparkling-initialization-review-r1069-20261026/results.json').read_text());assert a['initialization_scope_passed'] and not a['whole_minimum_passed'];p=V/'sparkling-force-sequence-target-r1097-20261026/replicas/results.json';t=json.loads(p.read_text());assert t['passed'] and t['replicas']==6 and len(t['records'])==9
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1061<=int(m[1])<=1097:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
   if m and 1061<=int(m[1])<=1097:put(p,'logs/'+p.name)
  recovery=V/'sparkling-proof-recovery-r1060-20261026'
  for p in sorted(recovery.rglob('*')):
   if not p.is_file() or 'partial-reports' in p.parts or set(p.relative_to(recovery).parts)&excluded:continue
   put(p,'recovery-recipes/'+p.relative_to(recovery).as_posix())
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. All included roots terminal before packaging. Exact frozen sources, complete copied SPARK reports, failed budgets/compile/filter attempts, raw numerical/movement outputs, executables, native-C metadata and recipes retained. Later1098 slice/scalar prototype and active1099/1100 jobs excluded.'))
 dump(D/'summary.json',dict(adopted=False,initialization_review=a,force_qualification=q,target_timing=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in t['records']],scope='Both references prove the five Arms initialization properties on1049, with three explicit whole-topology obligations still open. The new constrained-force candidate1076 closes model28/window74/wrapper22/buffer41 per reference, counts not additive, plus both-profile432+1152 numerical controls. Exact ordered scalar formula, all former outer/null domains, original scalar checks and first-rejection prefix/untouched-tail relation retained. No new forced inline, assumption or suppression. The target9 six-replica native-C comparison does not establish a reproducible multi-DOF gain and the initial hinge cases show about3.8-4.1% slowdown. It stays unadopted; no full30 or independent repeat is claimed. Other1070/1072/1084 proof-model variants are explicitly separate; pure prefix lemma31 closes on1084 but is not the measured candidate. Initial1065 cannot compile because the original forced-inline wrapper contains a nested helper; moving that production helper to a separate ordinary procedure fixes compilation without adding an inline directive. Tiny filter pilot succeeds while the real multi-line/subprogram combination1063 is rejected; no proof claim is based on the pilot. Runtime remains893/e956729c3; complete port, migration, whole dynamics Gold and overall C parity remain unfinished.'))
 (D/'README.md').write_text('''# Verified force-window experiment and scoped initialization closure

On exact1049 sources, completed actual Build_Manifold_Topology minima prove five
initialization properties on C3.17/C3.14: prefix invariant initialization and
preservation, final whole-array initialization, and initialization at both actual
consuming calls. The whole minimum still has three open obligations: configuration
buffer indices at964/972 and subtree-mass precondition at967. The separate review
retains those failures and all warnings; FLOW is not promoted to whole-unit Gold.

The measured1076 force candidate closes28 sequence-model,74 constrained-window,
22 immediate-wrapper and41 existing-buffer checks per reference. Counts concern
separate minima and are not additive. The sequence is componentwise equal to the
original ordered scalar expression; the loop proves exact success iff every
value fits, exact prefix written and untouched suffix on first rejection.
Original scalar subtype checks and all admitted outer/null domains remain. No
new forced-inline policy, cast, assumption, suppression or model filter is added.
Existing432 activation and1152 integration scenarios pass for both roles/profiles
on C3.17/C3.14. These checks do not prove complete Fill_Total, inertia phase,
Data, dynamics or universal C equivalence. Data constructor gaps remain separate.

The targeted9 six-replica supported movement comparison uses normal native
C3.17 SIMD/LTO, matched strict FP flags, balanced orders, shared fixtures and
replica-then-block confidence intervals. It finds no demonstrated reproducible
multi-DOF gain; initial hinge medians increase roughly3.8-4.1%. Every raw interval
is retained. There is no full30, independent-repeat, aggregate speedup or C-parity
claim. The candidate remains private and unadopted.

Initial1065 compilation fails because the old forced-inline wrapper contains a
nested production helper. The separate ordinary helper1067 fixes compilation
without adding an inline directive. All intermediate stronger-contract failures,
resource-only retries and an unused pure-prefix lemma31 on1084 remain separately
bound to their sources. A tiny filter pilot succeeds, but the real filter mix1063
is rejected before proof; that failed attempt supplies no verified result.

Runtime remains893, published as e956729c3. New slice/scalar prototype1098 and
its active jobs are outside this checkpoint. Restore force-windows-and-init.zip
through tools/evidence_store.py. Full port, coordinated migration, complete
dynamics Gold and overall C parity remain unfinished.
''')
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),no_runtime_adoption=True,full_force_minima_and_target_controls_preserved=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),roots=len(roots),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
