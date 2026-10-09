from pathlib import Path
import hashlib,json,zipfile
TMP=Path('/var/tmp'); repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
out=TMP/'sparkling-hessian-reuse-publish-r122-20261009';out.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
items={}
def add(p,n):
 assert n not in items,n
 items[n]=p
roots={
 'release315':TMP/'sparkling-alignment-315-reuse-release-r122-20261009',
 'release314':TMP/'sparkling-alignment-314-reuse-release-r122-20261009',
 'solver-validation':TMP/'sparkling-alignment-315-reuse-solver-r122-20261009'}
source_check={}
for label,root in roots.items():
 m=json.loads((root/'manifest.json').read_text())
 assert all(sha(root/'source'/name)==value for name,value in m['sources'].items())
 matches={name:sha(repo/name)==value for name,value in m.get('original_sources',{}).items()}
 assert all(matches.values()),[name for name,ok in matches.items() if not ok]
 source_check[label]={'manifest_sha256':sha(root/'manifest.json'),'frozen_sources_match':True,'original_sources_match_checkout':matches}
 for p in sorted(root.rglob('*')):
  if not p.is_file():continue
  rel=p.relative_to(root)
  if any(part in ('build','force-build','state-build','__pycache__','obj','gnatprove','.git') for part in rel.parts):continue
  add(p,label+'/'+rel.as_posix())
 for pattern in ['force-build/release/bin/*','state-build/release/bin/*','build/validation/bin/*']:
  for p in root.glob(pattern):
   if p.is_file():add(p,label+'/binaries/'+p.name)
for name in ['sparkling-verify-reuse-r122-20261009.py','sparkling-verify-reuse-r122-20261009.json']:
 add(TMP/name,'orchestration/'+name)
for p in sorted(TMP.glob('sparkling-reuse-r122-*.log')):add(p,'orchestration/'+p.name)
add(TMP/'sparkling-fold-oracle-r121-20261009/synthetic_fold_oracle.py','oracle/synthetic_fold_oracle.py')
for rel in ['experimental/alignment-3.15/tests/build_flex.py','tools/guarded.py']:
 add(repo/rel,'runners/'+rel)
(out/'source-check.json').write_text(json.dumps(source_check,indent=2)+'\n');add(out/'source-check.json','source-check.json')
archive=out/'runtime.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for name,p in sorted(items.items()):z.write(p,name)
files={name:sha(p) for name,p in sorted(items.items())}
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 assert set(z.namelist())==set(files)
 for name,value in files.items():assert hashlib.sha256(z.read(name)).hexdigest()==value,name
meta={'archive':archive.name,'sha256':sha(archive),'bytes':archive.stat().st_size,'all_members_verified':True,'files':files,'scope':'Frozen runtime/source evidence with build objects and caches excluded; includes numerical probes, not performance measurements.'}
(out/'runtime-manifest.json').write_text(json.dumps(meta,indent=2)+'\n')
print(json.dumps({k:v for k,v in meta.items() if k!='files'}));print('members',len(files))
