"""Compiled shell geometry: official negative orders, owned FS state and contacts."""
import ctypes as ct
from pathlib import Path
import sys
import tempfile
import xml.etree.ElementTree as ET

import mujoco
import numpy as np
import compare

LIBRARY = Path(mujoco.__file__).parent / 'libmujoco.so.3.14.0'
LIB = ct.CDLL(str(LIBRARY))
LIB.mju_shellTrackInterior.argtypes = [np.ctypeslib.ndpointer(dtype=np.float64,
    flags='C_CONTIGUOUS')] + [ct.c_int] * 3
LIB.mju_shellTrackInterior.restype = None
ORACLE = compare.oracle


def oracle(m, q, v):
    result = ORACLE(m, q, v)
    for f in range(m.nflex):
        degree = int(m.flex_interp[f])
        if degree >= 0:
            continue
        count = int(m.flex_nodenum[f])
        nodes = np.array([result['nodes'][(f, n)][1] for n in range(count)])
        grid = m.flex_cellnum[f] * abs(degree) + 1
        LIB.mju_shellTrackInterior(nodes, *map(int, grid))
        for n in range(count):
            result['nodes'][(f, n)] = (result['nodes'][(f, n)][0], nodes[n].copy())
    return result


def fixture_names():
    for degree, cells in ((1, '1 1 1'), (1, '2 2 2'), (2, '1 1 1'), (2, '2 1 2')):
        for shape in ('plane', 'sphere', 'box'):
            for variant in ('plain', 'pinned', 'rotated', 'mixed'):
                yield f'shell{degree}_{cells.replace(" ", "x")}_{shape}_{variant}', degree, cells, shape, variant


def fixtures():
    only = sys.argv[sys.argv.index('--only') + 1] if '--only' in sys.argv else None
    for name, degree, cells, shape, variant in fixture_names():
        if only and only not in name:
            continue
        root = ET.fromstring('<mujoco><compiler angle="radian"/>'
            '<option gravity="0 0 0"><flag island="disable" warmstart="disable"/></option>'
            '<worldbody/></mujoco>')
        world = root.find('worldbody')
        parent = world
        if variant == 'rotated':
            parent = ET.SubElement(world, 'body', dict(name='parent', pos='.02 -.01 .02',
                quat='.9950041652780258 0 .09983341664682815 0'))
        flex = ET.SubElement(parent, 'flexcomp', dict(name='shell', type='grid', dim='3',
            count='6 6 6', spacing='.036 .036 .036', pos='0 0 .08',
            dof='trilinear' if degree == 1 else 'quadratic', cellcount=cells, mass='1', radius='.012'))
        ET.SubElement(flex, 'elasticity', dict(elastic2d='bend', young='0', thickness='.02'))
        ET.SubElement(flex, 'contact', dict(selfcollide='none', internal='false', condim='3'))
        if variant == 'pinned':
            ET.SubElement(flex, 'pin', dict(id='0'))
        ET.SubElement(world, 'geom', dict(type=shape,
            size='1 1 .1' if shape == 'plane' else '.08' if shape == 'sphere' else '.08 .08 .08',
            pos='0 0 -.015' if shape == 'plane' else '0 0 -.055'))
        if variant == 'mixed':
            ordinary = ET.SubElement(world, 'flexcomp', dict(name='ordinary', type='grid', dim='2',
                count='2 2 1', spacing='.08 .08 .08', pos='.5 0 .01', dof='full', mass='.1', radius='.012'))
            ET.SubElement(ordinary, 'contact', dict(selfcollide='none', internal='false'))
        raw = ET.tostring(root, encoding='unicode')
        output = Path(sys.argv[sys.argv.index('--out') + 1])
        (output / (name + '.requested.xml')).write_text(raw)
        model = mujoco.MjModel.from_xml_string(raw)
        if int(model.flex_interp[0]) != -degree or model.nv > 256:
            raise RuntimeError(f'Fixture wrong negative order or exceeds core capacity: {name}')
        with tempfile.TemporaryDirectory(prefix='flex-shell-fixture-') as tmp:
            expanded = Path(tmp) / 'expanded.xml'
            mujoco.mj_saveLastXML(str(expanded), model)
            yield name, expanded.read_text()


if __name__ == '__main__':
    compare.fixtures = fixtures
    compare.oracle = oracle
    compare.main()
