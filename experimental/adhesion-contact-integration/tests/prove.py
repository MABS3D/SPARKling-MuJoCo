"""Minimal adhesion primitives, complete unit, then adapter flow separately."""
import argparse
import json
from pathlib import Path
import re
import resource
import shutil
import subprocess
import time
from build import environment, ROOT

parser = argparse.ArgumentParser()
parser.add_argument('--build', type=Path, required=True)
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--phase', choices=['small', 'whole', 'flow'], required=True)
args = parser.parse_args()
args.out.mkdir(parents=True, exist_ok=False)
resource.setrlimit(resource.RLIMIT_STACK, (64*1024*1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
snapshot = args.build / 'source'
project = snapshot / 'experimental/constrained-step/constrained.gpr'
unit_source = snapshot/'experimental/constrained-step/src'
if not (unit_source/'mj-adhesion.ads').exists():
    unit_source = snapshot/'experimental/adhesion-contact-integration/src'
if args.phase != 'flow':
    project = args.out / 'adhesion-proof.gpr'
    dirs = [str(unit_source), str(snapshot/'src')]
    project.write_text('project Adhesion_Proof is\n'
        + ' for Source_Dirs use (' + ','.join('"'+d+'"' for d in dirs) + ');\n'
        + ' for Source_Files use ("mj.ads", "mj-types.ads", "mj-adhesion.ads", "mj-adhesion.adb");\n'
        + ' for Object_Dir use external ("CONSTRAINED_BUILD_ROOT") & "/obj";\n'
        + ' for Create_Missing_Dirs use "True";\n'
        + ' package Compiler is for Default_Switches ("Ada") use ("-gnat2022"); end Compiler;\n'
        + 'end Adhesion_Proof;\n')
body = unit_source/'mj-adhesion.adb'
targets = [('whole', None)]
if args.phase == 'small':
    targets = [(m[1], 'mj-adhesion.adb:' + str(i))
               for i, line in enumerate(body.read_text().splitlines(), 1)
               if (m := re.match(r'\s*(?:procedure|function) (\w+)', line))]
if args.phase == 'flow':
    targets = [('adapter-flow', None)]
records = []
for label, limit in targets:
    env = environment()
    env['CONSTRAINED_MODE'] = 'validation'
    env['CONSTRAINED_BUILD_ROOT'] = str(args.out / label)
    unit = 'mj-data-constrained-body_adhesion' if args.phase == 'flow' else 'mj-adhesion'
    command = ['gnatprove', '-P', str(project), '-u', unit + '.adb',
               '--prover=cvc5,z3,altergo', '--timeout=5', '--memlimit=700', '--steps=0',
               '--proof=per_path', '-j1', '--checks-as-errors=on', '--warnings=continue',
               '--report=all', '--counterexamples=off']
    if limit: command += ['--limit-subp=' + limit]
    if args.phase == 'flow': command += ['--mode=flow', '--no-inlining']
    start = time.monotonic()
    run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '2600',
                          '--timeout', '240' if args.phase == 'whole' else '100', '--', *command],
                         env=env, capture_output=True, text=True)
    (args.out / (label + '.log')).write_text(run.stdout + run.stderr)
    record = dict(label=label, exit=run.returncode, seconds=time.monotonic()-start, command=command)
    report = next((p for p in (args.out / label).rglob('*.spark') if p.stem == unit), None)
    if report:
        data = json.loads(report.read_text())
        shutil.copyfile(report, args.out / (label + '.spark.json'))
        entries = [m for kind in ('proof', 'flow', 'warn_error') for m in data.get(kind, [])]
        record.update(proof_checks=sum(m.get('severity') == 'info' for m in data.get('proof', [])),
                      flow_checks=sum(m.get('severity') == 'info' for m in data.get('flow', [])),
                      coverage=bool(data.get('spark')) and all(v == 'all' for v in data.get('spark', {}).values())
                        and not any(data.get(k) for k in ['skip_proof', 'skip_flow_proof', 'pragma_assume']),
                      checks=sum(m.get('severity') == 'info' for m in entries),
                      open=sum(m.get('severity') not in ('info', 'warning') for m in entries),
                      warnings=sum(m.get('severity') == 'warning' for m in entries))
    records.append(record)
    (args.out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
    print({k:v for k,v in record.items() if k != 'command'}, flush=True)
(args.out / 'sources.json').write_text((args.build / 'manifest.json').read_text())

expected = 'flow_checks' if args.phase == 'flow' else 'proof_checks'
passed = bool(records) and all(r['exit'] == 0 and r.get('coverage', False)
    and r.get(expected, 0) > 0 and r.get('open', 1) == 0 for r in records)
raise SystemExit(0 if passed else 1)
