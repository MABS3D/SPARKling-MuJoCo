#!/usr/bin/env python3
"""Owned joint/tendon equality assembly and trajectories; no native row input."""
from compare_scalar import models
import compare_step


def fixtures():
    for name, kind, second, xml in models():
        xml = xml.replace('island="disable"', 'island="disable" warmstart="disable"')
        for solver in ['PGS', 'CG', 'Newton']:
            base = xml.replace('<option ', f'<option solver="{solver}" timestep=".001" iterations="200" tolerance="1e-12" ')
            yield solver+'-'+name+'-quartic', base
            yield solver+'-'+name+'-linear', base.replace('polycoef=".1 .8 .2 -.1 .05"', 'polycoef="0 1 0 0 0"')
            yield solver+'-'+name+'-constant', base.replace('polycoef=".1 .8 .2 -.1 .05"', 'polycoef="-.05 0 0 0 0"')
        base = xml.replace('<option ', '<option solver="Newton" timestep=".001" iterations="200" tolerance="1e-12" ')
        yield name+'-inactive', base.replace('polycoef=', 'active="false" polycoef=')
        yield name+'-disabled-equality', base.replace('warmstart="disable"', 'warmstart="disable" equality="disable"')
        yield name+'-disabled-passive', base.replace('warmstart="disable"', 'warmstart="disable" spring="disable" damper="disable"')
        # Two equality rows exercise object sharing and regularization together.
        eq = base.split('<equality>', 1)[1].split('</equality>', 1)[0]
        yield name+'-two-rows', base.replace('</equality>', eq+'</equality>')
    for name, kind, second, xml in models():
        # Preserve the original corpus and random sequence above, then exercise
        # scalar rows together with joint friction, a limit and plane contacts.
        xml = xml.replace('contact="disable" ', '')
        xml = xml.replace('island="disable"', 'island="disable" warmstart="disable"')
        xml = xml.replace('<worldbody>', '<worldbody><geom type="plane" pos="0 0 .455" size="2 2 .1"/>')
        xml = xml.replace('name="j0" type="hinge"', 'name="j0" frictionloss=".02" type="hinge"')
        xml = xml.replace('name="j1" type="slide" axis="1 0 0"',
                          'name="j1" type="slide" axis="1 0 1" limited="true" range="-.09 .1"')
        for solver in ['PGS', 'CG', 'Newton']:
            yield solver+'-'+name+'-mixed', xml.replace(
                '<option ', f'<option solver="{solver}" timestep=".001" iterations="200" tolerance="1e-12" ')


if __name__ == '__main__':
    compare_step.fixtures = fixtures
    compare_step.main()
