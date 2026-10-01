"""Isolated native terrain oracle; native crashes cannot abort all fixtures."""
import json,sys
import numpy as np
from pathlib import Path
from check_advanced import model,CUBE
from check_contacts import library
lib=library(Path(sys.argv[1]))
for line in sys.stdin:
    x=json.loads(line);m,d=model('hfield',x['kind'],CUBE)
    m.hfield_data[:]=x['heights'];d.geom_xpos[:]=x['positions'];d.geom_xmat[:]=x['matrices'];r=np.zeros(500)
    n=getattr(lib,'rigid_indexed_terrain_contacts' if x.get('indexed') else 'rigid_contacts')(m._address,d._address,0,1,x['margin'],r)
    print(json.dumps(r[:10*n].reshape(-1,10).tolist()),flush=True)
