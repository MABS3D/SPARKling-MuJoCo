"""Collect fresh proof diagnostics and numerical evidence without promoting pending proofs."""
from pathlib import Path
import argparse, hashlib, json, shutil, subprocess

here = Path(__file__).resolve().parents[1]
ap = argparse.ArgumentParser()
ap.add_argument('--proof-root', type=Path, default=Path('/var/tmp/sparkling-actuators-20260930'))
args = ap.parse_args()
manifest = {str(f.relative_to(here)): hashlib.sha256(f.read_bytes()).hexdigest()
            for folder in ['base', 'src'] for f in (here / folder).glob('*.ad*')}
small = ['sparse_product', 'lane_add', 'combine', 'unfold_lanes', 'unfold_tail',
         'velocity', 'rank_bounds', 'compress', 'project', 'slots', 'length_curve', 'scale_moment', 'add_force']
whole = ['mj-transmissions', 'mj-actuator_curves', 'mj-actuator_geometry',
         'mj-advanced_actuators', 'mj-actuator_transmissions']
runs = [('small', 'final-small-' + name) for name in small]
runs += [('small', 'final-small-geometry-product-v2')]
runs += [('small', 'final-small-compress-into'), ('small', 'final-small-reset')]
runs += [('complete', 'fresh-whole-' + name) for name in whole]
rows = []
for scope, name in runs:
    source = args.proof_root / name
    result = json.loads((source / 'result.json').read_text())
    assert json.loads((source / 'sources.json').read_text()) == manifest, name + ': stale sources'
    assert result['sources_unchanged'] and result['fresh'], name + ': incomplete/freshness failure'
    assert result['progress'] == 'PROGRESS_PROOF' and result['stop_reason'] == 'STOP_REASON_NONE', name
    assert result['coverage_ok'] and result['all_in_spark'], name + ': incomplete coverage'
    assert not any(result[k] for k in ['skip_proof', 'skip_flow_proof', 'pragma_assume']), name
    destination = here / 'evidence' / 'proofs' / name
    destination.mkdir(parents=True, exist_ok=True)
    for filename in ['result.json', 'sources.json', 'report.spark.json', 'run.log']:
        shutil.copyfile(source / filename, destination / filename)
    rows.append({'scope': scope, 'name': name, 'subprogram': result['subprogram'],
                 'passed': result['passed'], 'closed_checks': result['checks'],
                 'open_checks': len(result['open']), 'warnings_reviewed': result['reviewed_warnings'],
                 'seconds': result['seconds'], 'path': str(destination.relative_to(here))})

for mode in ['validation', 'release']:
    result = json.loads((here / 'evidence' / ('numerics-' + mode + '.json')).read_text())
    assert result['passed'] and result['cases'] == 4836, mode
    expected = {str(f.relative_to(here)): hashlib.sha256(f.read_bytes()).hexdigest()
                for folder in ['base', 'src', 'tests'] for f in (here / folder).iterdir() if f.is_file()}
    assert result['sources'] == expected, mode + ': stale numerical evidence'

toolchain = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
versions = {}
for folder, executable in [('gnat', 'gnat'), ('gprbuild', 'gprbuild'), ('gnatprove', 'gnatprove')]:
    tool = next((toolchain / folder).glob('*/bin/' + executable))
    versions[executable] = subprocess.check_output([str(tool), '--version'], text=True)
summary = {'reference_version': '3.14.0', 'sources': manifest, 'proofs': rows,
           'tool_versions': versions, 'project_sha256': hashlib.sha256((here / 'actuation.gpr').read_bytes()).hexdigest(),
           'checked_and_release_cases_each': 4836, 'aggregate_gold': False,
           'integrated_in_engine': False, 'performance_measured': False}
performance_path = here / 'evidence/performance/20260930-csr/stage-results.json'
if performance_path.exists():
    performance = json.loads(performance_path.read_text())
    assert all(performance['candidate_sources'][name] == value for name, value in manifest.items())
    summary.update(performance_measured=True, performance_scope='isolated actuation phase',
                   aggregate_movement_performance_measured=False,
                   performance_record=str(performance_path.relative_to(here)),
                   performance_integration_gate_passed=False)
(here / 'evidence' / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')

md = ['# Prove del candidato', '',
      'Sorgenti CSR verificati il 2026-09-30; riferimento C MuJoCo 3.14.0. '
      'I conteggi sono diagnostici per singola esecuzione, non percentuali di copertura di MuJoCo.', '',
      '## Sottoprogrammi minimi', '',
      '| Sottoprogramma | Obblighi chiusi | Aperti | Esito |',
      '|---|---:|---:|---|']
for row in rows:
    if row['scope'] == 'small':
        label = row['subprogram']
        if 'geometry-product' in row['name']: label = 'Geometry.Product'
        state = 'chiuso' if row['passed'] else 'pendente'
        md.append(f"| [{label}](proofs/{row['name']}/result.json) | {row['closed_checks']} | {row['open_checks']} | {state} |")
md += ['', 'Le prove locali sono modulari: dimostrano i contratti del sottoprogramma sotto '
       'le precondizioni e i contratti dei chiamati. Le curve dimostrano le branche del modello '
       'floating point; compressione e proiezione dimostrano schema, valori e conservazione '
       'delle componenti non interessate. Rank_Bounds e Unfold sono lemmi ghost.', '',
       '## Unità complete', '', '| Unità | Obblighi chiusi | Aperti | Esito |', '|---|---:|---:|---|']
for row in rows:
    if row['scope'] == 'complete':
        md.append(f"| [{row['name']}](proofs/{row['name']}/result.json) | {row['closed_checks']} | {row['open_checks']} | pendente |")
md += ['', 'Tutte le esecuzioni complete coprono le dichiarazioni dell’unità; le evidenze sono '
       'fresche, senza Skip_Proof, Skip_Flow o Assume. Rimangono obblighi di runtime safety '
       'e di correttezza funzionale: nessuna delle cinque unità viene dichiarata interamente Gold/Silver.', '',
       'Le funzioni elementari standard producono avvisi imprecise-call, conservati negli esiti. '
       'Le prove complete con questi avvisi non sono accettate come chiuse. Nelle sole prove '
       'di Product/Slots/Reset, i cui corpi e chiamati sono stati esaminati e non usano funzioni '
       'elementari, gli avvisi esterni al sottoprogramma selezionato sono annotati come '
       'estranei alla prova locale. Non sono soppressi né dichiarati risolti per l’unità.', '',
       'La riduzione Velocity ha il modello delle quattro corsie e della coda; resta aperta '
       'la conservazione dell’invariante funzionale e l’uguaglianza finale al modello. '
       'Nelle altre unità sono pendenti limiti intermedi floating point, precondizioni/index, '
       'composizione geometrica e uguaglianza alle leggi PID/DC. I log riportano posizione e '
       'diagnostica di ogni obbligo. La sicurezza universale non è deducibile dai soli test.', '',
       'Timeout e modelli mancanti sono lavoro di dimostrazione da completare; non eccezioni '
       'matematiche documentate per fermarsi a Silver. Prestazioni e integrazione nel motore '
       'restano separate da questi risultati.']
(here / 'evidence' / 'proofs.md').write_text('\n'.join(md) + '\n')
print(json.dumps({'small_closed': sum(r['passed'] for r in rows if r['scope'] == 'small'),
                  'complete_closed': sum(r['passed'] for r in rows if r['scope'] == 'complete'),
                  'cases_each': 4836}, indent=2))
