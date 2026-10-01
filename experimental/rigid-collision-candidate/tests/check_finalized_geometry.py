"""Check geometry -> complete-contact API integration on frozen inputs.

Compare with the separately exercised geometric path, and construct its
frame oracle using official C vector operations in makeFrame's order.
This is not an additional claim of
geometry equivalence to C: the differential reports remain authoritative.
"""
import argparse,ctypes,json,subprocess
from pathlib import Path
import mujoco,numpy as np

def run(out,inputs):
    native=ctypes.CDLL(str(Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'))
    vector=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')
    native.mju_normalize3.argtypes=[vector];native.mju_normalize3.restype=ctypes.c_double
    native.mju_dot3.argtypes=[vector,vector];native.mju_dot3.restype=ctypes.c_double
    native.mju_scl3.argtypes=[vector,vector,ctypes.c_double]
    native.mju_subFrom3.argtypes=[vector,vector];native.mju_cross.argtypes=[vector,vector,vector]
    def make_frame(frame):
        native.mju_normalize3(frame[:3]);t=frame[3:6]
        if native.mju_dot3(t,t)<.25:
            t[:]=0;t[1 if -.5<frame[1]<.5 else 2]=1
        tmp=np.zeros(3);native.mju_scl3(tmp,frame[:3],native.mju_dot3(frame[:3],t))
        native.mju_subFrom3(t,tmp);native.mju_normalize3(t);native.mju_cross(frame[6:],frame[:3],t)
    reports={}
    for profile in ['validation','release']:
        groups=[]
        for path in inputs:
            raw=path.read_text().splitlines();full=[]
            for text in raw:
                mode,tail=text.split(' ',1);full.append(('6' if mode=='3' else '5')+' '+tail)
            exe=str(out/'build'/profile/'bin/contact_probe')
            a=subprocess.run([exe],input='\n'.join(raw)+'\n',text=True,capture_output=True,timeout=240)
            b=subprocess.run([exe],input='\n'.join(full)+'\n',text=True,capture_output=True,timeout=240)
            left=a.stdout.splitlines();right=b.stdout.splitlines();failures=[]
            for i,text in enumerate(raw):
                if i>=len(left) or i>=len(right):failures.append(dict(index=i,reason='missing'));continue
                p=left[i].split();f=right[i].split()
                if p[0]!='SUCCESS' or f[0]!='SUCCESS':failures.append(dict(index=i,reason='status',raw=p[:2],full=f[:2]));continue
                if p[1]!=f[1]:failures.append(dict(index=i,reason='count',raw=p[1],full=f[1]));continue
                pre=np.array(list(map(float,p[2:]))).reshape(-1,10);actual=np.array(list(map(float,f[2:]))).reshape(-1,71);want=[]
                margin=float(text.split()[2])
                for row in pre:
                    frame=np.r_[row[4:7],row[7:10],np.zeros(3)].astype(float);make_frame(frame)
                    want.append(np.r_[row[:4],frame,3,[1,1,.005,.0001,.0001],[.02,1],[0,0],
                                      [.9,.95,.001,.5,2],margin,int(row[0]>=margin),0,[0,1],-1,0,np.zeros(36)])
                expected=np.array(want).reshape(-1,71)
                if not np.isfinite(actual).all() or np.any(np.abs(actual-expected)>2e-12*(1+np.abs(expected))):
                    failures.append(dict(index=i,reason='values',maximum_error=float(np.max(np.abs(actual-expected))),input=full[i]))
            groups.append(dict(input=path.name,cases=len(raw),raw_returncode=a.returncode,full_returncode=b.returncode,
                               raw_stderr=a.stderr,full_stderr=b.stderr,failures=failures))
            print(profile,path.name,'pipeline',len(raw),'failures',len(failures),flush=True)
        reports[profile]=groups
    (out/'finalized-pipeline.json').write_text(json.dumps(reports,indent=2)+'\n')
    return not any(g['failures'] or g['raw_returncode'] or g['full_returncode'] for groups in reports.values() for g in groups)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('inputs',type=Path,nargs='+');a=p.parse_args()
    raise SystemExit(0 if run(a.out.resolve(),a.inputs) else 1)
