from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-current-pc-profile-r1314';Z=D/'current-pc-profile.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
P=V/'sparkling-profile-compact-rne-r1298-20261027';A=json.loads((P/'results.json').read_text());C=json.loads((P/'post-profile-check.json').read_text());assert A['passed'] and C['passed'] and all(x['exact_uninstrumented_endpoints']==10000 for x in C['checks'].values());D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[V/'sparkling-current-profile-control-r1298-20261027',P];members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for root in roots:
  for p in sorted(root.rglob('*')):
   if p.is_file() and '__pycache__' not in p.parts:
    n=root.name+'/'+p.relative_to(root).as_posix();data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 p=V/'sparkling-profile-compact-rne-r1298.driver.log';data=p.read_bytes();members['logs/'+p.name]=hashlib.sha256(data).hexdigest();z.writestr('logs/'+p.name,data)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size));dump(D/'summary.json',dict(profile=A,post_profile_checks=C,scope='Exact same baseline1171/current1274/C binaries as accepted six-replica measurements, with main-thread timer sampling and all10000 endpoints exactly matching each role uninstrumented output. Actual runtime1294 source binding is in the earlier adoption checkpoint. Full-process sampling includes setup/output and handler overhead, substantial overruns and unknown locations; no exact phase-time, statistical causal decomposition or parity timing claim. Inlining changes symbol ownership. The sampled Add_Row scalar loop still contains input Work_Real conversions plus integer-rejection counting, motivating the private1299 one-owner experiment; no gain is inferred from opcode counts.'))
(D/'README.md').write_text('''# Refreshed current-runtime PC profile, not acceptance timing

The same actual1171, adopted final1274 and normal native C3.17 binaries from the
combined acceptance runs are sampled independently on chain24/state0. Complete
main-thread timer metadata is checked. Each role passes10000 numeric endpoints
and exactly matches its own uninstrumented six-replica output. Binary/provider
hashes, maps, raw PC/timestamp data, symbolization and instruction windows remain.

Current self-sample shares are about19.4% in Solve_Acceleration,15.7% in
Solve_Compatible_Buffers,11.2% in Add_Long_Row,8.6% in compact Fill and7.4% in
Try_Recursive. C's top symbols include addToScl/factorI/jac/solveLD. These are
full-process sample fractions, including setup, output, signal overhead and
substantial timer overruns. Unknown locations remain explicit; repeated work may
alias the sampling schedule. Do not turn fractions or profiled elapsed times into
exact phase costs, causal speedups or parity evidence. Inlining changes symbol
ownership between binaries, so isolated parent/child symbols are not comparable.

Instruction windows identify retained Work_Real input conversions in the Add_Row
scalar loop inside Solve_Compatible_Buffers, alongside the integer rejection
counter. The referenced constant decodes to -1e60. The original Add_Row Pre
already bounds both operands; private1299 tests an identical base-Real expression
with those former bounds proved as Static facts. Its proof/build/numerical/timing
qualification is separate, not a result of this profile. No production code,
complete dynamics Gold, full port/migration or C-parity claim follows here.
Restore current-pc-profile.zip through tools/evidence_store.py.
''');dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),all_roles_exact_uninstrumented_endpoints=10000,profile_is_diagnostic_only=True));inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),inventory=inv['count'])),flush=True)
