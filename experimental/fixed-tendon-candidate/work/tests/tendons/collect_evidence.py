#!/usr/bin/env python3
"""Archive a completed run without executables, object files or stale claims."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import random
import statistics
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + '\n')


def archive(target, directories):
    with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
        for directory in directories:
            for file in sorted(directory.rglob('*')):
                if file.is_file():
                    z.write(file, directory.name + '/' + str(file.relative_to(directory)))


def baseline_ratios(session):
    """Independent resampling RNG keeps the recorded workload states intact."""
    rows = {}
    for record in session['records']:
        rows.setdefault(record['case'], {})[record['block'], record['variant']] = statistics.median(
            sample['seconds'] for sample in record['samples'])
    rng = random.Random(20260928)
    result = {}
    for case, times in rows.items():
        if (0, 'baseline') not in times:
            continue
        paired = [times[b, 'baseline']/times[b, 'c'] for b in range(session['blocks'])]
        boot = sorted(statistics.median(rng.choices(paired, k=len(paired))) for _ in range(2000))
        result[case] = dict(median=statistics.median(paired), ci95=[boot[49], boot[1949]])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--proof', type=Path, action='append', required=True,
                        help='Chronological order; later completed attempts replace earlier ones')
    parser.add_argument('--numerics', type=Path, action='append', required=True)
    parser.add_argument('--session', type=Path, action='append', required=True)
    parser.add_argument('--out', type=Path, required=True)
    a = parser.parse_args()
    a.out = a.out.resolve()
    a.out.mkdir(parents=True, exist_ok=False)
    build = read(a.build/'build.json')
    current = build['builds']['current']['sources']
    for rel, expected in current.items():
        assert digest(ROOT/rel) == expected, ('unmeasured source change', rel)
    save(a.out/'build.json', build)
    proofs = {}
    for directory in a.proof:
        result = read(directory/'results.json')
        # Validate the dependency closure actually selected in each project,
        # not unrelated files also copied into a proof snapshot.
        names = set()
        for project in result['projects'].values():
            names.update(re.findall(r'"([^"/]+\.ad[bs])"', project['content']))
        for rel, expected in result['source_sha256'].items():
            if Path(rel).name in names:
                assert digest(ROOT/rel) == expected, ('stale proof dependency', rel)
        for row in result['results']:
            if not row['status'].startswith('not_run'):
                row['report'] = directory.name
                proofs[row['target']['id']] = row
    save(a.out/'proof-index.json', proofs)
    archive(a.out/'proofs.zip', a.proof)
    numerics = [read(p/'results.json') for p in a.numerics]
    assert all(x['status'] == 'passed' and not x['failures'] for x in numerics)
    save(a.out/'numerics.json', numerics)
    archive(a.out/'numerics.zip', a.numerics)
    sessions = [read(p/'measurements.json') for p in a.session]
    for s in sessions:
        assert s['complete'] and s['build_sha256'] == digest(a.build/'build.json')
    save(a.out/'timings.json', [{k:v for k,v in s.items() if k != 'records'} for s in sessions])
    baseline = [baseline_ratios(s) for s in sessions]
    save(a.out/'baseline-over-c.json', baseline)
    archive(a.out/'timings.zip', a.session)
    changed = set(subprocess.check_output(['git','diff','--name-only'],cwd=ROOT,text=True).splitlines())
    changed.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=ROOT,text=True).splitlines())
    changed = sorted(p for p in changed if not p.startswith(str(a.out.relative_to(ROOT))+'/'))
    with zipfile.ZipFile(a.out/'changed-sources.zip','w',zipfile.ZIP_DEFLATED) as z:
        for rel in changed:
            z.write(ROOT/rel, rel)
    save(a.out/'changed-source-sha256.json', {rel:digest(ROOT/rel) for rel in changed})
    (a.out/'tracked.patch').write_bytes(subprocess.check_output(['git','diff','--binary'],cwd=ROOT))
    counts = Counter(x['status'] for x in proofs.values())
    lines = ['# Fixed-tendon acceptance results', '',
             '**Integration draft: full Gold and performance parity across all supported workloads are not established.**', '',
             'The supported implementation is described in [the scope and reproduction guide](../README.md).', '',
             '## Checked numerical agreement', '',
             '| Policy | Scenarios | Scalar comparisons | Policy/rejection tests | Result |',
             '|---|---:|---:|---:|---|']
    for n in numerics:
        lines.append(f"| {n['policy']} | {n['scenarios']} | {n['comparisons']} | {len(n['policy_tests'])} | {n['status']} |")
    lines += ['', 'Tolerance: `2e-10 + 2e-10*abs(reference)`. This is sampled agreement, not a universal equivalence proof.', '',
              '## Integrated performance', '',
              'All ratios are **Ada time / C time**, lower is faster. The range below spans the individual state/session median ratios; it is not a pooled mean or a confidence interval.', '',
              '| Workload | DOFs | Tendons | Range of median ratios |', '|---|---:|---:|---:|']
    grouped = defaultdict(list)
    for s in sessions:
        for row in s['summary']:
            grouped[row['case'].rsplit('-',1)[0]].append(row)
    for name, rows in grouped.items():
        ratios=[r['current_over_c']['median'] for r in rows]
        lines.append(f"| {name} | {rows[0]['nv']} | {rows[0]['ntendon']} | {min(ratios):.4f}–{max(ratios):.4f} |")
    lines += ['', 'The CPU, compiler, release flags, hashes and raw paired samples are archived. Baseline Ada is compared only on the no-tendon controls.', '',
              'No own proof/build jobs ran concurrently with the final timing sessions. Other activity on this shared machine was not controlled. Load averages are recorded below; a low average alone cannot certify an interference-free session.', '']
    for i,s in enumerate(sessions,1):
        lines.append(f"- Session {i}: {s['blocks']} alternating blocks, {s['samples']} samples × {s['steps']} Euler steps, {s['states']} states per model, CPU {s['cpu']}; load averages start `{s.get('loadavg_start')}`, end `{s.get('loadavg_end')}`.")
    lines += ['', '### Individual results', '',
              'MAD and p95 refer to trajectory-average ns/step. Ratio confidence intervals use paired block medians and bootstrap resampling within a session.', '',
              '| Session | Case/state | Ada median ns | C median ns | Ada MAD ns | Ada p95 ns | Ratio [95% CI] |', '|---:|---|---:|---:|---:|---:|---|']
    for i,s in enumerate(sessions,1):
        for row in s['summary']:
            x=row['ns_per_step']['current']; c=row['ns_per_step']['c']; r=row['current_over_c']; lo,hi=r['ci95']
            lines.append(f"| {i} | {row['case']} | {x['median']:.1f} | {c['median']:.1f} | {x['mad']:.1f} | {x['p95']:.1f} | {r['median']:.4f} [{lo:.4f}, {hi:.4f}] |")
    lines += ['', '### Controls against the pre-change Ada baseline', '',
              'Baseline/C is calculated directly from paired blocks, with a separate 2000-resample bootstrap. These are no-tendon workloads; they identify a pre-existing whole-pipeline gap, not the causal cost of individual tendon operations.', '',
              '| Session | Case/state | Baseline/C [95% CI] | Current/baseline [95% CI] |', '|---:|---|---|---|']
    for i, s in enumerate(sessions):
        for row in s['summary']:
            if row['case'] not in baseline[i]:
                continue
            b=baseline[i][row['case']]; r=row['current_over_baseline']
            lines.append(f"| {i+1} | {row['case']} | {b['median']:.4f} [{b['ci95'][0]:.4f}, {b['ci95'][1]:.4f}] | {r['median']:.4f} [{r['ci95'][0]:.4f}, {r['ci95'][1]:.4f}] |")
    lines += ['', '## Formal proof status', '',
              f'Latest attempts per selected subprogram: `{dict(counts)}`. A timeout with zero reported checks is not a pass. A successful fragment is conditional on its preconditions and called contracts; zero-check expression functions are not counted as proved obligations.', '',
              '| Unit/subprogram | Result | Checks | Unproved/flow |', '|---|---|---:|---:|']
    for row in proofs.values():
        t=row['target']
        lines.append(f"| `{t['file']}:{t['name']}` | {row['status']} | {row['proof_checks']} | {row['unproved']} |")
    lines += ['', 'Functional scopes include rounded polynomial terms, ordered length/velocity models, scalar projection with frame preservation, and ordered mass additions with symmetry. Read the diagnostics in `proofs.zip` for the obligations still open.', '',
              '**Still open:** loader proof; remaining kernel/driver obligations; a full functional fold for the passive driver; caller integration and creation/readiness proof closure after adding tendon ownership; the changed tendon CSR validator. These are unfinished proof engineering, not mathematical Silver exceptions. Old whole-pipeline proofs are not automatically inherited by this changed configuration.', '',
              'Spatial paths, tendon actuation/inherited actuator contributions and constraints remain outside this implementation. Performance acceptance for them is therefore absent. The 24-DOF workload must be assessed from both sessions and their uncertainty; an interval containing one establishes neither a speedup nor guaranteed non-inferiority.', '',
              '## Evidence', '',
              '`build.json`, `proof-index.json`, `numerics.json` and `timings.json` provide summaries. Zip archives contain raw logs, structured proof output, fixtures, inputs and timing samples. `changed-sources.zip` holds complete changed files to apply on the recorded baseline; `tracked.patch` omits new files by design. Binaries and object directories are excluded. `SHA256SUMS` covers the evidence files.', '']
    (a.out/'results.md').write_text('\n'.join(lines))
    (a.out/'SHA256SUMS').write_text(''.join(f'{digest(p)}  {p.name}\n' for p in sorted(a.out.iterdir()) if p.is_file() and p.name!='SHA256SUMS'))
    print(a.out/'results.md')


if __name__ == '__main__':
    main()
