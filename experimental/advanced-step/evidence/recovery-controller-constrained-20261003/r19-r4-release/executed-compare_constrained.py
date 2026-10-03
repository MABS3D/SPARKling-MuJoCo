"""Advanced controllers composed with native constraints, using the C oracle."""
import argparse
import hashlib
import json
import sys
from pathlib import Path
import xml.etree.ElementTree as ET
import compare as base

original_fixtures=base.fixtures
parser=argparse.ArgumentParser(add_help=False)
parser.add_argument('--solver',choices=['PGS','CG','Newton'],default='Newton')
parser.add_argument('--cone',choices=['pyramidal','elliptic'],default='pyramidal')
parser.add_argument('--jacobian',choices=['auto','dense','sparse'],default='auto')
parser.add_argument('--contact-mobility',choices=['fixed-anchor','free-carrier'],default='fixed-anchor')
choices,remaining=parser.parse_known_args()
sys.argv=[sys.argv[0],*remaining]


def constrained(source):
    root=ET.fromstring(source)
    opt=root.find('option');opt.set('solver',choices.solver);opt.set('cone',choices.cone)
    opt.set('jacobian',choices.jacobian)
    flag=opt.find('flag')
    flag.set('constraint','enable');flag.set('warmstart','disable');flag.set('island','disable')
    for j in root.findall('.//joint'):
        # Restrict only actual body joints; actuator/equality/tendon references
        # use other attributes and must retain their compiled semantics.
        if 'name' not in j.attrib:continue
        kind=j.get('type','hinge')
        j.set('limited','true');j.set('frictionloss','.002')
        j.set('range','0 1.5' if kind=='ball' else '-.015 .015' if kind=='slide' else '-1 1')
    world=root.find('worldbody')
    if choices.contact_mobility == 'free-carrier':
        # Retain the fixed-anchor corpus separately: its penetrated ball joints
        # cannot translate away from the plane and expose extreme solver loads.
        # This additional corpus gives each controlled tree a physical base
        # with positive inertia and translational freedom at the contact.
        for i,body in enumerate(list(world.findall('body'))):
            if body.find('.//joint') is None:continue
            world.remove(body)
            carrier=ET.SubElement(world,'body',name='carrier_'+str(i))
            ET.SubElement(carrier,'freejoint')
            ET.SubElement(carrier,'inertial',pos='0 0 0',mass='.05',diaginertia='.0002 .0002 .0002')
            carrier.append(body)
    ET.SubElement(world,'geom',name='controller_floor',type='plane',size='3 3 .1',
        pos='0 0 -.095',friction='.6 .01 .001',condim='3')
    return ET.tostring(root,encoding='unicode')


def extra_fixtures():
    # Tendon metric/passive/limits and equality share the same DOFs as control.
    for controller,actuator in [
        ('pid','<pid joint="j" kp="3" kv=".3" ki=".4" input="pos vel ff"/>'),
        ('dc','<dcmotor joint="j" motorconst=".2" resistance="2" input="voltage" inductance="0 .02"/>')]:
        bodies='<body name="a" pos="-.2 0 0"><joint name="j"/><geom size=".1" mass="1"/></body><body name="b" pos=".2 0 0"><joint name="j2"/><geom size=".1" mass="1"/></body>'
        root=ET.fromstring(base.model(actuator,bodies))
        tendon=ET.SubElement(root,'tendon')
        fixed=ET.SubElement(tendon,'fixed',name='t',stiffness='.3',damping='.04',springlength='.01',
            frictionloss='.001',limited='true',range='-.04 .04')
        ET.SubElement(fixed,'joint',joint='j',coef='1');ET.SubElement(fixed,'joint',joint='j2',coef='-.5')
        equality=ET.SubElement(root,'equality')
        ET.SubElement(equality,'joint',joint1='j',joint2='j2',polycoef='0 1 0 0 0')
        yield 'combo_'+controller+'_joint_tendon',ET.tostring(root,encoding='unicode')
    for equality in ['connect','weld']:
        bodies='<body name="a"><joint name="j" type="ball"/><geom pos=".12 0 0" size=".1" mass="1"/></body><body name="ref" pos=".25 0 0"/>'
        root=ET.fromstring(base.model('<orientation joint="j" kp="3" kv=".2" input="vel"/>',bodies))
        eq=ET.SubElement(root,'equality')
        attrs=dict(body1='a',body2='ref')
        if equality=='connect':attrs['anchor']='.12 0 0'
        ET.SubElement(eq,equality,**attrs)
        yield 'combo_so3_'+equality,ET.tostring(root,encoding='unicode')


def fixtures():
    for name,source in original_fixtures():yield name,constrained(source)
    for name,source in extra_fixtures():yield name,constrained(source)

base.fixtures=fixtures
try:
    base.main()
finally:
    # The underlying comparison retains identical numerical tolerances.
    args=argparse.ArgumentParser(add_help=False);args.add_argument('--out',type=Path)
    parsed,_=args.parse_known_args()
    if parsed.out and (parsed.out/'results.json').exists():
        p=parsed.out/'results.json';d=json.loads(p.read_text())
        d['constraint_profile']=vars(choices)
        d['driver_hashes']={str(f):hashlib.sha256(f.read_bytes()).hexdigest()
            for f in [Path(__file__),Path(base.__file__)]}
        p.write_text(json.dumps(d,indent=2)+'\n')
