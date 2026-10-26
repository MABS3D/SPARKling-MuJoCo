from pathlib import Path
import ast,hashlib,json,os,shutil
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';O=Path('/var/tmp/sparkling-backed-cache-cleanup-r627-20261025');O.mkdir();shutil.copy2(__file__,O/'runner.py');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
m=json.loads((E/'storage/manifest.json').read_text());raw=[]
for folder,name in [('20261025-direct-dot-contracts-r556','direct-dot-contracts.zip'),('20261025-reduction-closure-r605','reduction-closure.zip')]:
 p=E/folder/name;rel=p.relative_to(R).as_posix();v=m['archives'][rel];assert p.is_file() and not p.is_symlink() and p.stat().st_size==v['bytes'] and sha(p)==v['sha256'];raw.append(dict(path=str(p),bytes=v['bytes'],sha256=v['sha256'],exact_stored_archive=rel))
source=E/'20261025-reduction-closure-r605/package.py';tree=ast.parse(source.read_text());assigns=[n for n in ast.walk(tree) if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='names' for t in n.targets)];assert len(assigns)==1;names=ast.literal_eval(assigns[0].value);assert len(names)>25
archive=json.loads((E/'20261025-reduction-closure-r605/archive-manifest.json').read_text());members=archive['files'];caches=[]
for name in names:
 root=Path('/var/tmp')/('sparkling-'+name+'-20261025');assert root.is_dir() and any(k.startswith(root.name+'/') for k in members)
 for folder,dirs,files in os.walk(root,followlinks=False):
  if Path(folder).name!='obj':continue
  p=Path(folder);assert not p.is_symlink();dirs[:]=[];items=[x for x in p.rglob('*') if x.is_file() and not x.is_symlink()]
  if not items:continue
  assert any(q.suffix in ['.o','.ali','.spark','.why'] or 'gnatprove' in q.parts for q in items),p
  caches.append(dict(path=str(p),bytes=sum(q.stat().st_size for q in items),files=len(items)))
dump(O/'audit.json',dict(store_manifest_sha256=sha(E/'storage/manifest.json'),raw_zip_duplicates=raw,caches=caches,cache_bytes=sum(x['bytes'] for x in caches),scope='Only obj caches in completed source/proof/build roots explicitly included by the fully verified r605 archive. Preserve all frozen source, copied SPARK receipts, logs, binaries, inputs and raw measurements. Exact stored ZIP bytes remain restorable. No other project, toolchain, active job, old unmatched directory or storage payload is removed.'))
for p in raw:Path(p['path']).unlink()
for c in caches:shutil.rmtree(c['path'])
dump(O/'complete.json',dict(passed=True,raw_zip_bytes_removed=sum(v['bytes'] for v in raw),cache_bytes_removed=sum(v['bytes'] for v in caches),cache_directories=len(caches),vhdx_compacted=False,scope='Redundant Windows ZIP file allocations released; Linux VHDX blocks from generated caches reusable without claiming equal Windows physical-byte recovery. All original archive bytes remain losslessly reconstructable from the verified store.'))
print('BACKED CACHES',len(caches),sum(v['bytes'] for v in caches),'RAW WINDOWS ZIP BYTES',sum(v['bytes'] for v in raw),flush=True)
