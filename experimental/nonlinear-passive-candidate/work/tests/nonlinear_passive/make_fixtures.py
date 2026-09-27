from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'experimental/smooth/tools'))
from compare_numerics import fixtures
import xml.etree.ElementTree as ET
out=Path(__file__).with_name('fixtures')
for name in ['hinge_motor','slide','branched_multijoint','chain_12','disable_spring','disable_damper','disable_eulerdamp']:
 for mode in ['both','pure','signed']:
  tree=ET.fromstring(fixtures()[name])
  for j in tree.findall('.//joint'):
   if 'joint' in j.attrib: continue
   stiffness = '0' if mode == 'pure' else j.get('stiffness', '0')
   damping = '0' if mode == 'pure' else j.get('damping', '0')
   j.set('stiffness', stiffness + (' .3 .7' if mode != 'signed' else ' -.3 .7'))
   j.set('damping', damping + (' .4 .6' if mode != 'signed' else ' -.05 .6'))
  (out/f'nonlinear_{name}_{mode}.xml').write_text(ET.tostring(tree,encoding='unicode')+'\n')
