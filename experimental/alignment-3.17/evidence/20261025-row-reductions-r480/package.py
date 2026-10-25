from pathlib import Path
import hashlib,json,shutil,subprocess,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';O=E/'20261025-row-reductions-r480';Z=O/'row-reductions.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 assert not O.exists();O.mkdir();shutil.copy2(__file__,O/'package.py');inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files']);assert len(prior)==117
 runs=[('short-wide',Path('/var/tmp/sparkling-short-wide-run-r470-20261025'),Path('/var/tmp/sparkling-short-wide-candidate-r468-20261025'),Path('/var/tmp/sparkling-short-wide-min-r469-20261025')),('direct-expressions',Path('/var/tmp/sparkling-direct-rows-run-r474-20261025'),Path('/var/tmp/sparkling-direct-rows-r472-20261025'),Path('/var/tmp/sparkling-direct-add-min-r473-20261025')),('bit-rejection',Path('/var/tmp/sparkling-flag-rows-run-r478-20261025'),Path('/var/tmp/sparkling-flag-rows-r476-20261025'),Path('/var/tmp/sparkling-flag-add-min-r477-20261025'))]
 summary={};folders=[Path('/var/tmp/sparkling-short-wide-baseline-r468-20261025'),Path('/var/tmp/sparkling-short-wide-r468-20261025'),Path('/var/tmp/sparkling-generic-baseline-r481-20261025'),Path('/var/tmp/sparkling-generic-baseline-r482-20261025'),Path('/var/tmp/sparkling-generic-variants-r483-20261025')]
 for name,run,source,minimum in runs:
  assert json.loads((run/'complete.json').read_text())['passed'];h=json.loads((source/'sources.json').read_text());assert all(sha(source/'source'/n)==v for n,v in h.items());sessions=[]
  for i in [1,2]:
   d=json.loads((run/f'session{i}/results.json').read_text());assert d['passed'] and d['source_and_binary_unchanged'] and len(d['records'])==30;sessions.append(dict(session=i,records=[{k:x[k] for k in ['model','state','nv','statistics','current_over_baseline','current_over_c','checked_values','max_abs_c']} for x in d['records']]))
  proof=json.loads((minimum/'results.json').read_text());assert proof['obligations_closed'];summary[name]=dict(complete=json.loads((run/'complete.json').read_text()),change=json.loads((source/'change.json').read_text()),minimum=proof,sessions=sessions);folders += [run,source,minimum]
 manifest={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in manifest;nbytes=p.read_bytes();manifest[n]=hashlib.sha256(nbytes).hexdigest();z.writestr(n,nbytes)
  for folder in folders:
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for name in ['sparkling-short-wide-r468.py','sparkling-short-wide-run-r470.py','sparkling-short-wide-resume-r471.py','sparkling-direct-rows-r472.py','sparkling-direct-rows-run-r474.py','sparkling-direct-rows-gates-r475.py','sparkling-flag-rows-r476.py','sparkling-flag-rows-run-r478.py','sparkling-flag-rows-gates-r479.py','sparkling-generic-variants-r483.py']:
   put(Path('/tmp')/name,'recipes/'+name)
  for name in ['engine_core_smooth.c','engine_util_blas.c','engine_util_blas_avx.h']:
   put(Path('/var/tmp/sparkling-reference-317-20261024/src/engine')/name,'c317-review/'+name)
  put(R/'experimental/dynamics-derivatives-candidate/tests/generic_rows_probe.adb','new-corpus/generic_rows_probe.adb')
  put(R/'experimental/dynamics-derivatives-candidate/tests/check_generic_rows.py','new-corpus/check_generic_rows.py')
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert len(z.namelist())==len(manifest) and z.testzip() is None
  assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in manifest.items())
 summary.update(scope='Private, minimum-first exact FP/rejection/frame proofs and integrated smooth Euler diagnostics. No full dynamics/port/C-parity claim. All normal numerical and compiler flags remain. Original live caches not removed.',reference='3.17.0',reference_commit='800a109a4bdd02cb60404d565db4ae16fb04a53b',prior_head='6b552b3af13705930ee75796870d921461242f44',promotion_suite_r475_executed=False,promotion_suite_r479_executed=False,all_three_variants_rejected=True,current_working_kernel_sha256=sha(R/'experimental/smooth/src/mj-solver_kernels.adb'),generic_corpus=json.loads(Path('/var/tmp/sparkling-generic-variants-r483-20261025/results.json').read_text()),baseline_generic_corpus=json.loads(Path('/var/tmp/sparkling-generic-baseline-r482-20261025/results.json').read_text()))
 dump(O/'summary.json',summary);dump(O/'archive-manifest.json',dict(count=len(manifest),files=manifest,zip_bytes=Z.stat().st_size,zip_sha256=sha(Z),excluded='Only obj/analysis/__pycache__/.git components. Raw copied unit.spark reports, logs, frozen sources/manifests, executables, projects, all trajectory outputs/timings, input fixtures and actual recipes retained. Toolchains/shared C libraries external and hash-identified by build receipts.'))
 dump(O/'verification.json',dict(passed=True,archive_members_verified=len(manifest),zip_sha256=sha(Z),all_private_source_closures_verified=True,all_six_complete_sessions_verified=True,prior_inventory_entries=117,scope='Storage/source checks separate from language proof and numerical/performance claims.'))
 print('ARCHIVE READY',Z.stat().st_size,len(manifest),flush=True)
if __name__=='__main__':main()
