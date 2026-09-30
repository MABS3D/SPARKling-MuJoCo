#!/usr/bin/env python3
"""Freeze candidate sources; prove minimal subprograms or the complete unit."""
from pathlib import Path
import argparse, hashlib, json, os, re, shutil, signal, subprocess, time

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('name', help='new evidence directory name')
parser.add_argument('subprograms', nargs='*', default=['ALL'])
parser.add_argument('--unit', default='mj-cholesky.adb')
parser.add_argument('--timeout', type=int, default=10)
parser.add_argument('--memory', type=int, default=512)
parser.add_argument('--wall', type=int, default=1200)
parser.add_argument('--proof', choices=['per_check', 'per_path'], default='per_path')
args = parser.parse_args()
out = root / 'results/proofs' / args.name
out.mkdir(parents=True, exist_ok=False)
(out / 'source').mkdir()
for p in (root / 'src').glob('*.ad?'):
    shutil.copy2(p, out / 'source' / p.name)
repo = next(p for p in root.parents if (p / 'docs/verification-policy.md').exists())
for name in ['mj.ads', 'mj-types.ads', 'mj-quaternion_math.ads']:
    if not (out / 'source' / name).exists():
        shutil.copy2(repo / 'src' / name, out / 'source' / name)
(out / 'proof.gpr').write_text('project Proof is\n for Source_Dirs use ("source");\n for Object_Dir use "obj";\n for Create_Missing_Dirs use "True";\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022");\n end Compiler;\nend Proof;\n')
manifest = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((out / 'source').glob('*.ad?'))}
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
env = os.environ.copy()
tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH'] = ':'.join(str(p) for part in ['gnat', 'gprbuild', 'gnatprove'] for p in (tc / part).glob('*/bin')) + ':' + env['PATH']
rows = []
for name in args.subprograms or ['ALL']:
    command = ['gnatprove', '-P', str(out / 'proof.gpr'), '-u', args.unit,
               f'--timeout={args.timeout}', '--steps=0', '--prover=cvc5,z3,altergo',
               f'--proof={args.proof}', '-j2', f'--memlimit={args.memory}',
               '--report=all', '--checks-as-errors=on', '--counterexamples=off']
    if name != 'ALL':
        source = (out / 'source' / args.unit).read_text()
        match = list(re.finditer(r'^   (?:procedure|function) ' + re.escape(name) + r'\b', source, re.M))[-1]
        line = source[:match.start()].count('\n') + 1
        command.append(f'--limit-subp={args.unit}:{line}')
    started = time.monotonic()
    with (out / (name + '.log')).open('w') as log:
        child = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            rc = child.wait(timeout=args.wall)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
            rc = 124
    log = (out / (name + '.log')).read_text()
    row = dict(name=name, exit=rc, seconds=time.monotonic()-started, command=command,
               open=[line for line in log.splitlines() if re.search(r'(^|: ) *(medium|high|error):', line)])
    rows.append(row)
    (out / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
    spark = out / 'obj/gnatprove' / (Path(args.unit).stem + '.spark')
    if spark.exists():
        shutil.copy2(spark, out / (name + '.spark.json'))
    summary = out / 'obj/gnatprove/gnatprove.out'
    if summary.exists():
        shutil.copy2(summary, out / (name + '-summary.txt'))
    print(name, rc, len(row['open']), flush=True)
raise SystemExit(int(any(row['exit'] != 0 for row in rows)))
