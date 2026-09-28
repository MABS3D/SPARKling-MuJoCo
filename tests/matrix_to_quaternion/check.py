#!/usr/bin/env python3
"""Freeze sources; prove small subprograms then complete units; compare with C.

All generated builds/reports stay under --out. Resume a phase only while the
source manifest still matches. Timing is a kernel diagnostic, not a dynamics
performance claim. See README.md for the exact proof and numerical scope.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import resource
import shutil
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE.parent / "quaternions"))
from reference import validate


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--toolchain-root", type=Path)
    ap.add_argument("--phase", choices=["all","small","proof","numeric","performance"], default="all")
    ap.add_argument("--cpu", type=int, default=12)
    args = ap.parse_args()
    validate()
    env = os.environ.copy()
    if args.toolchain_root:
        bins = [str(sorted((args.toolchain_root/t).glob(t+"-*/bin"))[-1])
                for t in ("gnat","gprbuild","gnatprove")]
        env["PATH"] = ":".join(bins)+":"+env.get("PATH","")
    resource.setrlimit(resource.RLIMIT_STACK, (64*1024*1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    snapshot = out / "snapshot"
    files = [ROOT/"sparkling_mujoco.gpr", ROOT/"tools/guarded.py", ROOT/"tools/prove_report.py"]
    for stem in ("mj","mj-types","mj-blas","mj-vector_models","mj-matrix_types","mj-matrices","mj-matrix_models",
                 "mj-quaternion_math","mj-quaternions","mj-rotations","mj-poses"):
        files += [p for suffix in (".ads",".adb") if (p:=ROOT/"src"/(stem+suffix)).exists()]
    for folder in ("quaternions","poses","matrix_to_quaternion"):
        files += [p for p in (ROOT/"tests"/folder).iterdir()
                  if p.is_file() and p.suffix in (".ads",".adb",".c",".gpr",".py",".json")]
    reference = json.loads((ROOT/"tests/quaternions/reference.json").read_text())
    files += [ROOT/"mujoco"/p for p in reference["normalized_sha256"]]
    hashes = {str(p.relative_to(ROOT)):digest(p) for p in sorted(set(files))}
    manifest = out/"source-manifest.json"
    if manifest.exists():
        if json.loads(manifest.read_text()) != hashes:
            raise RuntimeError("Sources changed: choose a fresh output directory")
    else:
        for p in files:
            dest = snapshot/p.relative_to(ROOT)
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(p,dest)
        if hashes != {str(p.relative_to(ROOT)):digest(p) for p in sorted(set(files))}:
            raise RuntimeError("Sources changed while freezing")
        manifest.write_text(json.dumps(hashes,indent=2)+"\n")
    if hashes != {p:digest(snapshot/p) for p in hashes}:
        raise RuntimeError("Frozen sources changed")
    logs = out/"logs"
    logs.mkdir(exist_ok=True)
    commands = []
    def run(name,cmd,cap=None):
        if cap:
            cmd = [sys.executable,"tools/guarded.py","--cap-mb","3800","--timeout",str(cap),"--",*cmd]
        started = time.time()
        clock_start = time.monotonic()
        with (logs/(name+".log")).open("w") as log:
            result = subprocess.run(cmd,cwd=snapshot,env=env,stdout=log,stderr=subprocess.STDOUT)
        elapsed = time.monotonic()-clock_start
        commands.append(dict(name=name,command=cmd,started=started,seconds=elapsed,code=result.returncode))
        (out/("commands-"+args.phase+".json")).write_text(json.dumps(commands,indent=2)+"\n")
        print(name,result.returncode,round(elapsed,1),flush=True)
        if result.returncode:
            print((logs/(name+".log")).read_text()[-8000:])
            raise RuntimeError("Failed: "+name)
        return started
    if args.phase in ("all","small","proof"):
        project = snapshot/"tests/matrix_to_quaternion/proof.gpr"
        project.write_text('''project Proof is
 for Source_Dirs use ("../../src");
 for Object_Dir use "build/obj/proof";
 for Create_Missing_Dirs use "True";
 package Compiler is
  for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off");
 end Compiler;
end Proof;
''')
        cmd = ["gnatprove","-P",str(project),"--prover=cvc5,z3,altergo","--timeout=30",
               "--steps=0","--proof=per_check","-j2","--checks-as-errors=on",
               "--warnings=continue","--report=all","--counterexamples=off"]
        directory = project.parent/"build/obj/proof/gnatprove"
        if args.phase in ("all","small"):
            targets = {
                "mj-quaternions.ads": ["Matrix_Branch","Matrix_Radicand","Matrix_Pivot",
                    "Matrix_Conversion_Safe","Matrix_Quotient","Matrix_Raw","Normalization_Length",
                    "Normalized_Component","Normalized"],
                "mj-quaternions.adb": ["Select_Matrix_Branch","Conversion_Radicand",
                    "Conversion_Quotient","Convert_Raw","Conversion_Length","Normalize_Conversion",
                    "Equal_Normalization","From_Matrix"]}
            for file,names in targets.items():
                lines = (snapshot/"src"/file).read_text().splitlines()
                for name in names:
                    line = next(i for i,s in enumerate(lines,1)
                                if "function "+name+" (" in s or "procedure "+name+" (" in s)
                    run("small-"+name,cmd+["-u",file,f"--limit-subp={file}:{line}"],300)
                    shutil.copyfile(directory/"mj-quaternions.spark",logs/("small-"+name+".spark"))
        if args.phase in ("all","proof"):
            spec = importlib.util.spec_from_file_location("gate",snapshot/"tools/prove_report.py")
            gate = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(gate)
            for unit in ("mj-quaternions","mj-poses","mj-rotations"):
                for old in directory.glob("*.spark"):
                    old.unlink()
                command = cmd+["-u",unit+".ads"]
                started = run("whole-"+unit,command,1200)
                gate.record_invocation(directory,unit,started,gate.source_hashes(),command)
                run("gate-"+unit,[sys.executable,"tools/prove_report.py","--unit",unit,
                    "--mode","proof","--build-root",str(project.parent/"build"),"--since",str(started),"-v"])
                for suffix in (".spark",".invocation.json"):
                    shutil.copyfile(directory/(unit+suffix),logs/(unit+suffix))
    if args.phase in ("all","numeric"):
        for mode in ("development","validation","release"):
            for suite,var in (("matrix_to_quaternion","MATQUAT_MODE"),("quaternions","QUATERNION_MODE"),("poses","POSE_MODE")):
                run("build-"+suite+"-"+mode,["gprbuild","-P",f"tests/{suite}/checks.gpr",f"-X{var}={mode}","-p","-j2"],180)
                run("numeric-"+suite+"-"+mode,[sys.executable,f"tests/{suite}/numeric.py","--mode",mode],180)
    if args.phase in ("all","performance"):
        run("build-release",["gprbuild","-P","tests/matrix_to_quaternion/checks.gpr","-XMATQUAT_MODE=release","-p","-j2"],180)
        for session in (1,2):
            (out/f"host-session{session}.txt").write_text(subprocess.check_output(
                ["ps","-eo","pid,etime,comm,args"],text=True)+"\nloadavg: "+Path("/proc/loadavg").read_text())
            run(f"performance-{session}",[sys.executable,"tests/matrix_to_quaternion/measure.py",
                "--pairs","21","--ms","15","--cpu",str(args.cpu),"--output",str(out/f"performance-{session}.json")],180)
    if hashes != {p:digest(snapshot/p) for p in hashes}:
        raise RuntimeError("Sources changed during run")


if __name__ == "__main__":
    main()
