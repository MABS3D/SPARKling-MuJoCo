"""Exercise packed row updates with strict checks and the movement release flags.

Reuse the exhaustive disjoint-row corpus, including each rejected SIMD lane,
nonzero array origins, untouched regions, maximum indices and numeric limits.
Do not inherit the historical harness's suppressed-check or unsafe FP flags.
"""
import argparse, hashlib, json, resource, shutil, subprocess
from pathlib import Path
from build import ROOT, environment, FOLDERS, compiler_flags, linker_flags, solver_kernel_switches


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def row_test_stack_limit():
    """Allow large test arrays and validation contract snapshots, per child."""
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    requested = (soft if soft == resource.RLIM_INFINITY else
                 max(soft, 64 * 1024 * 1024))
    if hard != resource.RLIM_INFINITY and requested > hard:
        raise RuntimeError('Row corpus needs at least 64 MiB of test stack')
    resource.setrlimit(resource.RLIMIT_STACK, (requested, hard))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--vector-width', type=int, choices=[128,256,512],
                   help='Match a local solver vector-width preference in the corpus too')
    a = p.parse_args()
    a.build = a.build.resolve()
    a.out = a.out.resolve()
    hashes = json.loads((a.build/'sources.json').read_text())
    assert all(digest(a.build/'source'/name) == h for name, h in hashes.items())
    a.out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(Path(__file__), a.out/'runner.py')
    source = a.out/'source'
    shutil.copytree(a.build/'source', source)
    relative = 'experimental/dynamics-derivatives-candidate/tests/disjoint_rows_probe.adb'
    shutil.copy2(ROOT/'tests/movement_performance/c_parity_six/disjoint_rows_probe.adb', source/relative)
    hashes[relative] = digest(source/relative)
    (a.out/'sources.json').write_text(json.dumps(hashes, indent=2)+'\n')
    results = []
    for mode in ['validation', 'release']:
        flags = compiler_flags(mode)
        if a.vector_width:
            flags = flags + ['-mprefer-vector-width='+str(a.vector_width)]
        work = a.out/mode
        work.mkdir()
        project = work/'rows.gpr'
        project.write_text('project Rows is\n for Source_Dirs use ('+
            ', '.join('"'+str(source/f)+'"' for f in FOLDERS)+');\n'
            ' for Object_Dir use "obj";\n for Exec_Dir use "bin";\n'
            ' for Create_Missing_Dirs use "True";\n for Main use ("disjoint_rows_probe.adb");\n'
            ' package Compiler is\n'+solver_kernel_switches(mode,flags)+' for Default_Switches ("Ada") use ('+
            ', '.join('"'+f+'"' for f in flags)+');\n end Compiler;\n package Linker is\n for Default_Switches ("Ada") use ('+
            ', '.join('"'+f+'"' for f in linker_flags(mode))+');\n end Linker;\nend Rows;\n')
        command = ['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000',
                   '--timeout','600','--','gprbuild','-P',str(project),'-j1']
        with (work/'build.log').open('w') as log:
            subprocess.run(command, env=environment(), stdout=log, stderr=subprocess.STDOUT, check=True)
        binary = work/'bin/disjoint_rows_probe'
        run = subprocess.run([str(binary)], text=True, capture_output=True, timeout=60,
                             preexec_fn=row_test_stack_limit)
        (work/'output.txt').write_text(run.stdout+run.stderr)
        assert run.returncode == 0 and run.stdout.startswith('passed '), run.stdout+run.stderr
        results.append(dict(mode=mode, flags=flags, passed=True, output=run.stdout.strip(),
                            binary_sha256=digest(binary), build_command=command,
                            minimum_test_stack_bytes=64 * 1024 * 1024))
        print(mode, run.stdout.strip(), flush=True)
    unchanged = all(digest(source/n) == h for n,h in hashes.items())
    assert unchanged
    (a.out/'results.json').write_text(json.dumps(dict(passed=True, sources_unchanged=True,
        sources_sha256=digest(a.out/'sources.json'),
        runner_sha256=digest(a.out/'runner.py'), records=results,
        scope='Exact row arithmetic, rejection predicate and frame differential corpus; separate from formal proof and full movement performance.'), indent=2)+'\n')


if __name__ == '__main__':
    main()
