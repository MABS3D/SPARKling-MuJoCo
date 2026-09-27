"""Fixed-tendon numerical and integrated movement cases, pinned to MuJoCo 3.14."""
from pathlib import Path

def fixture(n=6, topology='chain', nonlinear=False, armature=.2, flag='', duplicate=False, include_tendons=True):
    inertia='<inertial pos=".1 .02 -.03" mass="1.5" diaginertia=".2 .3 .4"/>'
    bodies=[]
    for i in range(n):
        joint=f'<joint name="j{i}" type="{("hinge" if i%2 else "slide")}" axis="1 2 3" damping=".1" stiffness=".2" armature=".05"/>'
        bodies.append(f'<body pos=".13 -.07 .2">{joint}{inertia}')
    body=''.join(bodies)+('</body>'*n) if topology=='chain' else ''.join(x+'</body>' for x in bodies)
    tendons=[]
    for t in range(max(1,n//2) if include_tendons else 0):
        terms=''.join(f'<joint joint="j{i}" coef="{(-1 if i%2 else 1)*(.4+.1*t)}"/>' for i in range(t,n))
        if duplicate: terms += '<joint joint="j0" coef="-.125"/>'
        law='stiffness="2 .03 .002" damping=".2 .02 .001"' if nonlinear else 'stiffness="2" damping=".2"'
        tendons.append(f'<fixed name="t{t}" {law} armature="{armature}" springlength="-.1 .2">{terms}</fixed>')
    return f'''<mujoco><compiler angle="radian"/>
<option timestep=".001" integrator="Euler"><flag constraint="disable" {flag}/></option>
<worldbody>{body}</worldbody><tendon>{''.join(tendons)}</tendon>
<actuator><motor joint="j0" gear="-.7"/></actuator></mujoco>'''

def generate(out):
    out.mkdir(parents=True,exist_ok=True)
    cases={
        'tendon_scalar': fixture(n=1),
        'tendon_chain_6': fixture(),
        'tendon_branches_6': fixture(topology='branches'),
        'tendon_nonlinear': fixture(nonlinear=True),
        'tendon_no_armature': fixture(armature=0),
        'tendon_duplicates': fixture(duplicate=True),
        'tendon_chain_24': fixture(n=24),
        # Spring and damper individually exceed the fast-projection envelope.
        # Matching qvel=-qpos makes their C contributions cancel exactly.
        'tendon_large_cancellation': '''<mujoco><compiler angle="radian"/>
<option timestep="1e-24" gravity="0 0 0"><flag constraint="disable"/></option>
<worldbody><body><joint name="j" type="slide" ref="6e9"/>
<inertial pos="0 0 0" mass="1" diaginertia="1 1 1"/></body></worldbody>
<tendon><fixed stiffness="0 0 10" damping="0 0 10" springlength="0">
<joint joint="j" coef="1"/></fixed></tendon></mujoco>''',
        'tendon_coefficient_cancellation': '''<mujoco>
<option gravity="0 0 0"><flag constraint="disable"/></option>
<worldbody><body><joint name="j" type="slide"/>
<inertial pos="0 0 0" mass="1e10" diaginertia="1 1 1"/></body></worldbody>
<tendon><fixed><joint joint="j" coef="9e9"/><joint joint="j" coef="9e9"/>
<joint joint="j" coef="-9e9"/></fixed></tendon></mujoco>''',
    }
    for flag in ['spring','damper','eulerdamp']:
        cases['tendon_disable_'+flag]=fixture(nonlinear=True,flag=f'{flag}="disable"')
    for name, xml in cases.items(): (out/(name+'.xml')).write_text(xml+'\n')

if __name__=='__main__':
    generate(Path(__file__).parent/'fixtures')
    controls=Path(__file__).parent/'performance-fixtures'; controls.mkdir(exist_ok=True)
    (controls/'chain_24_without_tendons.xml').write_text(fixture(n=24,include_tendons=False)+'\n')
