from pathlib import Path
import json, subprocess, hashlib

repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp/sparkling-flex-equality-step-20261003-r254-grouped')
analysis=Path('/var/tmp/sparkling-flex-material-analysis-20261003-r254')
runner=repo/'experimental/flex-elasticity-integration/tests/prove_equality_adapter.py'
source_runner=base/'source/experimental/flex-elasticity-integration/tests/prove_equality_adapter.py'
assert runner.read_bytes()==source_runner.read_bytes()
rows=[]
for tag,scope in [('r255-metric-minimum','materials-metric'),
                  ('r256-element-minimum','materials-element'),
                  ('r257-flex-minimum','materials-flex'),
                  ('r258-row-first-minimum','materials-row-first')]:
    out=Path('/var/tmp/sparkling-flex-equality-step-20261003-'+tag)
    run=subprocess.run(['python3',str(runner),'--build',str(base),'--out',str(out),
                        '--analysis-build',str(analysis),'--scope',scope],cwd=repo)
    r=json.loads((out/'results.json').read_text())
    rows.append(dict(tag=tag,scope=scope,checks=r.get('checks'),proof=r.get('proof_checks'),flow=r.get('flow_checks'),
                     obligations_closed=r['obligations_closed'],strict_pass=r['passed'],warnings=len(r.get('warnings',[])),
                     seconds=r['seconds'],results_sha256=hashlib.sha256((out/'results.json').read_bytes()).hexdigest()))
    Path('/var/tmp/sparkling-flex-material-minima-20261003.json').write_text(json.dumps(dict(base=str(base),
       manifest_sha256=hashlib.sha256((base/'manifest.json').read_bytes()).hexdigest(),scopes=rows,
       claim='Separate minimal scopes on one exact frozen closure; retained warnings keep strict pass false. No whole-loader claim.'),indent=2)+'\n')
    assert r['obligations_closed'] and r['scope_coverage_complete'] and not r['open'], (tag,run.returncode,r)
    print(json.dumps(rows[-1]),flush=True)
print('All four minimal scopes closed; whole loader and caller composition still separate.',flush=True)
