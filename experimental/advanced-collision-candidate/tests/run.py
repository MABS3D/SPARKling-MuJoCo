"""Freeze, build and compare this candidate with native MuJoCo 3.14.0.

All generated files go into a new --out directory. Production Ada links no C.
This is numerical validation, not a timing or universal equivalence proof.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
RECOVERY = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
GNAT = RECOVERY / 'gnat/gnat-x86_64-linux-16.1.0-1/bin'
GPR = RECOVERY / 'gprbuild/gprbuild-x86_64-linux-26.0.0-1/bin'
COMMIT = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'

def hashes(root):
    return {str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(root.rglob('*')) if p.is_file() and '__pycache__' not in p.parts}

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',required=True,type=Path)
    ap.add_argument('--upstream',type=Path,default=ROOT.parents[1]/'mujoco')
    ap.add_argument('--gnat-bin',type=Path,default=GNAT)
    ap.add_argument('--gprbuild',type=Path,default=GPR/'gprbuild')
    ap.add_argument('--python',type=Path,default=Path('/var/tmp/sparkling-movement-env/bin/python'))
    ap.add_argument('--ccd-root',type=Path,default=Path('/var/tmp/sparkling-movement-c/build'))
    ap.add_argument('--guarded',type=Path,default=ROOT.parents[1]/'tools/guarded.py')
    a=ap.parse_args(); out=a.out.resolve();upstream=a.upstream.resolve()
    def git_read(*args):
        return subprocess.check_output(['git','-C',str(upstream),*args],text=True,
                                       env={**os.environ,'GIT_OPTIONAL_LOCKS':'0'}).strip()
    commit=git_read('rev-parse','HEAD')
    dirty=git_read('status','--porcelain','--untracked-files=no')
    if commit!=COMMIT or dirty:raise RuntimeError('the reference must be the clean pinned MuJoCo release')
    out.mkdir(parents=True,exist_ok=False)
    shutil.copy2(a.guarded,out/'guarded.py')
    snap=out/'snapshot';snap.mkdir()
    for directory in ('src','vendor','tests'):
        shutil.copytree(ROOT/directory,snap/directory,ignore=shutil.ignore_patterns('__pycache__'))
    for name in ('advanced.gpr','NOTICE','LICENSE','vendor-hashes.json'):
        shutil.copy2(ROOT/name,snap/name)
    usnap=out/'upstream';usnap.mkdir()
    for directory in ('src','include'):
        shutil.copytree(upstream/directory,usnap/directory)
    env=os.environ.copy();env['PATH']=str(a.gnat_bin)+':'+str(a.gprbuild.parent)+':'+env['PATH']
    commands=[]
    def run(argv,log):
        args=[sys.executable,str(out/'guarded.py'),'--cap-mb','3000','--timeout','360',
              '--',*[str(x) for x in argv]];commands.append(args)
        with (out/log).open('w') as f:
            subprocess.run(args,cwd=snap,env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
    def version(argv):
        return subprocess.check_output([str(x) for x in argv],env=env,text=True).strip()
    lib=Path(version([a.python,'-c','import mujoco,pathlib;print(pathlib.Path(mujoco.__file__).parent / "libmujoco.so.3.14.0")']))
    if not lib.is_file(): raise RuntimeError('native MuJoCo 3.14.0 shared library is missing')
    if version([a.python,'-c','import mujoco;print(mujoco.__version__)'])!='3.14.0':
        raise RuntimeError('wrong native reference version')
    # Compile the exact static C filter from the pinned snapshot. AABB and OBB
    # are mathematically related but round differently at extreme coordinates.
    driver=(usnap/'src/engine/engine_collision_driver.c').read_text()
    match=re.search(r'^static int filterBox\([\s\S]*?^}',driver,re.M)
    if match is None:raise RuntimeError('pinned C AABB filter not found')
    aabb=out/'aabb-reference.c'
    aabb.write_text('#include <mujoco/mujoco.h>\n'+match[0]+
                   '\nint ref_aabb(const double* a, const double* b, double margin) '
                   '{ return !filterBox(a, b, margin); }\n')
    native=out/'reference.so';ccd=a.ccd_root.resolve()
    cargv=[a.gnat_bin/'gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
           '-Wl,-Bsymbolic','-Wl,-z,defs', '-I'+str(usnap/'include'),'-I'+str(usnap/'src'),
           '-I'+str(ccd/'_deps/ccd-src/src'),'-I'+str(ccd/'_deps/ccd-build/src'),
           snap/'tests/reference.c',aabb,
           *[usnap/'src/engine'/n for n in ('engine_collision_primitive.c','engine_collision_flex.c',
                                          'engine_collision_convex.c','engine_collision_box.c')],
           ccd/'lib/libccd.a',lib,'-Wl,-rpath,'+str(lib.parent),'-lm','-o',native]
    run(cargv,'reference-build.log')
    for mode in ('validation','release'):
        print('build and compare',mode,flush=True)
        run([a.gprbuild,'-Padvanced.gpr','-j1','-XADVANCED_MODE='+mode,
             '-XADVANCED_BUILD_ROOT='+str(out/'build')],mode+'-build.log')
        binary=out/'build'/mode/'bin'
        run([binary/'advanced_checks'],mode+'-checks.log')
        run([a.python,snap/'tests/verify.py','--binary',binary/'advanced_probe',
             '--oracle',native,'--out',out/mode],mode+'-differential.log')
    manifest={'reference':{'version':'3.14.0','expected_commit':COMMIT,
                          'actual_commit':commit,'working_tree_status':dirty,
                          'library':str(lib),'library_sha256':hashlib.sha256(lib.read_bytes()).hexdigest()},
              'hardware':{'platform':platform.platform(),'machine':platform.machine(),
                          'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0]},
              'compilers':{'gcc':version([a.gnat_bin/'gcc','--version']),
                           'gprbuild':version([a.gprbuild,'--version']),
                           'python':version([a.python,'--version'])},
              'candidate_sha256':hashes(snap),'upstream_sha256':hashes(usnap),
              'oracle_sha256':hashlib.sha256(native.read_bytes()).hexdigest(),
              'aabb_reference_sha256':hashlib.sha256(aabb.read_bytes()).hexdigest(),
              'ccd_sha256':hashlib.sha256((ccd/'lib/libccd.a').read_bytes()).hexdigest(),
              'ccd_headers_sha256':{'source/'+k:v for k,v in hashes(ccd/'_deps/ccd-src/src/ccd').items()} | {
                  'generated/'+k:v for k,v in hashes(ccd/'_deps/ccd-build/src/ccd').items()},
              'binaries_sha256':hashes(out/'build/validation/bin')|{
                  'release/'+k:v for k,v in hashes(out/'build/release/bin').items()},
              'commands':commands,'performance':'not measured; numerical checks only'}
    if manifest['reference']['actual_commit']!=COMMIT:raise RuntimeError('upstream is not the pinned release')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('all checked and release comparisons passed; evidence:',out,flush=True)

if __name__=='__main__':main()
