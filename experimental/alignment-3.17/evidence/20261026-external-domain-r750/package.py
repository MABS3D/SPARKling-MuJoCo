from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261026-external-domain-r750';Z=D/'external-domain.zip';O=Path('/var/tmp/sparkling-adopt-external-domain-r749-20261026');G=Path('/var/tmp/sparkling-external-domain-gates-r748-20261026');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 accepted=json.loads((O/'complete.json').read_text());gate=json.loads((G/'complete.json').read_text());bindings=json.loads((O/'source-binding.json').read_text());assert accepted['passed'] and gate['passed'] and len(gate['gates'])==13;assert all(sha(R/n)==h for n,h in bindings['owners'].items());D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(Path('/var/tmp').iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 723<=int(m[1])<=749:roots.append(p)
 assert len(roots)>15;members={};exclude={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for folder in roots:
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not set(p.relative_to(folder).parts)&exclude:put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   m=re.search(r'-r(\d+)\.py$',p.name)
   if m and 723<=int(m[1])<=749:put(p,'recipes/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
 dump(D/'archive-manifest.json',dict(files=members,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),roots=[str(p) for p in roots],excluded='Generated compiler/prover/Python caches only. Frozen inputs, copied complete SPARK reports, logs, executables, raw measurements, failed bootstrap and proof attempts retained. External pinned reference libraries/toolchains identified by hashes rather than newly embedded.'))
 dump(D/'summary.json',dict(adoption=accepted,source_binding=bindings,numerical_gates=gate['gates'],proofs=gate['proofs'],timings=json.loads((O/'timing-summary.json').read_text()),scope='Equivalent original scalar input/output range constraints are explicit Pre/Post instead of automatic parameter/result subtype conversions. Exact ordered formula and caller numeric rejection/frame retained. Fresh actual source manifests equal verified full proof/build manifests on both C14/C17 closures. All13 numerical groups and6680 exact bit cases per profile pass. Nine targeted,three independent repeat and30 full scenarios qualify workload-specific gains; full port/dynamics Gold/migration/C parity remain open. No new commit/push.'))
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),runtime_owners_verified=True,both_actual_source_closures_match_verified_manifests=True))
 (D/'README.md').write_text('''# Adopted explicit scalar domains for external-force accumulation

The working Contribution function now uses base Real scalars with the original
previous-input Work_Real limit in Pre and original Contribution_Real output limit
in Post. The exact ordered two three-product reductions and two additions remain.
Declarations change; the currently used client is rebuilt and proved. This is not
a claim of arbitrary Ada generic-profile source compatibility. Admitted contract
inputs/outputs are retained, with no new assumptions, suppressions, trusted bodies,
forced inlining or deallocator change. Final Within_Work numeric rejection stays
in the unchanged caller. Six original products have proved Static local bounds.

Fresh complete external-math and direct-caller units independently close 58 and
42 checks on BOTH exact production C3.14 and candidate C3.17 closures, warning-free.
Fresh actual source manifests exactly equal all verified build/proof manifests.
All13 validation/release numerical groups pass: raw mass, derivatives, reverse
layout where applicable, compact cache, direct CRB and exact bit comparison.
The bit corpus has 6,680 cases per profile, including signed zero, subnormal,
cancellation, exponent and admitted-boundary values. Its oracle is native pinned
C3.17 mju_dot3 plus two ordered CPython binary64 additions, not an ideal-real
identity. A failed native-runtime bootstrap before any cases and its correction
are preserved; the matching GCC16 libstdc++ is set before interpreter startup.

The exact FP functional relation was already proved in the first trial; four
numeric-bound timeouts were closed with local product facts, without narrowing
Load/Previous. The first representation trial did not establish an integrated
benefit and was not adopted. The final explicit input/output range contract variant
removes twelve static floating comparison instructions from inlined acceleration
preparation (60 to48), with final caller rejection retained. Instruction counts
are diagnostic and do not substitute for timings.

The final nine-case targeted run, independent three-state chain24 repeat and all
30 supported scenarios use six identical executable replicas per role, balanced
orders, normalized argv0, shared fixtures, pinned normal native C3.17 SIMD/LTO and
matched FP flags. All numeric endpoints pass. All nine chain24 state/run estimates
show roughly1.4-2.1% less time, with each95% interval below one. Other workload
uncertainty remains explicit; no interval proves a slowdown, but many include no
change and some are broad. There is no unweighted aggregate or every-case speedup
claim. Full-run chain24 still takes about2.07-2.08 times C's time.

These workloads include nonzero external body wrenches. No benefit is claimed
for body-load-free operations where Contribution is not called. Full physics
coverage, whole dynamics Gold, coordinated production migration and overall C
parity remain unfinished. Production remains pinned to C3.14.

The early performance snapshot differs from the fresh proof/build closure only
in one unused Python test-provider file; all Ada/project inputs are identical.
The new complete two-reference proofs use the current provider bytes as well,
so actual working-source bindings are exact. Sources, proof scopes and all raw
samples are preserved, including unsuccessful precursor trials. Restore this ZIP
with tools/evidence_store.py restore using its repository-relative path. No new
commit or push is performed; the adoption and this evidence remain local.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==h for k,h in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
