from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-constructor-followup-r908';Z=D/'constructor-followup.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 P=V/'sparkling-data-span-identity-caller-r905-20261026';d=json.loads((P/'results.json').read_text());s=json.loads((P/'unit.spark.json').read_text());semantic=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in s.get(k,[]));assert d['source_hashes_unchanged'] and d['coverage'] and not d['obligations_closed'];roots=[P,V/'sparkling-data-span-lengths-r906-20261026'];D.mkdir();shutil.copy2(__file__,D/'package.py');members={};exclude={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&exclude:
     n=root.name+'/'+p.relative_to(root).as_posix();data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  data=Path(__file__).read_bytes();members['recipes/package.py']=hashlib.sha256(data).hexdigest();z.writestr('recipes/package.py',data)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only; terminal report, frozen sources and logs retained.'))
 dump(D/'summary.json',dict(private=True,adopted=False,semantic_closed=semantic,legacy_info_counter=d['checks'],open=len(d['open']),open_locations=[dict(line=x['line'],rule=x['rule']) for x in d['open']],warnings=len(d['warnings']),full_result=d,prepared_source='sparkling-data-span-lengths-r906-20261026',scope='Copy_Manifold_Joints minimum only. Frame invariant initialization and preservation close after the proved identity lemma. Other entry/post/range checks remain open.906 only changes length comparisons to Int64 to avoid implicit Natural range checks; it is prepared, unproved, unqualified and unadopted. No complete Initialize/Data/dynamics Gold or new runtime adoption claim.'))
 (D/'README.md').write_text('''# Private constructor follow-up

This follows the row-domain894 checkpoint. The905 constructor minimum completes
with the preserved report in summary.json. The body-frame invariant now closes
both initialization and preservation, using the previously proved two-field
setter, transitivity and array reflexivity helpers. Remaining obligations are
explicit; neither the constructor nor the whole parent Data unit is verified.
Semantic proof/flow counts exclude compiler informational loop-unrolling notes.

The906 source compares component lengths in Int64, preserving the full original
array/model domain while avoiding an implicit Natural conversion in pre/post
expressions. It is prepared only: a fresh minimum and caller chain remain to be
proved, followed by current-source C3.14/C3.17 validation/release numerical gates.
These private constructors are not part of the adopted runtime. No new public
filter, runtime scan, assumption, suppression or deallocator change is introduced.
All included jobs are terminal. Generated analysis caches are excluded; frozen
inputs, copied complete reports, logs and exact raw result counters are retained.
No commit or push is performed. Full port, whole dynamics Gold and C parity remain
unfinished. Restore constructor-followup.zip with tools/evidence_store.py restore.
''')
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),scope='Archive integrity and scope metadata only; not constructor proof closure.'))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),semantic_closed=semantic,open=len(d['open']),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
