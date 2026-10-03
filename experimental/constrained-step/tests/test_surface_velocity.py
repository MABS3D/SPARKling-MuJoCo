"""Surface velocity from owned MJB geometry through full Euler trajectories.

Only the model/state/loads are shared with C; Ada constructs all contacts,
Jacobians, response coefficients and solved forces itself.
"""
import argparse
import sys
from pathlib import Path
import compare


def surface_models():
    for cone in ['pyramidal', 'elliptic']:
        for solver in ['PGS', 'CG', 'Newton']:
            for dim in [1, 3, 4, 6]:
                xml = compare.model_xml(
                    '<body pos=".31 -.23 .095"><joint type="free"/>'
                    '<geom type="sphere" size=".1" mass="1"/></body>',
                    dim=dim, solver=solver)
                xml = xml.replace('cone="pyramidal"', f'cone="{cone}"')
                xml = xml.replace('type="plane" size="2 2 .1"',
                    'type="plane" size="2 2 .1" surfacevel=".45 -.12 .7 .2 -.3 .8"')
                yield f'surface_{cone}_{solver}_{dim}', xml
        for name, surface in [
            ('linear', '.5 -.1 0 0 0 0'),
            ('normal_only', '0 0 .8 0 0 0'),
            ('spin', '0 0 0 0 0 .9'),
            ('angular_tangent', '0 0 0 .6 -.4 0'),
            ('zero', '0 0 0 0 0 0'),
        ]:
            xml = compare.model_xml(
                '<body pos=".27 -.13 .095"><joint type="free"/>'
                '<geom type="box" size=".1 .1 .1" mass="1"/></body>', dim=6)
            xml = xml.replace('cone="pyramidal"', f'cone="{cone}"')
            xml = xml.replace('type="plane" size="2 2 .1"',
                f'type="plane" size="2 2 .1" quat=".7071067811865476 0 0 .7071067811865476" surfacevel="{surface}"')
            yield f'surface_rotated_{cone}_{name}', xml
        # Surface motion on geom2 and on both geoms; their frames move with qpos.
        for name, first, second in [
            ('second', '0 0 0 0 0 0', '.2 -.3 .1 .4 -.2 .7'),
            ('both', '.3 .1 0 -.2 .4 .5', '-.1 -.2 .3 .3 .1 -.4'),
            ('same', '.2 .1 0 0 0 .5', '.2 .1 0 0 0 .5'),
        ]:
            body = f'''<body pos="-.09 0 .4"><joint type="free"/>
              <geom type="sphere" size=".1" mass="1" surfacevel="{first}"/></body>
              <body pos=".09 0 .4"><joint type="free"/>
              <geom type="sphere" size=".1" mass="1" surfacevel="{second}"/></body>'''
            xml = compare.model_xml(body, dim=6, plane=False)
            yield f'surface_pair_{cone}_{name}', xml.replace('cone="pyramidal"', f'cone="{cone}"')
        # Noncontact rows precede the contact cache; excluded and empty contacts.
        body = '''<body pos="0 0 .095">
          <joint type="slide" axis="1 0 0" frictionloss=".1"/>
          <joint type="slide" axis="0 1 0" frictionloss=".2"/>
          <joint type="slide" axis="0 0 1" range="0 .2" margin=".015"/>
          <geom type="sphere" size=".1" mass="1"/></body>'''
        for name, modifier in [('mixed', ''), ('gap', 'margin=".02" gap=".02"')]:
            xml = compare.model_xml(body, dim=3).replace('cone="pyramidal"', f'cone="{cone}"')
            xml = xml.replace('type="plane" size="2 2 .1"',
                f'type="plane" size="2 2 .1" surfacevel=".4 -.2 0 0 0 .7" {modifier}')
            yield f'surface_{cone}_{name}', xml
        xml = compare.model_xml(
            '<body pos="0 0 1"><joint type="free"/>'
            '<geom type="sphere" size=".1" mass="1"/></body>')
        xml = xml.replace('cone="pyramidal"', f'cone="{cone}"')
        yield f'surface_{cone}_no_contacts', xml.replace('type="plane" size="2 2 .1"',
            'type="plane" size="2 2 .1" surfacevel=".4 0 0 0 0 .7"')


if __name__ == '__main__':
    compare.fixtures = surface_models
    compare.main()
