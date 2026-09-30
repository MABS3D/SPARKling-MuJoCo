"""Source provenance restricted to this standalone candidate and dependencies."""
from pathlib import Path
import hashlib,json,os,platform,subprocess
HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def snapshot():
    paths=[ROOT/'src/mj.ads',ROOT/'src/mj-types.ads',ROOT/'tools/guarded.py']
    paths+=list(HERE.glob('*.gpr'))+list((HERE/'src').glob('*.ad?'))
    paths+=[p for p in (HERE/'tests').glob('*') if p.is_file()]
    paths+=[HERE/'results/reference.json']
    reference=json.loads(paths[-1].read_text())
    for rel,wanted in reference['normalized_sha256'].items():
        p=ROOT/'mujoco'/rel
        assert hashlib.sha256(p.read_bytes().replace(b'\r\n',b'\n')).hexdigest()==wanted,rel
        paths.append(p)
    return {str(p.relative_to(ROOT)):digest(p) for p in sorted(paths)}
def tool_env():
    env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=':'.join(str(next((tc/x).glob('*/bin'))) for x in ['gnat','gprbuild','gnatprove'])+':'+env['PATH']
    return env
def provenance(env=None):
    env=env or tool_env()
    info={'platform':platform.platform(),'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0]}
    for tool in ['gcc','gprbuild','gnatprove']:
        p=subprocess.run([tool,'--version'],env=env,capture_output=True,text=True,timeout=10)
        info[tool]=(p.stdout+p.stderr).splitlines()[0]
    return info
