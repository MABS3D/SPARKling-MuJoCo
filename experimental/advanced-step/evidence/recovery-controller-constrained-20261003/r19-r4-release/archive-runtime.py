from pathlib import Path
import argparse,shutil,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--mode',required=True,choices=['validation','release']);a=p.parse_args()
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');build=Path('/var/tmp/sparkling-services-advanced-constrained-r19-r4-20261003');src=Path('/var/tmp/sparkling-services-advanced-regression-r19-r4-'+a.mode+'-20261003');out=repo/'experimental/advanced-step/evidence/recovery-controller-constrained-20261003'/('r19-r4-'+a.mode);out.mkdir(exist_ok=True)
for f in src.iterdir():
 if f.is_file():shutil.copy2(f,out/f.name)
manifest={}
for label in ['edges','minimum','smooth','fixed','mobile','parent']:
 (out/label).mkdir(exist_ok=True);shutil.copy2(src/label/'results.json',out/label/'results.json')
 for f in (src/label).iterdir():
  if f.is_file() and f.suffix in ['.input','.mjb','.output']:
   manifest[str(f.relative_to(src))]=hashlib.sha256(f.read_bytes()).hexdigest()
(out/'runtime-files-sha256.json').write_text(json.dumps({'source':str(src),'files':manifest},indent=2)+'\n')
for name in ['manifest.json','build-'+a.mode+'.log','owned-staging.patch','owned-staging.json','staging-equivalence-scope.json']:shutil.copy2(build/name,out/name)
for name in ['build_constrained.py','run_constrained_regression.py']:shutil.copy2(repo/'experimental/advanced-step/tests'/name,out/('executed-'+name))
shutil.copy2('/var/tmp/sparkling-services-controller-compare-records-r19-r3.py',out/'executed-compare-records.py');shutil.copy2(__file__,out/'archive-runtime.py')
for name in ['controller_edges.py','compare_constrained.py','compare.py']:shutil.copy2(build/'source/experimental/advanced-step/tests'/name,out/('executed-'+name))
shutil.copy2(build/'source/experimental/constrained-step/tests/compare.py',out/'executed-parent-compare.py')
print({'mode':a.mode,'file_hashes':len(manifest),'out':str(out)})
