#!/usr/bin/env python3
"""Batch the concrete stable-frame assertions; preserve all unit flow diagnostics."""
import argparse, hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[3]
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project, source_files, diagnostic_messages
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--toolchain-root',type=Path,required=True)
p.add_argument('--seconds',type=int,default=180)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
src=a.out/'source';src.mkdir()
hashes={}
for path in source_files(REPO):
    target=src/path.relative_to(REPO);target.parent.mkdir(parents=True,exist_ok=True)
    content=path.read_bytes();target.write_bytes(content);hashes[str(path.relative_to(REPO))]=hashlib.sha256(content).hexdigest()
for name,h in hashes.items():assert hashlib.sha256((REPO/name).read_bytes()).hexdigest()==h,'source changed while snapshotting'
unit='mj-data-inertia_phase'
text=(src/'experimental/smooth/src'/f'{unit}.adb').read_text()
lines=[i for i,l in enumerate(text.splitlines(),1) if 'pragma Assert (Stable_Ready (D))' in l or 'pragma Loop_Invariant (Static =>' in l]
# Include the new disjointness proof bridges and call, not merely a claim that
# aliases are harmless. The existing numerical solver's other proofs remain separate.
lines += [i for i,l in enumerate(text.splitlines(),1) if 'pragma Assert (Static =>' in l or 'AR.Rows_Disjoint' in l or l.strip() in ('SK.Add_Row','SK.Add_Row_Disjoint')]
lines=sorted(set(lines));selected=a.out/'selected-lines.txt'
selected.write_text(''.join(f'{unit}.adb:{i}\n' for i in lines))
project=isolated_project(src,a.out,unit)
env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
cmd=[sys.executable,str(REPO/'tools/guarded.py'),'--cap-mb','3000','--timeout',str(a.seconds),'--','gnatprove','-P',str(project),'--mode=all','--level=2','--prover=altergo,cvc5','--proof=per_check','--timeout=5','--memlimit=1000','--steps=0','--counterexamples=off','-j2','--report=all','--output=oneline','--checks-as-errors=on',f'--limit-lines={selected}','-u',f'{unit}.adb']
manifest=dict(command=cmd,source_sha256=hashes,selected_lines=lines,unit=unit)
(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
start=time.monotonic();run=subprocess.run(cmd,cwd=src,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
(a.out/'proof.log').write_text(run.stdout)
structured={path.name:json.loads(path.read_text()) for path in a.out.glob('*-obj/**/*.spark')}
(a.out/'proof.spark.json').write_text(json.dumps(structured,indent=2)+'\n')
messages=diagnostic_messages(run.stdout,structured)
proofs=[p for s in structured.values() for p in s.get('proof',[])]
errors=[m for m in messages if m['severity'] in ('error','low','medium','high')]
result=dict(exit_code=run.returncode,seconds=time.monotonic()-start,proof_checks=len(proofs),messages=messages,selected_lines=lines,status='passed' if run.returncode==0 and proofs and not errors else 'pending')
(a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('messages','selected_lines')},indent=2))
for m in errors:print(m)
sys.exit(0 if result['status']=='passed' else 1)
