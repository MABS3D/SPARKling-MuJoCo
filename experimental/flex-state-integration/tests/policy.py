import argparse,json,pathlib,subprocess,hashlib
def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=pathlib.Path);p.add_argument('--fixtures',required=True,type=pathlib.Path);p.add_argument('--out',required=True,type=pathlib.Path);a=p.parse_args();a.out.mkdir(exist_ok=False,parents=True)
 model=a.fixtures/'dim2_plane.mjb';core=a.fixtures/'dim2_plane-core.mjb';records=[]
 for mode,expected in [('interp','UNSUPPORTED_FEATURE'),('vertexbody','INVALID_MODEL'),('element','INVALID_MODEL'),('radius','INVALID_MODEL'),('dimension','INVALID_MODEL')]:
  r=subprocess.run([str(a.binary),str(model),str(core),'4096',mode],text=True,capture_output=True)
  records.append(dict(mode=mode,passed=r.returncode==0 and r.stdout.strip()=='create '+expected,output=r.stdout+r.stderr))
 # No numerical contact is published if capacity is exceeded, even after a
 # prior group has already filled the internal candidate buffer.
 qvalues='0 0 .03 1 0 0 0 .2 0 .03 1 0 0 0 0 .2 .03 1 0 0 0 '+('0 '*18)
 for cap in [0,1,2]:
  r=subprocess.run([str(a.binary),str(model),str(core),str(cap)],input='1\n'+qvalues+'\n',text=True,capture_output=True)
  records.append(dict(mode='capacity_'+str(cap),passed=r.returncode==0 and 'detect CAPACITY_LIMIT  0' in r.stdout and '\nc ' not in r.stdout,output=r.stdout+r.stderr))
 result=dict(cases=len(records),passed=sum(r['passed'] for r in records),records=records,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest())
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));raise SystemExit(result['passed']!=result['cases'])
if __name__=='__main__':main()
