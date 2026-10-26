from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-spatial-dot-adoption-r1172';Z=D/'spatial-dot-adoption.zip';A=V/'sparkling-adopt-spatial-dot-r1171-20261026';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 a=json.loads((A/'complete.json').read_text());assert a['passed'] and a['locally_adopted'];b=json.loads((A/'source-binding.json').read_text());assert all(sha(R/n)==v for n,v in b['owners'].items());g=json.loads((V/'sparkling-spatial-dot-numerical-gates-r1168-20261026/complete.json').read_text());assert g['passed'] and len(g['gates'])==13
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1146<=int(m[1])<=1171:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
   if m and 1146<=int(m[1])<=1171:put(p,'logs/'+p.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. Included jobs terminal. Frozen sources, all copied complete SPARK reports including unsuccessful budgets, raw controls, native-C metadata and binaries retained. External pinned toolchains/libraries identified by hashes. No unrelated project data or later work.'))
 dump(D/'summary.json',dict(adoption=a,actual_source_binding=b,numerical_gates=g,timings=json.loads((A/'timing-summary.json').read_text()),scope='Only Spatial_Kernels.Dot product constants change from constrained subtype to base Real with proved former product ranges as Static assertions. Exact original public Pre/Post, full admitted domains, six products and C mji_dot6 addition tree retained. All whole-unit proofs close independently on both references; inherited warnings preserved. Not full engine proof or C parity.'))
 (D/'README.md').write_text("""# Locally adopted proved static bounds for spatial Dot

The six Dot products now use base Real constants. Their former subtype limits
are retained as Static assertions, proved from the original complete input Pre.
Original API, Pre/Post, output bound, admitted domains and exact floating-point
addition tree are unchanged. The tree matches the actual C3.17 mji_dot6 source.
Contract-respecting calls retain the former intermediate bounds; invalid calls
outside Pre do not inherit a claim of identical old subtype-exception behavior.
No assumption, suppression, new inline directive or other private candidate is
included. Other spatial product helpers and reviewed deallocators are unchanged.

Both references independently close Dot39, Spatial_Kernels whole459, immediate
Projected9, Assemble_Row37 and Compact_Inertia whole377 semantic checks. Counts
are not additive. Spatial math is warning-free; the compact unit retains six
reviewed warnings on unchanged declarations/bodies. Initial low-resource Dot
return-bound and compact Assemble_Row postcondition timeouts are preserved.
More resources/per_path close them on the same sources. The whole compact runs
report success for all377 obligations, despite generic runner passed=false and
exit1 from its strict warning gate. obligations_closed=true, complete SPARK
coverage and no open obligations are verified explicitly; warnings are retained.

Both profiles/references pass the13 broader numerical groups: raw mass and
derivatives, C17 reverse-layout derivatives, compact cache, direct CRB and exact
Dot bits. Additional existing activation432 and integration1152 scenarios pass
per profile/reference.6720 scalar cases per role/profile match native C3.17
mju_dot(n=6), including signed zero, subnormal, extrema and cancellation inputs.
Test-only unchecked bit transport is outside production/proof trust. These tests
do not prove universal C equivalence or real-arithmetic error bounds.

Targeted9, independent chain3 and full30 supported movement scenarios use six
identical replicas per role, balanced orders, common fixtures, normal native
C3.17 SIMD/LTO and strict matched FP. All numeric endpoints pass. All nine
chain24 state/run estimates have95% intervals below1, with about1.4-2.2% less
time than actual893. Full-run chain24 still takes about1.90-1.91 times C's time.
Free_ball improves about3.1-3.9% in the full run, while targeted intervals include
no change; that result is not presented as independently replicated. No interval
proves a slowdown, but wide intervals on other models do not guarantee absence
of regressions. No unweighted aggregate speedup or overall C-parity claim follows.
Static compact-fill FP comparison sites fall50 to38; timing evidence is separate.

The single owner is locally adopted as1171 only after proof, numeric and timing
gates pass. Fresh actual C14/C17 source manifests exactly equal verified frozen
manifests. The previous893 solver implementation is retained. No commit or push
is performed. Complete port, full dynamics Gold, coordinated engine migration
and overall C performance parity remain unfinished. Restore spatial-dot-adoption.zip
through tools/evidence_store.py. Every failed budget and raw control is retained.
""")
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),actual_runtime_owner_verified=True,both_actual_source_closures_match_proven_inputs=True,whole_compact_obligations_closed_both_references=True,inherited_warnings_retained=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
