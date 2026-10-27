from pathlib import Path
import argparse,hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('--kind',choices=['history','adoption'],required=True);a=p.parse_args();history=a.kind=='history'
 low,high=(1193,1251) if history else (1252,1294)
 name='20261027-inertia-projection-controls-r1295' if history else '20261027-compact-rne-adoption-r1296'
 D=E/name;Z=D/('inertia-projection-controls.zip' if history else 'compact-rne-adoption.zip');D.mkdir();shutil.copy2(__file__,D/'package.py')
 roots=[]
 for x in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-2026102[67]$',x.name)
  if x.is_dir() and x.name.startswith('sparkling-') and m and low<=int(m[1])<=high:roots.append(x)
 heavy={'gnatprove','gnat2why','gnatwhy3','why3server','gprbuild','gnat1','gcc','cc1','lto1','lto-wrapper','cvc5','z3','alt-ergo'}
 for d in Path('/proc').iterdir():
  if not d.name.isdigit():continue
  try:
   comm=(d/'comm').read_text().strip();cmd=(d/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
   assert not (comm in heavy and any(str(root) in cmd for root in roots)),(d.name,comm)
   assert not ('benchmark_replicas.py' in cmd and comm.startswith('python')),(d.name,cmd)
  except (OSError,PermissionError):pass
 if history:
  summary=dict(adopted=False,scope='Private1193-1251 controls preceding final adoption1294. Includes public-profile-preserving helper variants, separately proved equality bridges, direct compact kernels, caller projection proof attempts, complete minima and all observed failures/timeouts. Whole1237 Direct attempts1246/1247 retain one postcondition open each; whole compact1249/1250 have no terminal unit report after host interruption. Gates1251 completed only eight groups. These are not passing full-unit/gate results. The later1252/1274 final proof and numerical closures are excluded here and recorded in the adoption checkpoint. Two initial1211 nine-case runs use different pre-final binaries; they are diagnosis, not final-source acceptance. Counts concern separate sources/scopes and are not additive.')
  readme='''# Private inertia helpers and projection proof controls

This checkpoint preserves1193-1251 source variants and their exact runners,
reports, binaries, numeric outputs and measurements. Typed public parent math
profiles remain intact in the1193/1200 helper variants. Independently proved
scalar equality bridges close the1200 whole math unit, but targeted movement
still shows hinge regressions, so it is not adopted.

The1211 Direct child preserves all original parent specifications and bodies,
changing only the existing compact row multiplication. Its initial whole Direct
proof closes on both references with separate source bindings; the real caller
postcondition initially remains open. Both nine-case runs, including wide and
barely-parity intervals, remain diagnostic and concern that earlier binary.

Caller attempts preserve the failed operator-visibility build1226, two open
assertions1228, Dot equality1232, four FP overflow obligations1234 and two product
equalities1236. Staged ghost products1237 close projection69, row substitution33
and Assemble_Row59 minima on C17; these are not a whole dynamics proof. The
unused1218 expected-result minimum and1239 equal-product lemma are retained.

Fresh final-source1237 whole Direct attempts1246/1247 each leave a postcondition
open. Whole compact1249/1250 and broader gates1251 were interrupted by the host:
there is no complete unit report in either compact run and only eight numeric
groups in1251. Partial Why3 sessions are included explicitly as partial reports,
never whole-unit completion. Later1252/1274 closures belong to the adoption
checkpoint. All source domains and failed budgets remain visible; no solver
timeout is described as a mathematical exception. Raw ZIP restoration is exact
through tools/evidence_store.py. Full port, migration, dynamics Gold and C parity
remain open.
'''
 else:
  adopt=V/'sparkling-adopt-compact-rne-r1294-20261027/results.json';d=json.loads(adopt.read_text());assert d['passed'] and d['locally_adopted'];q1=V/'sparkling-inertia-bridge-qualification-r1266-20261027/results.json';q2=V/'sparkling-rne-congruence-qualification-r1288-20261027/results.json';assert json.loads(q1.read_text())['passed'] and json.loads(q2.read_text())['passed']
  summary=dict(adoption=d,compact_qualification=json.loads(q1.read_text()),rne_qualification=json.loads(q2.read_text()),scope='Four actual runtime owners adopted locally after complete scoped proof/numeric/performance gates. Whole Direct122 and Compact501 close per reference on1252; whole RNE163 closes per reference on final1274. Explicit unchanged eight-/eighteen-source transitive dependency bridges carry earlier Direct/Compact proofs into the unrelated RNE-body delta; full project manifests differ and are not called identical for that reuse. Fresh actual C14/C17 snapshots match final1274 completely, including normalized manifest entry ordering after verifying every content digest. Six inherited compact warnings retained; no assumption, suppression, domain narrowing, new threshold or new inline policy. Both13-group qualifications, activation432/integration1152 per reference/profile and exact native bit controls6864 inertia/6794 RNE pass. All four timing runs retained separately, with no average of percentages and no universal no-regression, whole-engine/port/migration or overall C-parity claim.')
  readme='''# Locally adopted Direct inertia products in compact mass and RNE

Four runtime owners are adopted: the new Direct child specification/body,
the compact mass caller and the RNE body. The original parent math API and
implementations stay intact. Direct uses base Real scalar terms with former
bounds proved as Static facts and the exact parent Multiply as its functional
model. RNE uses it for both products in C3.17 mj_rne order. Original full domains,
acceptance/rejection checks, fallback zeros, small-model mass route and existing
Nv<3 selection remain. No new threshold, forced inline, assumption or suppression.

Both references close minimum Multiply35, whole Direct122 and whole Compact501;
C14 Assemble_Row59 also closes. The C17 caller minima on earlier byte-identical
compact inputs are recorded separately. Final RNE closes Try_Body_Force30 and
whole RNE163 per reference. Independently proved ghost congruence minima15/78/16
explain the FP equality composition. Counts are not additive. Six inherited
compact warnings match original diagnostic rules, columns and source statements.
An initial900s whole compact budget expires; the terminal attempt is preserved.
Incremental continuation on identical source validates prior Why3 tasks and
produces the complete501-check report. No partial report counts as completion.

RNE changes only its own body relative to the qualified compact snapshot.
Conservative context-clause/implicit-parent closures verify that all eight Direct
and eighteen Compact MJ source inputs are unchanged, for each reference. Those
proofs are reused with explicit dependency bindings, not a false claim of equal
full-project manifests. Fresh actual C14/C17 source snapshots match final1274 in
full after checking all file digests; only manifest entry ordering is normalized.
These scopes do not close whole dynamics/state/memory/constructor proofs.

Both complete13-group numeric qualifications and all standard activation432 and
integration1152 corpora pass for C3.14/C3.17 and validation/release. Native C exact
bits pass6864 inertia-vector and6794 RNE-body cases per role/profile, including
both original rejection branches. RNE's rejection wrapper in the C test is a
test-only Ada-policy comparator; C itself does not implement that rejection.
Test-only bit transport stays outside production/proof trust. The first C harness
misses an internal header and fails; its corrected attempt is retained separately.
No universal C-bit equivalence or ideal-real accuracy bound follows from cases.

Four six-replica timing runs use normal native C3.17 SIMD/LTO and matched strict
FP. Compact-only target9 finds no demonstrated reproducible gain. RNE target9
improves chain24 about0.9-2.0%, all three intervals below1. The final combined
full30 and independent target9 compare the same final binary directly with actual
1171. All numeric endpoints pass and Ada endpoints are bit-identical across roles.
The full run has chain medians1.4-1.9% lower but intervals including1. The independent
repeat has chain2.5-2.8% and free_ball3.2-3.6% lower, each interval below1. Full-run
free_ball gains2.6-3.2%, with one interval barely including1; hinge improves only in
the full run, while repeat intervals are wide. Other models retain wide intervals.
No confirmed slowdown in these runs guarantees none, and no percentage average
is used. Median chain time is still1.85-1.88 times native C, free_ball1.53-1.56,
while hinge is about2.2-3.3% slower than C. Overall C parity remains unfinished.

Actual binaries, frozen sources, full SPARK reports, partial Why3 sessions,
failed controls, provider hashes and all raw samples are archived. Restore the
original ZIP through tools/evidence_store.py. No commit or push is performed by
this adoption. The complete MuJoCo port, latest-engine migration and full dynamics
Gold remain open.
'''
 members={};special=[]
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  excluded={'obj','analysis','__pycache__','.git'}
  for root in roots:
   for folder,dirs,files in os.walk(root):
    dirs[:]=sorted(n for n in dirs if n not in excluded)
    for filename in sorted(files):
     f=Path(folder)/filename;put(f,root.name+'/'+f.relative_to(root).as_posix())
   for pattern in ['why3session.xml','*.spark']:
    for f in sorted(root.rglob(pattern)):
     if set(f.relative_to(root).parts)&excluded:
      arc='generated-reports/'+root.name+'/'+f.relative_to(root).as_posix();put(f,arc);special.append(arc)
  for f in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',f.name)
   if m and low<=int(m[1])<=high:put(f,'logs/'+f.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],generated_proof_reports_preserved=special,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated obj/analysis caches excluded except all available SPARK and Why3 session reports copied into generated-reports. Exact frozen sources, source manifests, runners, binaries and numeric/raw timing results retained. Included processes verified terminal; host-interrupted1249/1250 and partial1251 remain explicitly incomplete.'))
 dump(D/'summary.json',summary);(D/'README.md').write_text(readme);dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),all_available_spark_and_why3_session_reports_retained=True,actual_adoption_verified=not history,partial_results_not_completion=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for f in D.iterdir():
  if f.is_file():inv['files'][f.relative_to(E).as_posix()]=sha(f)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(kind=a.kind,zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
