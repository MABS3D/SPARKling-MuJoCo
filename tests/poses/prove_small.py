#!/usr/bin/env python3
"""Diagnose each new/changed subprogram before the whole-unit proof gate."""
from pathlib import Path
import argparse
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
BUILD=HERE/'build/small'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--match',help='Only declaration lines containing this text')
    args=parser.parse_args()
    BUILD.mkdir(parents=True,exist_ok=True)
    for name in ('mj-quaternions.adb','mj-poses.ads','mj-poses.adb'):
        for line,text in enumerate((ROOT/'src'/name).read_text().splitlines(),1):
            if not text.startswith(('   procedure ','   function ','      function ')):
                continue
            if name=='mj-quaternions.adb' and not any(part in text for part in
                    ('function Product (','Squared_Norm','Scale_Component','Normalize')):
                continue
            if name=='mj-poses.ads' and 'procedure ' in text:
                continue
            if name=='mj-poses.adb' and text.startswith('   procedure Normalize ') and text.rstrip().endswith(' with'):
                continue
            if args.match and args.match not in text:
                continue
            # Partial reports from another subprogram must not contaminate this
            # diagnostic. These are never recorded as full-unit receipts.
            for pattern in ('*.spark','*.invocation.json'):
                for old in (BUILD/'obj/proof/gnatprove').glob(pattern):old.unlink()
            command=['gnatprove','-P',str(HERE/'proof.gpr'),
                     '-XPOSE_PROOF_ROOT='+str(BUILD),'-u',name,
                     f'--limit-subp={name}:{line}','--level=2','--proof=per_check',
                     '--timeout=15','-j2','--checks-as-errors=on','--report=all',
                     '--counterexamples=off']
            log=BUILD/f'{name}-{line}.log'
            print(f'{name}:{line} {text.strip()}',flush=True)
            with log.open('w') as output:
                result=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),
                    '--cap-mb','4000','--timeout','300','--',*command],cwd=ROOT,
                    stdout=output,stderr=subprocess.STDOUT)
            if result.returncode:
                print(log.read_text());return result.returncode
    return 0

if __name__=='__main__':sys.exit(main())
