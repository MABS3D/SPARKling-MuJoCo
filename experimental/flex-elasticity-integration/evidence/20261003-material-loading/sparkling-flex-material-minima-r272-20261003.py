from pathlib import Path
import json, subprocess, hashlib

repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp/sparkling-flex-equality-step-20261003-r272-wide')
analysis=Path('/var/tmp/sparkling-flex-material-analysis-20261003-r272')
runner=repo/'experimental/flex-elasticity-integration/tests/prove_equality_adapter.py'
assert runner.read_bytes()==(base/'source/experimental/flex-elasticity-integration/tests/prove_equality_adapter.py').read_bytes()
rows=[]
for tag,scope in [('r274-element-minimum','materials-element'),
                  ('r275-metric-minimum','materials-metric'),
                  ('r276-flex-minimum','materials-flex'),
                  ('r277-row-first-minimum','materials-row-first'),
                  ('r278-vertex-minimum','materials-vertex'),
                  ('r279-edge-minimum','materials-edge')]:
    out=Path('/var/tmp/sparkling-flex-equality-step-20261003-'+tag)
    run=subprocess.run(['python3',str(runner),'--build',str(base),'--out',str(out),
                        '--analysis-build',str(analysis),'--scope',scope],cwd=repo,stdout=subprocess.DEVNULL)
    r=json.loads((out/'results.json').read_text())
    row=dict(tag=tag,scope=scope,checks=r.get('checks'),proof=r.get('proof_checks'),flow=r.get('flow_checks'),
             obligations_closed=r['obligations_closed'],strict_pass=r['passed'],warnings=len(r.get('warnings',[])),
             seconds=r['seconds'],results_sha256=hashlib.sha256((out/'results.json').read_bytes()).hexdigest())
    rows.append(row)
    Path('/var/tmp/sparkling-flex-material-minima-r272-20261003.json').write_text(json.dumps(dict(base=str(base),
       manifest_sha256=hashlib.sha256((base/'manifest.json').read_bytes()).hexdigest(),scopes=rows,
       claim='Separate minimal scopes on one exact frozen closure; retained warnings keep strict pass false. No whole-loader claim.'),indent=2)+'\n')
    print(json.dumps(row),flush=True)
    if not (r['obligations_closed'] and r.get('scope_coverage_complete') and not r.get('open')):
        print(json.dumps(dict(stopped_at=scope,exit=run.returncode,open=[{k:e.get(k) for k in ('rule','line','col','message')} for e in r.get('open',[])])),flush=True)
        raise SystemExit(1)
print('All six minimal scopes closed; whole loader and caller composition still separate.',flush=True)
