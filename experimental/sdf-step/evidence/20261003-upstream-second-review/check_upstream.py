import urllib.request,urllib.parse,json,datetime,hashlib,subprocess
from pathlib import Path
out=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/sdf-step/evidence/20261003-upstream-second-review')
base='https://api.github.com/repos/google-deepmind/mujoco'
def get(url):
 req=urllib.request.Request(url,headers={'User-Agent':'Sparkling-independent-review','Accept':'application/vnd.github+json'})
 with urllib.request.urlopen(req,timeout=30) as r:return r.read()
queries=['repo:google-deepmind/mujoco sdf_initpoints','repo:google-deepmind/mujoco mj_maxContact','repo:google-deepmind/mujoco "pairMaxContact"','repo:google-deepmind/mujoco "MeshSDF"','repo:google-deepmind/mujoco "collision function returned"','repo:google-deepmind/mujoco SDF contacts','repo:google-deepmind/mujoco SDF crash']
summ=[]
for i,q in enumerate(queries):
 url='https://api.github.com/search/issues?'+urllib.parse.urlencode({'q':q,'per_page':100})
 obj=json.loads(get(url));(out/f'search-{i}.json').write_text(json.dumps({'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'url':url,'response':obj},indent=2)+'\n')
 s={'query':q,'total':obj.get('total_count'),'incomplete':obj.get('incomplete_results'),'items':[{'number':x['number'],'title':x['title'],'state':x['state'],'url':x['html_url'],'pr':'pull_request'in x}for x in obj.get('items',[])]};summ.append(s);print(json.dumps(s))
(out/'search-summary.json').write_text(json.dumps(summ,indent=2)+'\n')
refs={'stable':'9ecbb9d7b5ee623f54745638d36799ff90e6f7cd','main':'16dafd8f26835d72d44842b3a5d69c233048a8e7'};audit=[]
for name,sha in refs.items():
 for path in ['src/engine/engine_collision_driver.c','src/engine/engine_collision_sdf.c','CONTRIBUTING.md','doc/computation/index.rst','doc/XMLreference.rst']:
  url=f'https://raw.githubusercontent.com/google-deepmind/mujoco/{sha}/{path}';raw=get(url);dest=out/f'{name}-{Path(path).name}';dest.write_bytes(raw)
  local=subprocess.check_output(['git','show',f'{sha}:{path}'],cwd='/var/tmp/sparkling-upstream-sdf-review-20261003/source')
  audit.append({'ref':name,'sha':sha,'path':path,'url':url,'sha256':hashlib.sha256(raw).hexdigest(),'matches_local_git_object':raw==local})
(out/'upstream-source-audit.json').write_text(json.dumps(audit,indent=2)+'\n');print('source online vs git',sum(x['matches_local_git_object']for x in audit),'/',len(audit))
