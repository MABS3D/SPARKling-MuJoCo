#!/usr/bin/env python3
"""Build checked probes or a native optimized whole-step comparison."""
from pathlib import Path
import argparse,hashlib,json,os,platform,subprocess
HERE=Path(__file__).resolve().parents[1];ROOT=HERE.parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);ap.add_argument('--benchmark',action='store_true');a=ap.parse_args()
a.out.mkdir(parents=True,exist_ok=True);env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH']=':'.join(str(next((tc/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':'+env['PATH'];env['ADHESION_ACTIVATION_BUILD_ROOT']=str(a.out.resolve())
cmd=['gprbuild','-P',str(HERE/('benchmark.gpr' if a.benchmark else 'candidate.gpr')),'-j2']
p=subprocess.run(cmd,env=env,text=True,capture_output=True)
(a.out/'build.log').write_text(p.stdout+p.stderr)
source={str(f.relative_to(ROOT)):hashlib.sha256(f.read_bytes()).hexdigest() for rel in ['src','experimental/smooth/src','experimental/actuation-integration','experimental/frictionless-contact-candidate/src','experimental/collision/src'] for f in (ROOT/rel).rglob('*') if f.is_file() and f.suffix in ['.ads','.adb','.c','.gpr','.py']}
report=dict(command=cmd,exit=p.returncode,platform=platform.platform(),source_sha256=source,project=(HERE/('benchmark.gpr' if a.benchmark else 'candidate.gpr')).read_text(),tools={x:subprocess.check_output([x,'--version'],env=env,text=True).splitlines()[0] for x in ['gcc','gprbuild','gnatprove']})
(a.out/'manifest.json').write_text(json.dumps(report,indent=2));print(p.stdout+p.stderr);raise SystemExit(p.returncode)
