#!/usr/bin/env python3
"""Isolated build; does not use another candidate's object/proof directories."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parents[1]
REPO = HERE.parents[1]

def environment():
    env = os.environ.copy()
    root = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(next((root / tool).glob('*/bin')))
                          for tool in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    return env

def sources():
    files = [REPO/'src/mj.ads', REPO/'src/mj-types.ads'] + list(HERE.glob('*.gpr'))
    files += list((HERE/'src').glob('*.ad?')) + list((HERE/'tests').glob('*.adb'))
    files += list((REPO/'experimental/smooth/src').glob('mj-elastic_*.ad?'))
    files += list((REPO/'experimental/frictionless-contact-candidate/src').glob('mj-contact_rows.ad?'))
    return {str(f.relative_to(REPO)): hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(files)}

def build(out, mode='validation'):
    out = Path(out).resolve(); out.mkdir(parents=True, exist_ok=True)
    env = environment(); env['ELASTIC_CONTACT_BUILD'] = str(out)
    before = sources()
    cmd = ['gprbuild', '-P', str(HERE/'contact.gpr'), '-p', '-j2', '-XELASTIC_CONTACT_MODE='+mode]
    proc = subprocess.run(cmd, env=env, text=True, capture_output=True)
    (out/('build-'+mode+'.log')).write_text(proc.stdout+proc.stderr)
    print(proc.stdout+proc.stderr)
    assert before == sources(), 'source changed during build'
    versions={tool:subprocess.run([tool,'--version'],env=env,text=True,capture_output=True).stdout.splitlines()[0]
              for tool in ('gnatls','gprbuild','gnatprove')}
    (out/('build-'+mode+'.json')).write_text(json.dumps(dict(command=cmd, exit=proc.returncode,
         sources=before,toolchains=versions,project=(HERE/'contact.gpr').read_text()), indent=2)+'\n')
    proc.check_returncode()
    return out/mode/'bin/elastic_contact_probe'

if __name__ == '__main__':
    ap = argparse.ArgumentParser(); ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--mode', choices=['validation', 'release'], default='validation')
    a = ap.parse_args(); print(build(a.out, a.mode))
