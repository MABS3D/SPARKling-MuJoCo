#!/usr/bin/env python3
"""Use the existing balanced whole-step runner for the invariant experiment."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--reference-build',type=Path,required=True,
                   help='Prior movement run containing movement_c and build.json')
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--toolchain-root',type=Path,required=True)
    p.add_argument('--cpu',type=int,default=12)
    a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    root=a.build.resolve();ref=a.reference_build.resolve()
    builds=json.loads((root/'build.json').read_text())
    metadata=json.loads((ref/'build.json').read_text())
    for label,variant in [('baseline','baseline'),('current','shortcut')]:
        (out/label).symlink_to(root/variant)
        metadata['builds'][label]=builds['builds'][variant]
    (out/'movement_c').symlink_to(ref/'movement_c')
    metadata['experiment']='seven entry guards; current = unpromoted Ready_Flag shortcut'
    (out/'build.json').write_text(json.dumps(metadata,indent=2)+'\n')
    subprocess.run([sys.executable,str(HERE.parent/'run.py'),'--out',str(out),
        '--reuse-build','--toolchain-root',str(a.toolchain_root),
        '--c-library',metadata['builds']['c']['library'],'--cpu',str(a.cpu)],check=True)


if __name__=='__main__':main()
