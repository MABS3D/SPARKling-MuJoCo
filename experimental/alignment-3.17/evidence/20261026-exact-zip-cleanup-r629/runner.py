from pathlib import Path
import hashlib,json,shutil,subprocess
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';O=Path('/var/tmp/sparkling-exact-zip-duplicates-r629-20261026');O.mkdir();shutil.copy2(__file__,O/'runner.py')
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
m=json.loads((E/'storage/manifest.json').read_text());assert len(m['archives'])==27
original=json.loads((E/'20261025-row-threshold-r620/archive-manifest.json').read_text());assert m['archives']['experimental/alignment-3.17/evidence/20261025-row-threshold-r620/row-threshold.zip']['sha256']==original['zip_sha256']
# Full store verification has checked the exact reconstruction of every one of
# these immutable stored ZIPs. Check each remaining raw copy before unlinking.
records=[];git='/mnt/c/Program Files/Git/cmd/git.exe'
for name,record in m['archives'].items():
 p=R/name
 if not p.exists():continue
 assert p.is_file() and not p.is_symlink() and p.is_relative_to(E),name
 tracked=subprocess.run([git,'ls-files','--error-unmatch','--',name],cwd=R,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 assert tracked.returncode==1,('Tracked archive must remain',name,tracked.returncode)
 ignored=subprocess.run([git,'check-ignore','--',name],cwd=R,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL);assert ignored.returncode==0,name
 assert p.stat().st_size==record['bytes'] and sha(p)==record['sha256'],name
 recipe=E/'storage'/record['recipe'];assert sha(recipe)==record['recipe_sha256']
 records.append(dict(path=name,bytes=record['bytes'],sha256=record['sha256'],git_tracked=False,ignored=True,stored_recipe=record['recipe']))
assert records;before=shutil.disk_usage('/mnt/c').free;dump(O/'audit.json',dict(store_manifest_sha256=sha(E/'storage/manifest.json'),raw_duplicates=records,bytes=sum(x['bytes'] for x in records),host_free_before=before,scope='Only remaining Git-ignored, untracked raw ZIPs with byte-identical entries in the fully verified exact store. All tracked historical ZIPs, recipes, payloads, source, logs, binaries and unique inputs remain. Restore reproduces every original byte without recompression.'))
for record in records:(R/record['path']).unlink()
after=shutil.disk_usage('/mnt/c').free;dump(O/'complete.json',dict(passed=True,raw_zip_files_removed=len(records),bytes_removed=sum(x['bytes'] for x in records),host_free_before=before,host_free_after=after,all_original_bytes_still_restorable=True,vhdx_compacted=False,scope='Redundant local raw Windows copies only; no proof source, report, exact storage object or tracked file removed. Existing ignored raw ZIP links require the documented restore command.'))
print('VERIFIED RAW ZIP DUPLICATES REMOVED',len(records),sum(x['bytes'] for x in records),'HOST FREE',after,flush=True)
