from pathlib import Path
import hashlib,json,os,re,shutil,subprocess
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';A=E/'20261026-constructor-and-force-r967';D=E/'20261026-completed-cache-cleanup-r968';V=Path('/var/tmp');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 manifest=json.loads((A/'archive-manifest.json').read_text());roots=list(map(Path,manifest['roots']));assert all(p.parent==V and re.search(r'-r(\d+)-20261026$',p.name) and 907<=int(re.search(r'-r(\d+)-20261026$',p.name)[1])<=965 for p in roots)
 heavy={'gnatprove','gnat2why','gnatwhy3','why3server','gprbuild','gnat1','gcc','g++','cc1','cc1plus','cvc5','z3','alt-ergo','ld','lto1','lto-wrapper','git','git.exe','zip'};active=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit() or int(p.name)==os.getpid():continue
  try:
   comm=(p/'comm').read_text().strip()
   if comm in heavy:
    cwd=os.readlink(p/'cwd')
    if cwd.startswith((str(R),'/var/tmp/sparkling','/tmp')):active.append(dict(pid=int(p.name),comm=comm,cwd=cwd))
  except (OSError,PermissionError):pass
 assert not active,active
 D.mkdir();shutil.copy2(__file__,D/'cleanup.py');preserved=[]
 for name in ['sparkling-total-force-unit-r914-20261026','sparkling-total-force-baseline-unit-r916-20261026']:
  p=V/name;analysis=p/'analysis'
  for source in sorted(analysis.rglob('*')):
   if source.is_file() and source.name in ['why3session.xml','why3shapes.gz']:
    out=D/'partial-sessions'/name/source.parent.name/source.name;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,out);preserved.append(dict(original=str(source),copy=str(out.relative_to(D)),bytes=out.stat().st_size,sha256=sha(out)))
 assert len([p for p in preserved if p['copy'].endswith('why3session.xml')])==20
 dirs=[]
 for root in roots:
  for p in root.rglob('*'):
   relative=p.relative_to(root)
   if p.is_dir() and p.name in ['obj','analysis'] and 'source' not in relative.parts and not any(x in ['obj','analysis'] for x in relative.parts[:-1]):
    assert not p.is_symlink() and p.resolve().is_relative_to(root.resolve());dirs.append(p)
 assert len(dirs)==45
 q=subprocess.run(['du','-sb',*[str(p) for p in dirs]],capture_output=True,text=True,check=True);sizes={path:int(size) for size,path in (line.split('\t',1) for line in q.stdout.splitlines())};assert set(sizes)==set(map(str,dirs))
 dump(D/'plan.json',dict(eligible_cache_directories=sizes,apparent_bytes=sum(sizes.values()),partial_sessions=preserved,active_own_heavy_processes=active,archived_root_manifest_sha256=sha(A/'archive-manifest.json'),scope='Only generated obj/analysis directories outside frozen source trees, in completed task roots907..965. Partial Why3 session XML/shapes from both timed-out whole math controls copied first; no whole-unit closure claim. Frozen sources, full copied reports/logs, baseline flow traces, binaries, numerical inputs/outputs and raw timing remain in the exact967 archive. Toolchains, other projects, runtime binaries and source trees excluded.'))
 # Include new immutable receipts in the full inventory BEFORE verifying all
 # archived inputs, then perform only the precise approved generated-cache list.
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.rglob('*'):
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 verified=subprocess.run(['python3',str(R/'tools/evidence_store.py'),'verify'],cwd=R,capture_output=True,text=True,check=True);v=json.loads(verified.stdout);assert v['passed'] and v['archives']==39;linux_before=shutil.disk_usage(V)._asdict();windows_before=shutil.disk_usage('/mnt/c')._asdict();removed=[]
 for p in dirs:
  assert p.is_dir() and not p.is_symlink();shutil.rmtree(p);removed.append(str(p))
 assert all(not p.exists() for p in dirs)
 dump(D/'results.json',dict(passed=True,removed_cache_directories=removed,removed_apparent_bytes=sum(sizes.values()),preserved_partial_sessions=len(preserved),full_store_verified_before_removal=v,linux_before=linux_before,linux_after=shutil.disk_usage(V)._asdict(),windows_before=windows_before,windows_after=shutil.disk_usage('/mnt/c')._asdict(),scope='Cache reclamation only. du -b reports apparent bytes, not equivalent physical Windows-byte recovery. WSL was not stopped; no VHDX compaction or filesystem trim performed. All removed artifacts regenerate from preserved frozen sources/recipes.'))
 (D/'README.md').write_text('''# Completed-task generated cache cleanup

This removes only the exact45 generated obj/analysis directories listed in
plan.json, outside frozen source trees in completed task roots907..965. Toolchains,
other projects, active work, runtime binaries and all sources are untouched.
The original967 archive preserves sources, complete copied reports, errors,
baseline flow traces, binaries, numerical corpora and raw timing. All39 stored
archives and the complete inventory are verified before removal. Original partial
Why3 session XML/shapes from both timed-out complete math attempts are copied
here first; they are partial diagnostics, not complete unit proof evidence.

Byte counts use du --apparent-size. Linux free blocks do not imply equal physical
Windows recovery. WSL is not stopped, and its VHDX is not compacted or trimmed.
This storage operation changes no numerical code or formal/performance claim.
All result receipts and immutable evidence remain local; no commit or push.
''')
 inv=json.loads((E/'inventory.json').read_text())
 for p in D.rglob('*'):
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(passed=True,removed_directories=len(removed),apparent_bytes=sum(sizes.values()),partial_reports_preserved=len(preserved),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
