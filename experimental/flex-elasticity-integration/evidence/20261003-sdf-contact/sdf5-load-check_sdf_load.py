"""Exercise the SDF geometry admission independently of any dynamics step."""
import argparse, hashlib, json, resource, subprocess
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    command=[str(a.binary.resolve()),str(a.model.resolve()),'load-checks']
    run=subprocess.run(command,capture_output=True,text=True,timeout=30)
    (a.out/'output.txt').write_text(run.stdout+run.stderr)
    passed=run.returncode==0 and run.stdout.strip()=='load_checks 30'
    result=dict(passed=passed,exit=run.returncode,checks=30 if passed else None,command=command,
        stack_bytes=128*1024*1024,source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        model_sha256=hashlib.sha256(a.model.read_bytes()).hexdigest(),
        limits='Finite adversarial/lifecycle tests, not a proof of Load for all inputs.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result));raise SystemExit(not passed)

if __name__=='__main__':main()
