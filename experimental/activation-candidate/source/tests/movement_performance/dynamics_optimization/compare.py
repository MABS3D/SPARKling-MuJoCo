#!/usr/bin/env python3
"""Measure one independent session using the frozen, verified build inputs."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path, required=True)
    parser.add_argument('--cpu', type=int, default=12)
    parser.add_argument('--blocks', type=int, default=24)
    args = parser.parse_args()
    root = args.build.resolve()
    out = args.out.resolve()
    metadata = json.loads((root / 'build.json').read_text())
    out.mkdir(parents=True, exist_ok=False)
    for variant in ('baseline', 'current'):
        (out / variant).symlink_to(root / variant)
    (out / 'movement_c').symlink_to(root / 'movement_c')
    shutil.copy2(root / 'build.json', out / 'build.json')
    command = [sys.executable, str(HERE.parent / 'run.py'), '--out', str(out),
        '--reuse-build', '--toolchain-root', str(args.toolchain_root),
        '--c-library', metadata['builds']['c']['library'], '--cpu', str(args.cpu),
        '--blocks', str(args.blocks), '--ada-comparison', 'tolerance',
        '--extra-fixtures', str(HERE / 'fixtures')]
    for model in ('hinge_motor', 'branched_multijoint', 'chain_12',
                  'crb_no_damping', 'crb_chain_24'):
        command += ['--model', model]
    subprocess.run(command, check=True)


if __name__ == '__main__':
    main()
