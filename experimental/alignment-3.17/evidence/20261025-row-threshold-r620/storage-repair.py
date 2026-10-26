from pathlib import Path
import gzip,hashlib,json,os,shutil,subprocess,sys
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261025-row-threshold-r620';S=E/'storage';I=E/'inventory.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
sys.path.insert(0,str(R/'tools'));import evidence_store
m,old=evidence_store.load(S);assert m['totals']['archives']==26
index=S/'objects-2c0f3cd28ab729299d881f98728790f07329d8b97ddcee601afc85a1d74e62e3.json.gz';assert sha(index)==index.name[8:-8]
objects=json.loads(gzip.decompress(index.read_bytes()));assert len(objects)>len(old) and all(objects.get(k)==v for k,v in old.items())
z=D/'row-threshold.zip';zsha=sha(z);a=json.loads((D/'archive-manifest.json').read_text());assert zsha==a['zip_sha256'];recipe=S/('archive-'+zsha+'.json.gz');parts=json.loads(gzip.decompress(recipe.read_bytes()));assert all(k in objects for p in parts for k in p['chunks'])
newpacks=sorted({v['file'] for v in objects.values()}-set(m['packs']));assert newpacks==['payloads-0031.bin','payloads-0032.bin','payloads-0033.bin'];before=sha(S/'manifest.json')
for name in newpacks:
 p=S/name;assert p.stat().st_size<=evidence_store.PACK;m['packs'][name]=dict(bytes=p.stat().st_size,sha256=sha(p))
relative=z.relative_to(R).as_posix();assert relative not in m['archives'];m['archives'][relative]=dict(sha256=zsha,bytes=z.stat().st_size,recipe=recipe.name,recipe_sha256=sha(recipe));m['index']=dict(file=index.name,sha256=sha(index));m['totals']=dict(original_archive_bytes=sum(v['bytes'] for v in m['archives'].values()),payload_bytes=sum(v['bytes'] for v in m['packs'].values()),objects=len(objects),archives=len(m['archives']))
inv=json.loads(I.read_text());previous=json.loads(subprocess.check_output(['/mnt/c/Program Files/Git/cmd/git.exe','show','HEAD:experimental/alignment-3.17/evidence/inventory.json'],cwd=R,text=True));assert len(previous['files'])==159 and all(inv['files'][k]==v for k,v in previous['files'].items())
prefix='experimental/alignment-3.17/evidence/';bad=[k for k in inv['files'] if k.startswith(prefix)];assert len(bad)==7 and all('20261025-row-threshold-r620/' in k for k in bad)
for k in bad:
 fixed=k[len(prefix):];assert fixed not in inv['files'];inv['files'][fixed]=inv['files'].pop(k)
# Correct the future packaging recipe; retain the original recipe inside the
# already hashed ZIP as the record of the failed metadata-finalization attempt.
for p in [Path('/tmp/sparkling-threshold-checkpoint-r620.py'),D/'package.py']:
 s=p.read_text();assert s.count('p.relative_to(R).as_posix()]=sha(p)')==1;p.write_text(s.replace('p.relative_to(R).as_posix()]=sha(p)','p.relative_to(E).as_posix()]=sha(p)'))
shutil.copy2(__file__,D/'storage-repair.py')
tmp=S/'manifest.json.repair';dump(tmp,m);os.replace(tmp,S/'manifest.json')
dump(D/'storage-repair.json',dict(cause='New inventory entries incorrectly used repository-relative instead of evidence-relative paths. The pack command had created exact immutable payloads, recipe and index, but rejected the inventory before committing its manifest.',correction='Preserved the raw ZIP and all existing payloads. Verified the orphan index extends the old index without changes, recipe chunks exist, three newly created payloads satisfy size/hash checks and all159 previous inventory entries remain unchanged. Finalized that exact transaction and corrected the seven new inventory paths. Corrected the external packaging recipe; its original erroneous version remains inside the exact unchanged ZIP.',old_manifest_sha256=before,new_manifest_sha256=sha(S/'manifest.json'),zip_sha256=zsha,new_packs=newpacks,new_index=index.name,archive_bytes_unchanged=True,full_store_verification_pending=True))
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in previous['files'].items());inv['count']=len(inv['files']);dump(I,inv)
print('EXACT PACK TRANSACTION RECOVERED',m['totals'],'inventory',inv['count'],flush=True)
