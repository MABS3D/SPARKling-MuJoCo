"""Shared and distinct meshes; raw/count graphs and scanning/indexed clipping."""
import argparse,json,subprocess
from pathlib import Path
import numpy as np
from benchmark_meshes import clouds
from check import rotation
from check_advanced import model,mesh_asset,mesh_graph
from check_contacts import library,serialize_objects,match


def run(out):
    rng=np.random.default_rng(3141511);lib=library(out)
    batches={'validation':([],[],[]),'release':([],[],[])}
    for family,cloud in clouds():
        small=len(cloud)<=48
        for distinct in [False,True]:
            m,d=model('mesh','mesh',cloud,cloud*np.array([1.13,.84,1.06]) if distinct else None)
            vertices=[];facets=[];graphs=[];seeds=[]
            for g in [0,1]:
                v,f=mesh_asset(m,g);gr,se=mesh_graph(m,g)
                vertices.append(v);facets.append(f);graphs.append(gr);seeds.append(se)
            for i in range(25 if small else 8):
                pos=rng.uniform(-1.6,1.6,(2,3));mats=np.stack([rotation(rng),rotation(rng)])
                if i%5==0:pos[:]=0;pos[1]=[.03,.02,.04];mats[:]=np.eye(3).reshape(9)
                margin=float(rng.choice([0.,0.,.005,.1]));d.geom_xpos[:]=pos;d.geom_xmat[:]=mats
                for reversed_pair in [False,True]:
                    order=[1,0] if reversed_pair else [0,1]
                    result=np.zeros(500);n=lib.rigid_contacts(m._address,d._address,*order,margin,result)
                    expected=result[:10*n].reshape(-1,10).copy()
                    for mode in [0,7,9,10]:
                        for shared in ([False] if distinct else [False,True]):
                            text=serialize_objects(['mesh','mesh'],m.geom_size[order],pos[order],mats[order],
                                vertices=[vertices[g] for g in order],facets=[facets[g] for g in order],
                                graphs=[graphs[g] for g in order],seeds=[seeds[g] for g in order],
                                margin=margin,mode=mode,shared_mesh=shared)
                            desc=dict(family=family,distinct=distinct,sample=i,reversed=reversed_pair,shared=shared,mode=mode)
                            for profile in ['release']+(['validation'] if small else []):
                                batches[profile][0].append(text);batches[profile][1].append(expected);batches[profile][2].append(desc)
    reports={}
    for profile,(texts,wants,descs) in batches.items():
        r=subprocess.run([str(out/'build'/profile/'bin/contact_probe')],input=''.join(texts),text=True,capture_output=True,timeout=600)
        lines=r.stdout.splitlines();failures=[];coverage={}
        for i,(want,desc) in enumerate(zip(wants,descs)):
            coverage[desc['family']]=coverage.get(desc['family'],0)+1
            fields=lines[i].split() if i<len(lines) else []
            if not fields or fields[0]!='SUCCESS':err=dict(reason='status',fields=fields)
            else:
                actual=np.asarray(fields[2:],float).reshape(-1,10);err=match(actual,want)
                if len(actual)!=int(fields[1]):err=dict(reason='protocol')
            if err:failures.append(dict(index=i,**desc,**err,input=texts[i]))
        reports[profile]=dict(cases=len(wants),output_count=len(lines),returncode=r.returncode,stderr=r.stderr,
                              coverage=coverage,failures=failures,
                              note='Large hull cases run in release; checked coverage is the three small-hull families.')
        (out/('mesh-pairs-'+profile+'-input.txt')).write_text(''.join(texts))
        print(profile,'mesh pair variants',len(wants),'failures',len(failures),flush=True)
    (out/'mesh-pairs-numerics.json').write_text(json.dumps(reports,indent=2)+'\n')
    return all(not r['returncode'] and not r['failures'] and r['cases']==r['output_count'] for r in reports.values())

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    raise SystemExit(0 if run(a.out.resolve()) else 1)
