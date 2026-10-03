"""Prove each surface-velocity subprogram, then its complete standalone unit."""
import argparse, hashlib, json, re, shutil, subprocess, time
from pathlib import Path
from build import environment, ROOT

p = argparse.ArgumentParser()
p.add_argument('--out', type=Path, required=True)
p.add_argument('--only')
p.add_argument('--timeout', type=int, default=5)
p.add_argument('--wall-timeout', type=int, default=240)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
src = a.out / 'source'
src.mkdir()
hashes = {}
for rel in ['src/mj.ads', 'src/mj-types.ads',
            'experimental/constrained-step/src/mj-surface_velocity.ads',
            'experimental/constrained-step/src/mj-surface_velocity.adb']:
    data = (ROOT / rel).read_bytes()
    (src / Path(rel).name).write_bytes(data)
    hashes[rel] = hashlib.sha256(data).hexdigest()
(a.out / 'sources.json').write_text(json.dumps(hashes, indent=2) + '\n')
body = src / 'mj-surface_velocity.adb'
targets = [(m[1], f'mj-surface_velocity.adb:{i}')
           for i, line in enumerate(body.read_text().splitlines(), 1)
           if (m := re.match(r'\s*function (\w+)', line))]
spec = (src / 'mj-surface_velocity.ads').read_text().splitlines()
value_line = next(i for i, line in enumerate(spec, 1) if 'function Geometry_Value ' in line)
position = next(i for i, target in enumerate(targets) if target[0] == 'Geometry')
targets.insert(position, ('Geometry_Value', f'mj-surface_velocity.ads:{value_line}'))
targets += [('whole', None)]
if a.only:
    targets = [t for t in targets if t[0] == a.only]
records = []
for label, limit in targets:
    if label == 'whole' and any(r['exit'] or r.get('open', 1) or r.get('warnings', 1) for r in records):
        break
    obj = a.out / label
    obj.mkdir()
    project = a.out / (label + '.gpr')
    project.write_text(f'''project Surface_Proof is
  for Source_Dirs use ("source");
  for Object_Dir use "{label}";
  package Compiler is
    for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off");
  end Compiler;
end Surface_Proof;
''')
    cmd = ['gnatprove', '-P', str(project), '-u', 'mj-surface_velocity.adb',
           '--prover=cvc5,z3,altergo', f'--timeout={a.timeout}', '--memlimit=700',
           '--steps=0', '--proof=per_path', '--no-inlining', '-j1', '--checks-as-errors=on',
           '--warnings=continue', '--report=all', '--counterexamples=off']
    if limit:
        cmd.append('--limit-subp=' + limit)
    start = time.monotonic()
    run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'),
                          '--cap-mb', '2200', '--min-free-mb', '12000', '--timeout', str(a.wall_timeout), '--', *cmd],
                         env=environment(), text=True, capture_output=True)
    (a.out / (label + '.log')).write_text(run.stdout + run.stderr)
    entry = dict(label=label, exit=run.returncode,
                 seconds=time.monotonic() - start, command=cmd)
    report = next(obj.rglob('mj-surface_velocity.spark'), None)
    if report:
        data = json.loads(report.read_text())
        shutil.copyfile(report, a.out / (label + '.spark.json'))
        checks = [v for k in ('proof', 'flow', 'warn_error') for v in data.get(k, [])]
        entry.update(proved=sum(v.get('severity') == 'info' for v in checks),
                     open=sum(v.get('severity') not in ('info', 'warning') for v in checks),
                     warnings=sum(v.get('severity') == 'warning' for v in checks))
        if limit is None:
            entry['complete_coverage'] = (not data['skip_proof'] and not data['skip_flow_proof']
                and not data['pragma_assume'] and all(v == 'all' for v in data['spark'].values())
                and data['progress'] == 'PROGRESS_PROOF' and data['stop_reason'] == 'STOP_REASON_NONE')
            entry['entities'] = sorted(data['entities'][k]['name'] for k in data['spark'])
    records.append(entry)
    print(entry, flush=True)
(a.out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
if not records or any(r['exit'] or r.get('open', 1) or r.get('warnings', 1)
    or (r['label'] == 'whole' and not r.get('complete_coverage')) for r in records):
    raise SystemExit(1)
