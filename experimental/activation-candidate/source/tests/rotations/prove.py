#!/usr/bin/env python3
"""Whole-unit proof with the repository's freshness and coverage gate."""
from pathlib import Path
import hashlib, importlib.util, json, shutil, subprocess, sys, time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
spec=importlib.util.spec_from_file_location('prove_report',ROOT/'tools/prove_report.py')
report=importlib.util.module_from_spec(spec);spec.loader.exec_module(report)

def main():
    directory=HERE/'build/obj/proof/gnatprove'
    directory.mkdir(parents=True,exist_ok=True)
    started=time.time();sources=report.source_hashes()
    project=HERE/'proof.gpr';project_hash=hashlib.sha256(project.read_bytes()).hexdigest()
    # Remove partial/stale reports, retaining only reusable prover sessions.
    for pattern in ('*.spark','*.invocation.json'):
        for old in directory.glob(pattern):old.unlink()
    command=['gnatprove','-P',str(project),'-u','mj-rotations.ads','--level=2',
             '--proof=per_check','--timeout=30','-j2','--checks-as-errors=on',
             '--warnings=continue','--report=all','--counterexamples=off']
    result=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','4000',
                           '--timeout','1200','--',*command],cwd=ROOT)
    if result.returncode:return result.returncode
    if sources!=report.source_hashes() or project_hash!=hashlib.sha256(project.read_bytes()).hexdigest():
        raise RuntimeError('Sources changed during proof; rerun on a stable snapshot')
    report.record_invocation(directory,'mj-rotations',started,sources,command)
    result=report.main(['--unit','mj-rotations','--mode','proof','--build-root',str(HERE/'build'),'--since',str(started),'-v'])
    if result:return result
    receipt={'started':started,'command':command,'source_sha256':sources,
             'project_sha256':project_hash,'report_sha256':hashlib.sha256((directory/'mj-rotations.spark').read_bytes()).hexdigest()}
    (HERE/'build/proof-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return 0

if __name__=='__main__':sys.exit(main())
