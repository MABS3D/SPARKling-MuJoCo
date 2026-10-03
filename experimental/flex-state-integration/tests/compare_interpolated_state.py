"""Compiled interpolated flex geometry using owned Ada node and vertex poses."""
import tempfile
from pathlib import Path
import xml.etree.ElementTree as ET
import mujoco
import compare

def fixtures():
 for degree,dof in [(1,'trilinear'),(2,'quadratic')]:
  for cells in ['1 1 1','2 1 1','2 2 2']:
   for shape in ['plane','sphere','box']:
    for variant in ['plain','pinned','rotated']:
     bounded_3d=degree==2 and cells=='2 2 2'
     root=ET.fromstring('<mujoco><compiler angle="radian"/><option gravity="0 0 0"><flag island="disable" warmstart="disable"/></option><worldbody/></mujoco>')
     world=root.find('worldbody');parent=world
     if variant=='rotated':parent=ET.SubElement(world,'body',dict(name='parent',pos='.02 -.01 .02',quat='.9950041652780258 0 .09983341664682815 0'))
     # Keep nodal count <= vertex count in the C grid compiler and pin enough
     # nodes to fit the owned core's explicit 256-DOF capacity. The original
     # 375-DOF cases remain recorded as rejected coverage, not passing tests.
     flex=ET.SubElement(parent,'flexcomp',dict(name='volume',type='grid',dim='3',count='6 6 6' if bounded_3d else '4 4 4',spacing='.036 .036 .036' if bounded_3d else '.06 .06 .06',
       pos='0 0 .08',dof=dof,cellcount=cells,mass='1',radius='.012'))
     ET.SubElement(flex,'elasticity',dict(elastic2d='none'))
     ET.SubElement(flex,'contact',dict(selfcollide='none',internal='false',condim='3'))
     if bounded_3d:ET.SubElement(flex,'pin',dict(range='0 41' if variant=='pinned' else '0 40'))
     elif variant=='pinned':ET.SubElement(flex,'pin',dict(id='0'))
     ET.SubElement(world,'geom',dict(type=shape,size='1 1 .1' if shape=='plane' else '.08' if shape=='sphere' else '.08 .08 .08',pos='0 0 -.015' if shape=='plane' else '0 0 -.055'))
     raw=ET.tostring(root,encoding='unicode');model=mujoco.MjModel.from_xml_string(raw)
     if model.flex_interp.tolist()!=[degree]:raise RuntimeError('Fixture did not select positive interpolation')
     # Expand flexcomp once through the official compiler. Removing only the
     # explicit flex from this XML leaves exactly the same nodal bodies/DOFs.
     with tempfile.TemporaryDirectory(prefix='flex-interp-fixture-') as tmp:
      expanded=Path(tmp)/'expanded.xml';mujoco.mj_saveLastXML(str(expanded),model)
      suffix=variant+'_capacity_pinned' if bounded_3d else variant
      yield f'interp{degree}_{cells.replace(" ","x")}_{shape}_{suffix}',expanded.read_text()

if __name__=='__main__':
 compare.fixtures=fixtures
 compare.main()
