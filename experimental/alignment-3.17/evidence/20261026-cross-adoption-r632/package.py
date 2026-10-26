from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';D=E/'20261026-cross-adoption-r632';Z=D/'cross-adoption.zip';O=Path('/var/tmp/sparkling-adopt-cross-r631-20261026');G=Path('/var/tmp/sparkling-cross-revisit-gates-r625-20261025')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 accepted=json.loads((O/'complete.json').read_text());assert accepted['passed'];gate=json.loads((G/'complete.json').read_text());assert gate['passed'] and len(gate['gates'])==13
 h=json.loads((O/'snapshot317/sources.json').read_text());owner='experimental/smooth/src/mj-smooth_math.adb';assert sha(R/owner)==h[owner]
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files']);assert len(prior)==186
 storage=Path('/var/tmp/sparkling-storage-unit-r636-20261026/results.json');sd=json.loads(storage.read_text());assert sd['passed'] and sd['checks']==84 and not sd['warnings']
 D.mkdir();shutil.copy2(__file__,D/'package.py');members={};excluded={'obj','analysis','__pycache__','.git'}
 roots=[G,O,Path('/var/tmp/sparkling-storage-slices-r633-20261026'),Path('/var/tmp/sparkling-storage-motion-min-r634-20261026'),Path('/var/tmp/sparkling-storage-inertia-min-r635-20261026'),storage.parent]
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();i=zipfile.ZipInfo.from_file(p,n);i.compress_type=zipfile.ZIP_DEFLATED;z.writestr(i,data,compresslevel=6)
  for folder in roots:
   for p in sorted(folder.rglob('*')):
    if p.is_file() and not any(c in excluded for c in p.relative_to(folder).parts):put(p,folder.name+'/'+p.relative_to(folder).as_posix())
  for name in ['sparkling-cross-revisit-gates-r625.py','sparkling-adopt-cross-r631.py','sparkling-storage-slices-r633.py']:put(Path('/tmp')/name,'recipes/'+name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:
  assert z.testzip() is None and len(z.namelist())==len(members) and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'summary.json',dict(adopted=True,actual_adoption=accepted,source_binding=json.loads((O/'source-binding.json').read_text()),numerical_groups=gate['gates'],private_storage=dict(adopted=False,whole_unit=sd,minima={'motion':json.loads(Path('/var/tmp/sparkling-storage-motion-min-r634-20261026/results.json').read_text()),'inertia':json.loads(Path('/var/tmp/sparkling-storage-inertia-min-r635-20261026/results.json').read_text())}),scope='Actual Cross adoption after13 numerical integration groups and796 closed whole-math checks on each exact C14/C17 closure, existing66 diagnostics separate. Both fresh actual source manifests equal verified builds. Replicated accepted movement raw data are in exact r630; full C17 proof/bit inputs in r620. Private contiguous spatial load experiment closes84 checks without warnings, but is not adopted/timed yet. Full dynamics Gold, complete engine port/migration and C parity remain open.'))
 dump(D/'archive-manifest.json',dict(files=members,count=len(members),zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches. All frozen source, copied complete SPARK reports, logs, executables and numerical outputs retained. r620/r630 retain earlier proof/corpus/timing inputs. External reference libraries/toolchains identified by pinned hashes, not embedded.'))
 dump(D/'verification.json',dict(passed=True,archive_members_verified=len(members),zip_sha256=sha(Z),actual_source_owner_verified=True,prior_inventory_entries=186))
 (D/'README.md').write_text('''# Adopted Cross with complete two-reference proof and integration

The working Cross now uses the exact candidate measured in r630: six rounded
products, three ordered subtractions and unchanged public domain/postcondition.
Six redundant intermediate subtype checks become proved Static bounds. No
assumption, suppression, new trusted production body, forced inline, input
narrowing or deallocator change is introduced.

The entire math unit independently closes 796 checks (738 proof, 58 flow) under
both exact production C3.14 and candidate C3.17 closures. Each preserves 66 existing
diagnostics; strict warning-free passed is false, obligations_closed true. All13
broader validation/release numerical groups pass, including raw mass, derivatives,
reverse layouts, compact cache, direct CRB and the 5,972-case exact C bit corpus
per profile. Fresh snapshots of the actual working sources match the verified
build manifests in full, including the default production project release source.
Earlier kernel/reduction proofs retain unchanged called contracts; not rerun here.
This is scoped FP functional/safety assurance, not complete dynamics Gold or
ideal-real accuracy.

The nine targeted and all30 supported integrated movement scenarios are preserved
in r630. Both use six identical executable replicas per role, balanced orders,
normalized argv0 and shared fixtures, normal native C3.17 SIMD/LTO and matched GCC
FP flags. Chain24 time falls about8% relative to the adopted threshold8 baseline;
branches24 about5%, with all corresponding intervals below parity in both runs.
Other workload estimates remain distinct, with no unweighted aggregate. The
incomplete low-disk attempt and copy-placement uncertainty are retained. Chain24
still takes about2.1times C and branches24 about1.59times C, so overall parity
and complete MuJoCo coverage are unfinished.

A subsequent PRIVATE spatial-storage candidate uses checked language slice
conversions for contiguous six-/ten-value loads. Its two minima each close12checks
and the full unit closes84 without warnings, retaining exact component/frame
relations and full domains. It introduces no unchecked conversion or borrowed
pointer. The public spatial-storage body is unchanged; boundary/compiler/movement
acceptance remains pending. Only completed source/proof records are included.

cross-adoption.zip contains frozen input, copied SPARK reports, numerical results,
executables and actual source bindings. Restore exact ZIP bytes with the documented
evidence_store restore command. Previous r620/r630 bundles provide the full C17
proof, bit corpus, native comparator metadata and raw movement samples. No new
GitHub commit or push is performed; changes remain local after6e98c9bc4.
''')
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);inv['cross_adoption_r632_prior_entries_preserved']=True;dump(E/'inventory.json',inv)
 print('CROSS ADOPTION CHECKPOINT READY',Z.stat().st_size,len(members),inv['count'],flush=True)
if __name__=='__main__':main()
