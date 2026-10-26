from pathlib import Path
import hashlib,json,os,shutil
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';O=Path('/var/tmp/sparkling-own-cache-cleanup-r626-20261025');O.mkdir();shutil.copy2(__file__,O/'runner.py')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
m=json.loads((E/'storage/manifest.json').read_text());z=E/'20261025-row-threshold-r620/row-threshold.zip';rel=z.relative_to(R).as_posix();entry=m['archives'][rel];assert z.is_file() and not z.is_symlink() and sha(z)==entry['sha256'] and z.stat().st_size==entry['bytes'];assert sha(E/'storage'/entry['recipe'])==entry['recipe_sha256']
# Full exact store verification completed successfully immediately before this
# run (27 archives /168 inventory files); source bytes are independently bound.
removed=dict(path=str(z),bytes=z.stat().st_size,sha256=entry['sha256'],store_manifest_sha256=sha(E/'storage/manifest.json'),reason='Redundant ignored raw ZIP only; exact compressed bytes remain in the fully verified lossless store and can be restored without recompression.')
z.unlink();dump(O/'raw-zip-removal.json',removed)
roots=['row-threshold-r606','row-threshold-min-r607','row-threshold-unit-r608','row-threshold-corpus-r609','row-threshold-build-r610','row-threshold-gates-r614','cross-revisit-r616','cross-revisit-min-r617','adopt-threshold-r618','cross-revisit-unit-r619','cross-revisit-bits-r621','cross-revisit-build-r622']
cache=[]
for name in roots:
 root=Path('/var/tmp')/('sparkling-'+name+'-20261025');assert root.is_dir()
 for folder,dirs,files in os.walk(root,followlinks=False):
  if Path(folder).name!='obj':continue
  p=Path(folder);assert not p.is_symlink();dirs[:]=[]
  paths=[q for q in p.rglob('*') if q.is_file() and not q.is_symlink()]
  # Object roots must hold generated compiler/prover products, never a source
  # tree. All accepted proof reports/logs were copied outside obj before packing.
  assert any(q.suffix in ['.o','.ali','.spark','.why'] or 'gnatprove' in q.parts for q in paths),p
  cache.append(dict(path=str(p),bytes=sum(q.stat().st_size for q in paths),files=len(paths)))
assert len(cache)==len({q['path'] for q in cache});dump(O/'cache-audit.json',dict(eligible=cache,total_bytes=sum(q['bytes'] for q in cache),scope='Only obj compiler/prover caches in own completed r606-r622 experiments, whose sources, binaries and copied proof receipts are already in the exact verified r620 store. No other project, older workdir, toolchain, source, binary, raw output or existing evidence store is deleted. No VHDX compaction or physical host-byte recovery is claimed from cache deletion.'))
for item in cache:shutil.rmtree(item['path'])
dump(O/'complete.json',dict(passed=True,raw_zip_bytes_removed=removed['bytes'],cache_bytes_removed=sum(q['bytes'] for q in cache),cache_directories=len(cache),cached_inputs_and_receipts_retained=True,restoration='python3 tools/evidence_store.py restore '+rel,scope='Raw Windows ZIP removal frees its host file allocation; Linux generated-cache removal makes existing VHDX filesystem blocks reusable. WSL not stopped; VHDX not compacted.'))
print('OWN COMPLETED CACHES REMOVED',len(cache),sum(q['bytes'] for q in cache),'RAW WINDOWS ZIP',removed['bytes'],flush=True)
