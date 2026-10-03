"""Compatibility entry point for the frozen API build/proof drivers."""
import argparse, pathlib, subprocess, sys
p=argparse.ArgumentParser();p.add_argument('--out',required=True)
p.add_argument('--phase',choices=['build','small','whole'],required=True)
p.add_argument('--mode',default='validation');p.add_argument('--unit',default='mj-api-state')
p.add_argument('--only');p.add_argument('--reuse',action='store_true');a=p.parse_args()
here=pathlib.Path(__file__).resolve().parent
if a.phase=='build':
 cmd=[sys.executable,str(here/'build.py'),'--out',a.out,'--mode',a.mode,'--working-dependencies']
 if a.reuse:cmd+=['--resume']
else:
 if a.reuse:p.error('proof receipts must use a fresh output directory')
 cmd=[sys.executable,str(here/'prove.py'),'--out',a.out,'--unit',a.unit]
 if a.phase=='small':
  if not a.only:p.error('small proof requires --only')
  cmd+=['--only',a.only]
raise SystemExit(subprocess.run(cmd).returncode)
