from pathlib import Path
import hashlib, json, shutil

root = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base = Path('/var/tmp')
ev = root / 'experimental/alignment-3.15/evidence'
dest = ev / '20261008-packed-row-view-r60'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def copy(p, q):
    q.parent.mkdir(parents=True, exist_ok=True)
    assert not q.exists(), q
    shutil.copyfile(p, q)

inventory = json.loads((ev / 'inventory.json').read_text())
old = dict(inventory['files'])
assert len(old) == 3565
for name, value in old.items():
    assert sha(ev / name) == value, name
production = base / 'sparkling-alignment-314-packed-regression-r60-20261008'
receipt = json.loads((production / 'results.json').read_text())
assert receipt['complete'] and receipt['reference'] == '3.14.0'
assert receipt['source_hashes_unchanged']
manifest = json.loads((production / 'manifest.json').read_text())
assert all(sha(production / 'source' / k) == v for k, v in manifest['sources'].items())
engine = base / 'sparkling-alignment-315-packed-engine-proof-r60-20261008'
inputs = json.loads((engine / 'manifest.json').read_text())['sources']
for name in ['mj-constraint_solvers-packed_cholesky.ads',
             'mj-constraint_solvers-packed_cholesky.adb', 'mj-constraint_solvers.adb']:
    path = 'experimental/constraint-solvers-candidate/src/' + name
    assert manifest['sources'][path] == inputs[path] == sha(root / path)
for p in production.iterdir():
    if p.is_file():
        copy(p, dest / 'production-314' / p.name)
for p in production.glob('*/results.json'):
    copy(p, dest / 'production-314' / p.parent.name / p.name)
copy(base / 'sparkling-alignment-315-packed-time-r60-quiet-20261008/tail-audit.json',
     dest / 'paired-time/tail-audit.json')
copy(Path(__file__), dest / 'followup/archive.py')
summary = dict(reference='3.14.0', checks_passed=366,
               owned_packed_kernel_and_caller_match_315=True,
               source_hashes_unchanged=True, complete=True, goal_complete=False)
(dest / 'followup/results.json').write_text(json.dumps(summary, indent=2) + '\n')
for name, value in old.items():
    assert sha(ev / name) == value, name
for p in dest.rglob('*'):
    if p.is_file() and str(p.relative_to(ev)) not in old:
        inventory['files'][str(p.relative_to(ev))] = sha(p)
inventory['count'] = inventory['current_entries'] = len(inventory['files'])
inventory['packed_row_view_followup_prior_entries_preserved'] = len(old)
(ev / 'inventory.json').write_text(json.dumps(inventory, indent=2) + '\n')
for name, value in inventory['files'].items():
    assert sha(ev / name) == value, name
print(json.dumps(dict(entries=inventory['count'], preserved=len(old), production_checks=366)))
