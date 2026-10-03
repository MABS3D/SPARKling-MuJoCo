"""Run bounded common-engine proof diagnostics without editing shared sources."""
import argparse, os, subprocess, sys
from pathlib import Path
from build import ROOT
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--repo',type=Path,default=ROOT);p.add_argument('--name',action='append',required=True);p.add_argument('--budget',type=int,default=360)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
env=os.environ.copy();env['TMPDIR']='/var/tmp'
cmd=[sys.executable,str(ROOT/'experimental/smooth/tools/prove_fragments.py'),
 '--repo',str(a.repo),'--report-dir',str(a.out/'report'),
 '--toolchain-root','/var/tmp/sparkling-matrix-recovery/toolchains',
 '--unit','mj-data','--jobs','1','--wall-seconds','180','--prepare-seconds','240',
 '--total-seconds',str(a.budget),'--prover-seconds','5','--steps','0',
 '--provers','cvc5,z3,altergo','--proof-mode','per_path','--cap-mb','2500']
for name in a.name:cmd+=['--name',name]
with (a.out/'run.log').open('w') as log:r=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
print(a.out/'run.log');raise SystemExit(r.returncode)
