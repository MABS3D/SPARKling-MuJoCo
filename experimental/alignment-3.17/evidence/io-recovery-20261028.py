"""Prepare a private annotation fix after Linux execution/storage recovery.

This generator is unexecuted. Verify the saved sources first. No production
source, existing snapshot, test outcome or proof result is overwritten.
"""
from pathlib import Path
import shutil,json,hashlib
V=Path('/var/tmp')
C=V/'sparkling-mocap-model-qualified-control-r2305-20261028';C.mkdir(exist_ok=True)
O=V/'sparkling-mocap-model-qualified-r2306-20261028';O.mkdir()
shutil.copy2(__file__,C/'prepare.py')
for tag in ['317','314']:
 old=V/'sparkling-mocap-model-composed-r2298-20261028'/tag
 hashes=json.loads((old/'sources.json').read_text())
 assert all(hashlib.sha256((old/'source'/n).read_bytes()).hexdigest()==h for n,h in hashes.items())
 out=O/tag;out.mkdir();shutil.copytree(old/'source',out/'source')
 for n in ['sources.json','reference.json','source-order-as-generated.json']:shutil.copy2(old/n,out/n)
 p=out/'source/experimental/smooth/src/mj-data.adb';s=p.read_text()
 assert s.count('with MJ.Models.Validity;')==1
 s=s.replace('with MJ.Models.Validity;','with MJ.Models.Validity;\nwith MJ.Models.Gen_Clauses;')
 for n in ['Bools_OK','Reals_In_Tier0','Refs_OK']:
  oldname='MJ.Models.Validity.'+n;assert s.count(oldname)==1
  s=s.replace(oldname,'MJ.Models.Gen_Clauses.'+n)
 p.write_text(s);hashes[str(p.relative_to(out/'source'))]=hashlib.sha256(p.read_bytes()).hexdigest()
 (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
shutil.copy2(V/'sparkling-mocap-reference-control-r2265-20261028/prove.py',C/'prove.py')
