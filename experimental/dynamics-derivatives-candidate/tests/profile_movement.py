"""Sample the current smooth step with gprof; never use instrumented time for parity.

All sources are copied unchanged from a verified movement build. Sampling and
call counts cover the full process, including setup/reset/output. Every result
is checked against both the uninstrumented Ada result and the saved C oracle.
"""
import argparse, hashlib, json, os, re, shutil, subprocess, time
from pathlib import Path
import numpy as np
from build import ROOT, environment
from benchmark_movement import parse


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True, help='One current movement build directory')
    p.add_argument('--fixtures', type=Path, required=True, help='Completed movement benchmark directory')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--cases', nargs='+', default=['chain_24-0', 'branches_24-0', 'free-0'])
    p.add_argument('--samples', type=int, default=3000)
    p.add_argument('--cpu', type=int, default=12)
    a = p.parse_args()
    a.build = a.build.resolve()
    a.out = a.out.resolve()
    a.fixtures = a.fixtures.resolve()
    assert a.samples > 0
    original = json.loads((a.build/'sources.json').read_text())
    assert all(digest(a.build/'source'/n) == h for n, h in original.items())
    fixtures = json.loads((a.fixtures/'results.json').read_text())
    assert fixtures['passed'] and fixtures['source_and_binary_unchanged']
    assert fixtures['reference'] == '3.17.0'
    records = {r['model']+'-'+str(r['state']): r for r in fixtures['records']}
    assert all(name in records for name in a.cases)
    a.out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(Path(__file__), a.out/'runner.py')
    shutil.copy2(Path(__file__).with_name('benchmark_movement.py'), a.out/'parser.py')
    shutil.copy2(Path(__file__).with_name('build.py'), a.out/'environment.py')
    source = a.out/'source'
    shutil.copytree(a.build/'source', source)
    hashes = dict(original)
    dump(a.out/'sources.json', hashes)
    project_text = (a.build/'movement.gpr').read_text()
    project_text = project_text.replace(str(a.build/'source'), str(source))
    project_text = project_text.replace('"-ffp-contract=off"', '"-ffp-contract=off", "-pg", "-g"')
    project_text, count = re.subn(
        r'(package Linker is\s*for Default_Switches \("Ada"\) use \()([^;]*)(\);)',
        lambda match: match[1] + match[2] + ', "-pg"' + match[3], project_text)
    assert count == 1, 'Expected the movement linker settings'
    project = a.out/'movement.gpr'
    project.write_text(project_text)
    env = environment()
    command = ['python3', str(ROOT/'tools/guarded.py'), '--cap-mb', '3000',
               '--timeout', '600', '--', 'gprbuild', '-P', str(project), '-j1']
    start = time.monotonic()
    with (a.out/'build.log').open('w') as log:
        result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
    dump(a.out/'build.json', dict(command=command, exit=result.returncode,
         seconds=time.monotonic()-start, original_sources_sha256=digest(a.build/'sources.json'),
         sources_sha256=digest(a.out/'sources.json'), library_and_harness_unchanged=True,
         project_sha256=digest(project), fixture_receipt_sha256=digest(a.fixtures/'results.json'),
         toolchain={tool:subprocess.check_output([tool,'--version'],env=env,text=True).splitlines()[0]
                    for tool in ['gcc','gprbuild','gprof']}))
    assert result.returncode == 0, (a.out/'build.log').read_text()[-3000:]
    binary = a.out/'bin/movement_all_probe'
    print('instrumented build passed', flush=True)
    os.sched_setaffinity(0, {a.cpu})
    results = []
    for name in a.cases:
        record = records[name]
        work = a.out/name
        work.mkdir()
        model = a.fixtures/(record['model']+'.mjb')
        assert digest(model) == record['model_sha256']
        shutil.copy2(model, work/'model.mjb')
        shutil.copy2(a.fixtures/(name+'.input'), work/'input.txt')
        oracle = np.asarray(json.loads((a.fixtures/(name+'-oracle.json')).read_text()))
        baseline = parse((a.fixtures/(name+'-00-current.output')).read_text(),
                         record['nq'], record['nv'], record['samples'])[0][1]
        command = [str(binary), str(work/'model.mjb'), str(record['steps']), str(a.samples), '2']
        wrapper = ('import subprocess,sys; '
                   'inp=open(sys.argv[1]); out=open(sys.argv[2],\"w\"); '
                   'raise SystemExit(subprocess.run(sys.argv[3:],stdin=inp,stdout=out).returncode)')
        guarded = ['python3', str(ROOT/'tools/guarded.py'), '--cap-mb', '1500',
                   '--timeout', '120', '--', 'python3', '-c', wrapper,
                   str(work/'input.txt'), str(work/'output.txt'), *command]
        with (work/'run.log').open('w') as log:
            result = subprocess.run(guarded, stdout=log, stderr=subprocess.STDOUT, cwd=work, env=env)
        assert result.returncode == 0, (name, result.returncode)
        rows = parse((work/'output.txt').read_text(), record['nq'], record['nv'], a.samples)
        assert all(np.array_equal(values, baseline) for _, values in rows), name+' Ada equality'
        assert all(np.allclose(values, oracle, atol=2e-10, rtol=2e-10) for _, values in rows), name+' C oracle'
        gmon = work/'gmon.out'
        assert gmon.exists() and gmon.stat().st_size > 0
        with (work/'gprof.txt').open('w') as output:
            subprocess.run(['gprof', '-b', str(binary), str(gmon)], stdout=output, check=True)
        flat = []
        for line in (work/'gprof.txt').read_text().split('Call graph')[0].splitlines():
            match = re.match(r'^\s*(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(.*)$', line)
            if match:
                flat.append(dict(percent=float(match[1]), self_seconds=float(match[3]), columns=match[4]))
        assert any(row['self_seconds'] > 0 for row in flat), 'No statistical samples: '+name
        results.append(dict(case=name, passed=True, command=command, samples=a.samples,
                       steps=record['steps'], model_sha256=digest(model), input_sha256=digest(work/'input.txt'),
                       exact_ada=True, c_tolerance=True, flat_profile=flat,
                       artifacts={n:digest(work/n) for n in ['gmon.out','gprof.txt','output.txt','run.log']}))
        dump(a.out/'partial.json', results)
        print(name, 'checked and profiled', flat[:4], flush=True)
    unchanged = all(digest(source/n) == h for n,h in hashes.items()) and all(
        digest(a.build/'source'/n) == h for n,h in original.items())
    assert unchanged
    dump(a.out/'results.json', dict(passed=True, sources_unchanged=True, cpu=a.cpu,
         binary_sha256=digest(binary), sources_sha256=digest(a.out/'sources.json'), records=results,
         limitations=['Instrumented gprof sampling is diagnostic, not release timing or phase attribution of the C gap.',
             'Sampling and call counts cover the full process, including setup, reset and I/O. Shared-library time is outside the main-image histogram.',
             'Instrumentation changes layout and call overhead; inlining attributes work to containing symbols.',
             'No C phase profile or matched-build parity claim.']))


if __name__ == '__main__':
    main()
