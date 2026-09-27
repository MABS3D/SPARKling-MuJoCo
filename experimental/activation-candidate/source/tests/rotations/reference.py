"""Validate the pinned C reference, ignoring checkout line-ending conversion."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent

def validate():
    receipt=json.loads((HERE/'reference.json').read_text())
    root=HERE.parent.parent/'mujoco'
    for relative,expected in receipt['normalized_sha256'].items():
        actual=hashlib.sha256((root/relative).read_text().encode()).hexdigest()
        if actual!=expected:raise RuntimeError(f'MuJoCo reference changed: {relative}; review the reference pin and receipts')
    return receipt['commit']

if __name__=='__main__':print(validate())
