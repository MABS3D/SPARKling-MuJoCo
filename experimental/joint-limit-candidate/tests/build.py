#!/usr/bin/env python3
from pathlib import Path
import argparse, json, subprocess, sys
from evidence import HERE, ROOT, environment, snapshot, provenance

ap = argparse.ArgumentParser()
ap.add_argument('--out', type=Path, required=True)
ap.add_argument('--mode', choices=['development', 'validation', 'release'], default='validation')
args = ap.parse_args()
args.out.mkdir(parents=True, exist_ok=True)
sources = snapshot()
env = environment()
env['LIMIT_BUILD_ROOT'] = str(args.out.resolve())
cmd = ['gprbuild', '-P', str(HERE / 'limits.gpr'), '-p', '-f', '-j1', '-XLIMIT_MODE=' + args.mode]
cmd = [sys.executable, str(ROOT/'tools/guarded.py'), '--cap-mb', '2600',
       '--min-free-mb', '12000', '--timeout', '180', '--', *cmd]
p = subprocess.run(cmd, env=env, text=True, capture_output=True)
(args.out / ('build-' + args.mode + '.log')).write_text(p.stdout + p.stderr)
(args.out / ('build-' + args.mode + '.json')).write_text(json.dumps(
    {'command': cmd, 'exit': p.returncode, 'sources': sources, 'environment': provenance(env)}, indent=2) + '\n')
assert sources == snapshot(), 'source changed during build'
print(p.stdout + p.stderr)
raise SystemExit(p.returncode)
