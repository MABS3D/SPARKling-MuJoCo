import os,json,subprocess,time,hashlib
from pathlib import Path
out=Path(__file__).resolve().parent
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
source=out/'source'
manifest=json.loads((out/'manifest.json').read_text())
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert all(sha(source/n)==v for n,v in manifest['sources'].items())
env=os.environ.copy()
tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH']=':'.join(str(p) for kind in ('gnat','gprbuild') for p in (tc/kind).glob('*/bin'))+':'+env['PATH']
env.update(SOLVERS_BUILD_ROOT=str(out/'build'),SOLVERS_MODE='release')
commands=[]
for command,label,cap,limit in [
    (['gprbuild','-P',str(source/'experimental/constraint-solvers-candidate/solvers.gpr'),'sparse_cholesky_probe.adb','-j1'],'build',3000,600),
    (['/var/tmp/sparkling-movement315-env/bin/python',str(source/'experimental/constraint-solvers-candidate/tests/test_sparse_cholesky.py'),'--binary',str(out/'build/release/bin/sparse_cholesky_probe'),'--out',str(out/'cases'),'--reference','/var/tmp/sparkling-alignment-315-foundation-r6-20261007/source/mujoco','--reference-version','3.15.0'],'native',2500,240)]:
    start=time.monotonic()
    guarded=['python3',str(root/'tools/guarded.py'),'--cap-mb',str(cap),'--timeout',str(limit),'--',*command]
    with (out/(label+'.log')).open('w') as log:
        run=subprocess.run(guarded,cwd=source,env=env,stdout=log,stderr=subprocess.STDOUT)
    commands.append(dict(label=label,command=guarded,exit=run.returncode,seconds=time.monotonic()-start,log_sha256=sha(out/(label+'.log'))))
    (out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
    print(label,run.returncode,flush=True)
    assert run.returncode==0
assert all(sha(source/n)==v for n,v in manifest['sources'].items())
receipt=dict(complete=True,reference='3.15.0',source_hashes_unchanged=True,manifest_sha256=sha(out/'manifest.json'),runner_sha256=sha(Path(__file__)),commands=commands,binary_sha256=sha(out/'build/release/bin/sparse_cholesky_probe'))
(out/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
