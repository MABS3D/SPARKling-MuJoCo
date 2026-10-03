"""Exercise report provenance, including a killed proof with a warm cache.

The mocked prover writes native-shaped reports; no formal-proof claim is made
by this runner regression. All source/cache/output paths are temporary.
"""
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import prove_equality_adapter as runner


class ReceiptChecks(unittest.TestCase):
    def invoke(self, *, fresh=True, report_line=1, exit_code=0,
               stop_reason='STOP_REASON_NONE', duplicate=False, whole=False, warning=False,
               specification=False, wrong_entity=False, missing_spec_model=False,
               overloaded=False, wrong_overload=False, ambiguous_profile=False,
               loading=False, materials=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build, analysis, out = root/'source-build', root/'cache', root/'receipt'
            name = ('mj-data-flex_elasticity-material_loading' if materials else
                    'mj-data-flex_elasticity-loading' if loading else
                    'mj-data-flex_elasticity-equalities' if whole or overloaded else 'mj-data-flex_elasticity')
            source_name = 'experimental/flex-elasticity-integration/src/'+name+'.adb'
            source = build/'source'/source_name
            source.parent.mkdir(parents=True)
            source.write_text('procedure '+('Append_Edges' if whole else 'Load')+' is\nbegin null; end;\n')
            if overloaded:
                source.write_text('procedure Append_Edges (Model : Force_Model) is\n'
                                  'begin null; end;\n'
                                  'procedure Append_Edges (E : Engine) is\n'
                                  'begin null; end;\n')
            hashes={source_name:hashlib.sha256(source.read_bytes()).hexdigest()}
            if specification:
                spec=source.with_suffix('.ads')
                spec.write_text('package Dummy is\n\nprocedure Load;\nend Dummy;\n')
                hashes[str(spec.relative_to(build/'source'))]=hashlib.sha256(spec.read_bytes()).hexdigest()
            if overloaded:
                spec=source.with_suffix('.ads')
                other='Model : Force_Model' if ambiguous_profile else 'E : Engine'
                spec.write_text('package Dummy is\nprocedure Append_Edges (Model : Force_Model);\n'
                                'procedure Append_Edges ('+other+');\nend Dummy;\n')
                hashes[str(spec.relative_to(build/'source'))]=hashlib.sha256(spec.read_bytes()).hexdigest()
            if missing_spec_model:
                spec=source.with_suffix('.ads')
                spec.write_text('package Dummy is\nfunction Omitted_Model return Boolean is (True);\nend Dummy;\n')
                hashes[str(spec.relative_to(build/'source'))]=hashlib.sha256(spec.read_bytes()).hexdigest()
            (build/'manifest.json').write_text(json.dumps({'sources':hashes}))
            report_path = analysis/'gnatprove'/(name+'.spark')
            report_path.parent.mkdir(parents=True)
            report = {'entities': {'1': {'name': 'MJ.Data.'+('Append_Edges' if whole or overloaded else 'Load'),
                'sloc': [{'file': name+'.adb', 'line': report_line}]}},
                'spark': {'1': 'all'}, 'proof': [{'severity': 'info'}],
                'flow': [], 'warn_error': [], 'skip_proof': [],
                'skip_flow_proof': [], 'pragma_assume': [],
                'progress': 'PROGRESS_PROOF', 'stop_reason': stop_reason}
            if specification:report['entities']['1']['sloc'][0]={'file':name+'.ads','line':3}
            if overloaded:report['entities']['1']['sloc'][0]={'file':name+'.ads','line':3 if wrong_overload else 2}
            if wrong_entity:report['entities']['1']['name']='MJ.Data.Other'
            if warning:report['warn_error'].append({'severity':'warning','rule':'imprecise-call'})
            # This is the previous invocation's report. The prover must see a
            # clean report slot even when it subsequently dies before writing.
            report_path.write_text(json.dumps(report))

            def prover(command, **kwargs):
                self.assertFalse(report_path.exists(), 'stale report survived')
                if fresh:
                    report_path.write_text(json.dumps(report))
                    if duplicate:
                        second = analysis/'other'/(name+'.spark')
                        second.parent.mkdir()
                        second.write_text(json.dumps(report))
                return subprocess.CompletedProcess(command, exit_code)

            args = ['proof', '--build', str(build), '--out', str(out),
                    '--analysis-build', str(analysis), '--scope',
                    'materials-load' if materials else
                    'whole' if whole else 'model' if overloaded else 'load']
            with patch.object(sys, 'argv', args), patch.object(runner, 'environment', return_value={}), \
                 patch.object(runner.subprocess, 'run', side_effect=prover), \
                 patch('builtins.print'):
                with self.assertRaises(SystemExit) as ended:
                    runner.main()
            result = json.loads((out/'results.json').read_text())
            self.assertEqual(bool(ended.exception.code), not result['passed'])
            return result

    def test_killed_proof_does_not_inherit_old_counts(self):
        result = self.invoke(fresh=False, exit_code=99)
        self.assertFalse(result['passed'])
        self.assertNotIn('proof_checks', result)
        self.assertNotIn('complete_coverage', result)

    def test_another_subprogram_report_is_rejected(self):
        result = self.invoke(report_line=156)
        self.assertFalse(result['passed'])
        self.assertFalse(result['report_scope_matches'])
        self.assertNotIn('proof_checks', result)

    def test_completed_minimum_is_not_whole_unit(self):
        result = self.invoke()
        self.assertTrue(result['passed'])
        self.assertEqual(result['proof_checks'], 1)
        self.assertTrue(result['scope_coverage_complete'])
        self.assertFalse(result['complete_coverage'])

    def test_incomplete_translation_is_not_a_pass(self):
        self.assertFalse(self.invoke(stop_reason='STOP_REASON_ERROR')['passed'])

    def test_review_warning_is_preserved_despite_closed_obligations(self):
        result=self.invoke(warning=True)
        self.assertTrue(result['obligations_closed'])
        self.assertFalse(result['passed'])
        self.assertEqual(len(result['warnings']),1)

    def test_public_subprogram_specification_location_is_accepted(self):
        self.assertTrue(self.invoke(specification=True)['passed'])

    def test_wrong_entity_at_specification_location_is_rejected(self):
        result=self.invoke(specification=True,wrong_entity=True)
        self.assertFalse(result['passed'])
        self.assertNotIn('proof_checks',result)

    def test_overloaded_specification_matches_only_its_body_profile(self):
        self.assertTrue(self.invoke(overloaded=True)['passed'])

    def test_another_overload_at_same_name_is_rejected(self):
        result=self.invoke(overloaded=True,wrong_overload=True)
        self.assertFalse(result['passed'])
        self.assertNotIn('proof_checks',result)

    def test_ambiguous_overload_profiles_are_rejected(self):
        result=self.invoke(overloaded=True,ambiguous_profile=True)
        self.assertFalse(result['passed'])
        self.assertNotIn('proof_checks',result)

    def test_admission_scope_follows_the_private_loader_unit(self):
        result=self.invoke(loading=True)
        self.assertTrue(result['passed'])
        self.assertEqual(result['limit_file'],'mj-data-flex_elasticity-loading.adb')

    def test_material_scope_selects_the_reduced_interface_child(self):
        result=self.invoke(materials=True)
        self.assertTrue(result['passed'])
        self.assertEqual(result['limit_file'],'mj-data-flex_elasticity-material_loading.adb')

    def test_ambiguous_reports_are_rejected(self):
        result = self.invoke(duplicate=True)
        self.assertFalse(result['passed'])
        self.assertNotIn('proof_checks', result)

    def test_whole_scope_cannot_omit_specification_expression_function(self):
        result=self.invoke(whole=True,missing_spec_model=True)
        self.assertFalse(result['passed'])
        self.assertFalse(result['obligations_closed'])
        self.assertEqual(result['missing_entities'],['omitted_model'])

    def test_whole_scope_checks_expected_entities(self):
        result = self.invoke(whole=True)
        self.assertTrue(result['passed'])
        self.assertTrue(result['complete_coverage'])
        self.assertEqual(result['missing_entities'], [])


if __name__ == '__main__':
    unittest.main()
