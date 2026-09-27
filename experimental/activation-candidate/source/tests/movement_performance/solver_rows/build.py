#!/usr/bin/env python3
"""Use the dynamics builder with the pre-vector-row source baseline."""
import importlib.util
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('dynamics_build',
    HERE.parent/'dynamics_optimization/build.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
builder.HERE = HERE
if __name__ == '__main__':
    builder.main()
