from pathlib import Path
import gzip, hashlib, json, re, shutil

root = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base = Path('/var/tmp')
evidence = root / 'experimental/alignment-3.15/evidence'
dest = evidence / '20261008-packed-row-view-r60'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def copy(p, q):
    q.parent.mkdir(parents=True, exist_ok=True)
    assert not q.exists(), q
    shutil.copyfile(p, q)

def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    assert not p.exists(), p
    p.write_text(json.dumps(value, indent=2) + '\n')

inventory = json.loads((evidence / 'inventory.json').read_text())
old = dict(inventory['files'])
assert len(old) == 3171
for name, digest in old.items():
    assert sha(evidence / name) == digest, name
assert not dest.exists()
engines = {}
for stage in range(54, 61):
    engine = base / f'sparkling-alignment-315-packed-engine-proof-r{stage}-20261008'
    manifest = json.loads((engine / 'manifest.json').read_text())
    assert all(sha(engine / 'source' / n) == v for n, v in manifest['sources'].items())
    engines[sha(engine / 'manifest.json')] = engine
    out = dest / 'proof-source' / engine.name
    copy(engine / 'manifest.json', out / 'manifest.json')
    for n in ['mj-constraint_solvers-packed_cholesky.ads', 'mj-constraint_solvers-packed_cholesky.adb']:
        copy(engine / 'source/experimental/constraint-solvers-candidate/src' / n, out / n)
runner = (root / 'experimental/alignment-3.15/tests/prove_flex.py').read_text()
attempts = []
for receipt in sorted(base.glob('sparkling-alignment-315-packed-*-scope-r*-20261008/results.json')):
    stage = int(re.search(r'-r(\d+)', receipt.parent.name)[1])
    if stage < 54 or stage > 60:
        continue
    data = json.loads(receipt.read_text())
    assert data['manifest_sha256'] in engines
    historical = '\n'.join(line for line in runner.splitlines()
        if not (stage < 56 and '"Packed_Set_Scratch":' in line)
        and not (stage < 57 and '"Packed_Prefix_Progress":' in line)) + '\n'
    assert hashlib.sha256(historical.encode()).hexdigest() == data['runner_sha256'], receipt
    out = dest / 'attempts' / receipt.parent.name
    for n in ['results.json', 'proof.log', 'unit.spark.json']:
        if (receipt.parent / n).exists():
            copy(receipt.parent / n, out / n)
    (out / 'prove_flex.py').write_text(historical)
    attempts.append(dict(stage=stage, receipt=receipt.parent.name,
        scope=data['subprogram'], checks=data.get('checks'),
        closed=data.get('obligations_closed', False), passed=data['passed'],
        open=len(data.get('open', [])), warnings=data.get('warnings', [])))
write(dest / 'attempts.json', attempts)
for name, stage in [('Prefix_Progress', 59), ('Update_Row', 60)]:
    receipt = base / f'sparkling-alignment-315-packed-{name.lower().replace("_", "-")}-scope-r{stage}-20261008/results.json'
    data = json.loads(receipt.read_text())
    assert data['passed'] and data['obligations_closed'] and data['scope_coverage_complete']
    assert not data['open'] and not data['warnings']
engine = base / 'sparkling-alignment-315-packed-engine-proof-r60-20261008'
sources = json.loads((engine / 'manifest.json').read_text())['sources']
audit = json.loads((base / 'sparkling-packed-minima-reuse-r60-20261008.json').read_text())
update = json.loads((base / 'sparkling-alignment-315-packed-update-row-scope-r60-20261008/results.json').read_text())
audit['scopes'].append(dict(scope='Update_Row', stage=60, checks=update['checks'],
    receipt='sparkling-alignment-315-packed-update-row-scope-r60-20261008',
    closed=update['obligations_closed'], warnings=update['warnings']))
audit['checks'] += update['checks']
write(dest / 'closure.json', audit)
for label in ['native', 'release']:
    folder = base / f'sparkling-alignment-315-packed-{label}-r60-20261008'
    receipt = json.loads((folder / 'results.json').read_text())
    assert receipt['complete'] and receipt['source_hashes_unchanged']
    inputs = json.loads((folder / 'manifest.json').read_text())['sources']
    assert all(inputs.get(k) == v for k, v in sources.items())
    for p in folder.iterdir():
        if p.is_file():
            copy(p, dest / label / p.name)
    for p in folder.glob('*/results.json'):
        copy(p, dest / label / p.parent.name / p.name)
    if label == 'native':
        for n in ['input.txt', 'output.txt']:
            p = folder / 'cases' / n
            q = dest / label / 'cases' / (n + '.gz')
            q.parent.mkdir(parents=True, exist_ok=True)
            q.write_bytes(gzip.compress(p.read_bytes(), mtime=0))
            assert gzip.decompress(q.read_bytes()) == p.read_bytes()
        copy(folder / 'cases/reference.c', dest / label / 'cases/reference.c')
        for n in ['packed_cholesky_probe.adb', 'test_sparse_cholesky.py']:
            copy(folder / 'source/experimental/constraint-solvers-candidate/tests' / n, dest / label / n)
        copy(folder / 'source/experimental/constraint-solvers-candidate/solvers.gpr', dest / label / 'solvers.gpr')
timing = base / 'sparkling-alignment-315-packed-time-r60-quiet-20261008'
data = json.loads((timing / 'results.json').read_text())
assert data['complete'] and data['quiet_window'] and all(r['passed'] for r in data['results'])
for p in timing.iterdir():
    if p.is_file() and p.suffix != '.so':
        copy(p, dest / 'paired-time' / p.name)
for n in ['prove_flex.py', 'build_flex.py', 'build_packed.py']:
    copy(root / 'experimental/alignment-3.15/tests' / n, dest / n)
copy(root / 'tools/guarded.py', dest / 'guarded.py')
for p in (base / 'sparkling-packed-factor-assembly-r60-20261008').iterdir():
    if p.is_file():
        copy(p, dest / 'assembly' / p.name)
copy(Path(__file__), dest / 'archive.py')
write(dest / 'results.json', dict(reference='3.15.0', source_count=len(sources),
    native_cases_passed=395, integrated_checks_passed=390,
    proof_attempts=attempts, row_update_closed=True,
    whole_factor_functional_closed=False, whole_backsolve_functional_closed=False,
    caller_gold_closed=False, goal_complete=False,
    performance=data['results']))
for name, digest in old.items():
    assert sha(evidence / name) == digest, name
for p in dest.rglob('*'):
    if p.is_file():
        inventory['files'][str(p.relative_to(evidence))] = sha(p)
inventory['count'] = inventory['current_entries'] = len(inventory['files'])
inventory['packed_row_view_prior_entries_preserved'] = len(old)
(evidence / 'inventory.json').write_text(json.dumps(inventory, indent=2) + '\n')
for name, digest in inventory['files'].items():
    assert sha(evidence / name) == digest, name
print(json.dumps(dict(entries=inventory['count'], prior_preserved=len(old))))
