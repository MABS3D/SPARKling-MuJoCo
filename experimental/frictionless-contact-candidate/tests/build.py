#!/usr/bin/env python3
from pathlib import Path
import argparse,json,os,subprocess
from evidence import HERE,snapshot,provenance
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);ap.add_argument('--mode',choices=['development','validation','release','benchmark'],default='validation');ap.add_argument('--toolchain-root',type=Path,default=Path('/var/tmp/sparkling-matrix-recovery/toolchains'));args=ap.parse_args()
source_hashes=snapshot()
out=args.out.resolve();out.mkdir(parents=True,exist_ok=True);env=os.environ.copy()
env['PATH']=':'.join(str(next((args.toolchain_root/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':'+env['PATH']
env['CONTACT_BUILD_ROOT']=str(out)
cmd=['gprbuild','-P',str(HERE/('benchmark.gpr' if args.mode=='benchmark' else 'contact.gpr')),'-p','-f','-j2']
if args.mode!='benchmark':cmd+=['-XCONTACT_MODE='+args.mode]
r=subprocess.run(cmd,env=env,capture_output=True,text=True)
(out/('build-'+args.mode+'.log')).write_text(r.stdout+r.stderr)
(out/('build-'+args.mode+'.json')).write_text(json.dumps({'command':cmd,'exit':r.returncode,'toolchain_root':str(args.toolchain_root),'build_root':str(out),'sources':source_hashes,'environment':provenance(env)},indent=2)+'\n')
assert source_hashes==snapshot(),'source changed during build'
print(r.stdout+r.stderr);raise SystemExit(r.returncode)
