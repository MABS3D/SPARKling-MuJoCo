"""Read-only provenance shared by the candidate verification runners."""
from pathlib import Path
import hashlib,json,os,platform,subprocess
HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def snapshot():
    paths=[ROOT/'src/mj.ads',ROOT/'src/mj-types.ads',ROOT/'tools/guarded.py']
    paths += list((ROOT/'experimental/collision/src').glob('*.ad?'))
    paths += list(HERE.glob('*.gpr'))
    paths += list((HERE/'src').glob('*.ad?'))
    paths += [p for p in (HERE/'tests').glob('*') if p.is_file()]
    paths += [HERE/'results/reference.json']
    reference=json.loads((HERE/'results/reference.json').read_text())
    for rel,wanted in reference['normalized_sha256'].items():
        p=ROOT/'mujoco'/rel
        assert hashlib.sha256(p.read_bytes().replace(b'\r\n',b'\n')).hexdigest()==wanted,rel
        paths.append(p)
    return {str(p.relative_to(ROOT)):digest(p) for p in sorted(paths)}
def provenance(env=None):
    env=env or os.environ
    info={'platform':platform.platform(),'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0]}
    for tool in ['gcc','gprbuild','gnatprove']:
        try:
            p=subprocess.run([tool,'--version'],env=env,capture_output=True,text=True,timeout=10)
            info[tool]=(p.stdout+p.stderr).splitlines()[0]
        except FileNotFoundError:
            info[tool]='not on PATH'
    return info
