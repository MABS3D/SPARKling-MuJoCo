#!/usr/bin/env python3
"""Run bounded GNATprove jobs on individual, unchanged Ada subprograms.

Linux runner using the repository's process-group watchdog. Results concern
the recorded source snapshot and selected checks, not physical equivalence.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time


DECL = re.compile(r'^   (function|procedure)\s+("[^"\n]+"|[A-Za-z]\w*)', re.M)
MESSAGE = re.compile(r'^([^\s:]+\.ad[bs]):(\d+):(\d+): (info|warning|low|medium|high|error): (.*)$')
WITH = re.compile(r'^(?:(?:limited|private)\s+)?with\s+([^;]+);', re.M | re.I)


def diagnostic_messages(stdout: str, structured: dict) -> list[dict]:
    """Keep unit-level flow failures even when GNATprove filters console lines.

    --limit-line can suppress an error elsewhere in the selected unit from
    stdout while that error prevents the requested proof from running at all.
    The .spark flow records still contain the error and its actual location.
    """
    messages = []
    seen = set()

    def add(file, line, column, severity, text):
        key = (file, int(line), int(column), severity, text)
        if key not in seen:
            seen.add(key)
            messages.append(dict(file=file, line=int(line), column=int(column),
                                 severity=severity, text=text))

    for line in stdout.splitlines():
        match = MESSAGE.match(line)
        if match:
            add(*match.groups())
    for item in structured.values():
        for message in item.get('flow', []):
            if message.get('severity') in ('error', 'low', 'medium', 'high'):
                add(message['file'], message['line'], message['col'],
                    message['severity'], message['message']['text'])
    return messages


def targets(source: Path) -> list[dict]:
    groups = defaultdict(list)
    for path in sorted(source.glob('*.ad?')):
        content = path.read_text()
        declarations = list(DECL.finditer(content))
        for index, match in enumerate(declarations):
            stop = declarations[index + 1].start() if index + 1 < len(declarations) else len(content)
            body = content[match.start():stop]
            if re.search(r'\bis\s+new\s', body.split(';', 1)[0]):
                continue  # Generic instantiations are not subprogram bodies.
            if path.suffix == '.ads':
                if match.group(1) != 'function' or not re.search(r'\breturn\b[^;]*\bis\s*\(', body):
                    continue  # In specs, select expression-function bodies only.
            line = content.count('\n', 0, match.start()) + 1
            name = match.group(2)
            slug = name.strip('"')
            slug = {'+': 'add', '-': 'subtract', '*': 'multiply'}.get(slug, slug)
            key = f'{path.stem}__{slug.lower()}__{path.suffix[1:]}_{line}'
            groups[path.stem].append(dict(id=key, file=path.name, line=line, name=name))

    # Cover every module before spending the budget on all helpers in one file.
    order = ['mj-smooth_math', 'mj-data', 'mj-data-inertia', 'mj-data-kinematics',
             'mj-data-forces', 'mj-data-actuation', 'mj-data-forward', 'mj-data-euler']
    order += sorted(set(groups) - set(order))
    result = []
    for index in range(max(map(len, groups.values()), default=0)):
        for group in order:
            if index < len(groups[group]):
                result.append(groups[group][index])
    return result


def source_files(repo: Path) -> list[Path]:
    paths = [repo / 'sparkling_mujoco.gpr', repo / 'experimental/smooth/smooth.gpr']
    for directory in (repo / 'src', repo / 'experimental/smooth/src'):
        paths.extend(p for p in directory.rglob('*') if p.is_file() and p.suffix in ('.ads', '.adb'))
    return sorted(paths)


def line_targets(source: Path, selectors: list[str]) -> list[dict]:
    result = []
    for selector in selectors:
        file, number = selector.rsplit(':', 1)
        line = int(number)
        if Path(file).name != file or Path(file).suffix not in ('.ads', '.adb'):
            raise ValueError('use an Ada source basename and a one-based line number')
        path = source / file
        if not path.is_file() or not 1 <= line <= len(path.read_text().splitlines()):
            raise ValueError(f'invalid source location: {selector}')
        target = dict(id=f'{path.stem}__{path.suffix[1:]}_line_{line}',
                      file=file, line=line, name=f'line {line}', selector='line')
        if target not in result:
            result.append(target)
    return result


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def isolated_project(snapshot: Path, work: Path, unit: str, extra_units: tuple[str, ...] = ()) -> Path:
    """Preserve whole source units and their dependencies, without library-wide discovery."""
    sources = {p.name: p for p in snapshot.rglob('*') if p.suffix in ('.ads', '.adb')}
    subunits = defaultdict(list)
    for path in sources.values():
        match = re.search(r'^separate\s*\(\s*([\w.]+)\s*\)', path.read_text(), re.M | re.I)
        if match:
            subunits[match.group(1).lower().replace('.', '-')].append(path.stem)
    pending = [unit, *extra_units]
    included = set()
    while pending:
        stem = pending.pop()
        if stem in included:
            continue
        included.add(stem)
        pending.extend(subunits[stem])
        if '-' in stem:
            pending.append(stem.rsplit('-', 1)[0])
        for suffix in ('.ads', '.adb'):
            path = sources.get(stem + suffix)
            if path is None:
                continue
            # Runtime units are supplied by the toolchain; retain all local withs.
            for match in WITH.finditer(path.read_text()):
                for name in match.group(1).split(','):
                    dependency = name.strip().lower().replace('.', '-')
                    if dependency + '.ads' in sources or dependency + '.adb' in sources:
                        pending.append(dependency)
    files = sorted(name for name in sources if Path(name).stem in included)
    directories = sorted({str(sources[name].parent) for name in files})
    quote = lambda value: '"' + value.replace('"', '""') + '"'
    project = work / (unit + '.gpr')
    project.write_text('\n'.join([
        'project Fragment is',
        '   for Source_Dirs use (' + ', '.join(map(quote, directories)) + ');',
        '   for Source_Files use (' + ', '.join(map(quote, files)) + ');',
        '   for Object_Dir use ' + quote(unit + '-obj') + ';',
        '   for Create_Missing_Dirs use "True";',
        '   package Compiler is',
        '      for Default_Switches ("Ada") use',
        '        ("-gnat2022", "-O0", "-g", "-gnata", "-gnato", "-gnatVa", "-ffp-contract=off");',
        '   end Compiler;',
        'end Fragment;', '']))
    return project


def save_report(out: Path, manifest: dict, results: list[dict]) -> None:
    data = dict(manifest, results=results, counts=dict(Counter(r['status'] for r in results)))
    (out / 'results.json').write_text(json.dumps(data, indent=2) + '\n')
    lines = ['# Smooth dynamics: fragmented GNATprove results', '',
             'Each row is one bounded subprogram, line or whole-unit invocation on unchanged sources.',
             'A completed row is limited to the emitted obligations and their contracts;',
             'it is not a proof of physical correctness or of the complete simulator.',
             'An unproved check is not, by itself, a demonstrated runtime failure.',
             'Timeouts and jobs not yet run must not be counted as passes.', '',
             f"Source snapshot: `{manifest['snapshot']}`", '',
             '| Subprogram | Location | Result | Proof checks | Unproved/flow | Errors | Seconds |',
             '| --- | --- | --- | ---: | ---: | ---: | ---: |']
    for row in results:
        target = row['target']
        label = f"{target['file']}:{target['line']}"
        status = row['status']
        if row.get('log'):
            status = f"[{status}]({row['log']})"
        lines.append(f"| `{target['name']}` | `{label}` | {status} | {row.get('proof_checks', 0)} | {row.get('unproved', 0)} | "
                     f"{row.get('errors', 0)} | {row.get('seconds', 0):.1f} |")
    lines += ['', '## Diagnostics', '']
    for row in results:
        diagnostics = [m for m in row.get('messages', []) if m['severity'] != 'info']
        if not diagnostics:
            continue
        lines += [f"### {row['target']['id']}", '']
        for message in diagnostics[:8]:
            text = message['text'].replace('\n', ' ')
            lines.append(f"- `{message['file']}:{message['line']}` ({message['severity']}): {text}")
        if len(diagnostics) > 8:
            lines.append(f"- {len(diagnostics) - 8} more diagnostics in the individual log.")
        lines.append('')
    (out / 'report.md').write_text('\n'.join(lines) + '\n')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument('--report-dir', type=Path)
    parser.add_argument('--toolchain-root', type=Path, help='Directory containing gnat/, gprbuild/, gnatprove/')
    parser.add_argument('--unit', action='append', default=[], help='File name or stem; repeat to select units')
    parser.add_argument('--match', default='', help='Case-insensitive substring of target id or subprogram name')
    parser.add_argument('--name', action='append', default=[],
                        help='Exact subprogram name, case-insensitive; repeat for a focused sweep')
    parser.add_argument('--line', action='append', default=[], help='Check FILE:LINE instead of whole subprograms; repeatable')
    parser.add_argument('--whole-unit', action='append', default=[], help='Check an entire unit basename, e.g. mj-smooth_math')
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--wall-seconds', type=int, default=20, help='Watchdog limit per subprogram')
    parser.add_argument('--prepare-seconds', type=int, default=60, help='First job budget per dependency project')
    parser.add_argument('--total-seconds', type=int, default=600, help='Budget for the complete sweep')
    parser.add_argument('--prover-seconds', type=int, default=1)
    parser.add_argument('--prover-mb', type=int, default=1000, choices=range(128, 3001),
                        metavar='128..3000', help='Per-prover memory limit in MB; overall watchdog remains active')
    parser.add_argument('--steps', type=int, default=200)
    parser.add_argument('--provers', default='cvc5', help='Comma-separated GNATprove provers')
    parser.add_argument('--level', type=int, choices=range(5), default=0)
    parser.add_argument('--proof-mode', choices=('per_check', 'progressive'), default='per_check',
                        help='Proof splitting strategy; recorded in the run manifest')
    parser.add_argument('--jobs', type=int, default=1)
    parser.add_argument('--cap-mb', type=int, choices=range(512, 4001), default=2000)
    args = parser.parse_args()
    if min(args.wall_seconds, args.prepare_seconds, args.total_seconds, args.prover_seconds) <= 0 or args.steps < 0:
        parser.error('time limits must be positive; steps must be nonnegative (0 = no step limit)')
    repo = args.repo.resolve()
    if args.jobs < 1 or (args.line and args.whole_unit):
        parser.error('jobs must be positive; choose line selectors or whole units')
    if args.name and (args.line or args.whole_unit):
        parser.error('--name selects subprograms; do not combine it with --line or --whole-unit')
    try:
        if args.whole_unit:
            selected = []
            for unit in args.whole_unit:
                stem = Path(unit).stem
                if Path(stem).name != stem or not (repo / 'experimental/smooth/src' / (stem + '.adb')).is_file():
                    raise ValueError(f'unknown unit: {unit}')
                selected.append(dict(id=stem+'__whole_unit', file=stem+'.adb', line=1,
                                     name='whole unit', selector='unit'))
        else:
            selected = (line_targets(repo / 'experimental/smooth/src', args.line) if args.line
                        else targets(repo / 'experimental/smooth/src'))
    except (ValueError, OSError) as error:
        parser.error(str(error))
    selected = [t for t in selected if
                (not args.unit or t['file'] in args.unit or Path(t['file']).stem in args.unit)
                and (not args.name or t['name'].lower() in {name.lower() for name in args.name})
                and args.match.lower() in (t['id'] + ' ' + t['name']).lower()]
    if not selected:
        parser.error('no matching subprograms')
    if args.list:
        print(json.dumps(selected, indent=2))
        return 0
    if args.report_dir is None:
        parser.error('--report-dir is required for a run')
    env = os.environ.copy()
    if args.toolchain_root:
        bins = []
        for tool in ('gnat', 'gprbuild', 'gnatprove'):
            candidates = sorted((args.toolchain_root / tool).glob(f'{tool}-*/bin'))
            if not candidates:
                parser.error(f'cannot find {tool} in --toolchain-root')
            bins.append(str(candidates[-1]))
        env['PATH'] = ':'.join(bins) + ':' + env.get('PATH', '')
    if shutil.which('gnatprove', path=env.get('PATH')) is None:
        parser.error('gnatprove is not on PATH; provide --toolchain-root')

    out = args.report_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    if (out / 'results.json').exists():
        parser.error('report directory already contains a run; choose a new directory')
    logs = out / 'logs'
    logs.mkdir(exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='sparkling-smooth-fragments-'))
    snapshot = work / 'source'
    hashes = {}
    originals = source_files(repo)
    for original in originals:
        relative = original.relative_to(repo)
        destination = snapshot / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        content = original.read_bytes()
        destination.write_bytes(content)
        hashes[str(relative)] = hashlib.sha256(content).hexdigest()
    if any(digest(p) != hashes[str(p.relative_to(repo))] for p in originals):
        parser.error('sources changed while taking the snapshot; rerun when they are stable')
    # Take line numbers from the same immutable source snapshot used by the tool.
    selected_ids = {t['id'] for t in selected}
    snapshot_targets = (selected if args.whole_unit else
                        line_targets(snapshot / 'experimental/smooth/src', args.line) if args.line
                        else targets(snapshot / 'experimental/smooth/src'))
    selected = [t for t in snapshot_targets if t['id'] in selected_ids]
    if args.name:
        # Honor helper-before-caller order requested on the command line.
        name_order = {name.lower(): i for i, name in enumerate(args.name)}
        selected.sort(key=lambda target: name_order[target['name'].lower()])
    if not selected:
        parser.error('no selected targets in the immutable snapshot')
    # Runtime children share one stable dependency project and cache. Changing
    # Source_Files every job invalidates frontend artifacts and hides diagnostics.
    project_groups = {Path(t['file']).stem:
                      ('mj-data-euler' if Path(t['file']).stem.startswith('mj-data')
                       else Path(t['file']).stem) for t in selected}
    # Public entry wrappers need not be dependencies of the internal Euler path.
    # Retain them in the stable shared proof project after the pipeline split.
    data_units = tuple(sorted({p.stem for p in (snapshot / 'experimental/smooth/src').glob('mj-data*.ad?')}))
    group_projects = {unit: isolated_project(snapshot, work, unit,
                      data_units if unit == 'mj-data-euler' else ())
                      for unit in set(project_groups.values())}
    projects = {unit: group_projects[group] for unit, group in project_groups.items()}
    env['SPARKLING_BUILD_ROOT'] = str(work / 'build')
    manifest = dict(snapshot=str(snapshot), build_root=env['SPARKLING_BUILD_ROOT'],
                    source_sha256=hashes, repo=str(repo), arguments=vars(args).copy(),
                    projects={unit: dict(path=str(path), sha256=digest(path), content=path.read_text())
                              for unit, path in projects.items()})
    manifest['arguments'] = {k: str(v) if isinstance(v, Path) else v for k, v in manifest['arguments'].items()}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    results = [dict(target=t, status='not_run') for t in selected]
    save_report(out, manifest, results)
    started = time.monotonic()
    prepared = set()
    for index, target in enumerate(selected):
        remaining = int(args.total_seconds - (time.monotonic() - started))
        if remaining < 2:
            for row in results[index:]:
                row['status'] = 'not_run_budget'
            break
        project = projects[Path(target['file']).stem]
        first = project not in prepared
        wall = min(max(args.wall_seconds, args.prepare_seconds) if first else args.wall_seconds, remaining)
        prepared.add(project)
        object_root = project.parent / (project.stem + '-obj')
        # GNATprove's aggregate report/exit code includes every .spark file
        # left in its directory, even with --limit-subp. Clear only our previous
        # diagnostic records, retaining compiled global contracts and prover cache.
        for previous in object_root.rglob('*.spark'):
            previous.unlink()
        summary = object_root / 'gnatprove/gnatprove.out'
        if summary.exists():
            summary.unlink()
        analysis_file = target['file']
        if target.get('selector') == 'line' and analysis_file.endswith('.ads'):
            # Contract checks are emitted while analyzing the corresponding body.
            # Analyzing only a spec can otherwise select zero obligations.
            body = Path(analysis_file).with_suffix('.adb').name
            if (snapshot / 'experimental/smooth/src' / body).is_file():
                analysis_file = body
        command = [sys.executable, str(repo / 'tools/guarded.py'), '--cap-mb', str(args.cap_mb),
                   '--timeout', str(wall), '--', 'gnatprove', '-P', str(project),
                   '--mode=all', f'--level={args.level}', f'--prover={args.provers}',
                   f'--proof={args.proof_mode}',
                   f'--timeout={args.prover_seconds}', f'--memlimit={args.prover_mb}', f'--steps={args.steps}',
                   '--counterexamples=off', f'-j{args.jobs}', '--report=all', '--output=oneline',
                   '--checks-as-errors=on',
                   *([] if target.get('selector') == 'unit' else
                     [f"--limit-{target.get('selector', 'subp')}={target['file']}:{target['line']}"]),
                   '-u', analysis_file]
        print(f"[{index + 1}/{len(selected)}] {target['id']} (wall {wall}s)", flush=True)
        before = time.monotonic()
        try:
            proc = subprocess.run(command, cwd=snapshot, env=env, stdout=subprocess.PIPE,
                                  stderr=subprocess.STDOUT, text=True)
        except KeyboardInterrupt:
            results[index]['status'] = 'interrupted'
            for row in results[index + 1:]:
                row['status'] = 'not_run_interrupted'
            save_report(out, manifest, results)
            return 130
        elapsed = time.monotonic() - before
        log = Path('logs') / (target['id'] + '.log')
        (out / log).write_text(proc.stdout)
        proof_checks = 0
        flow_checks = 0
        structured = {}
        for record in object_root.rglob('*.spark'):
            item = json.loads(record.read_text())
            structured[record.name] = item
            proof_checks += len(item.get('proof', []))
            flow_checks += len(item.get('flow', []))
        if structured:
            (logs / (target['id'] + '.spark.json')).write_text(json.dumps(structured, indent=2) + '\n')
        if summary.exists():
            shutil.copyfile(summary, logs / (target['id'] + '.summary.txt'))
        messages = diagnostic_messages(proc.stdout, structured)
        unproved = sum(m['severity'] in ('low', 'medium', 'high') for m in messages)
        errors = sum(m['severity'] == 'error' for m in messages)
        if proc.returncode == 99:
            if 'insufficient available memory' in proc.stdout:
                status = 'resource_blocked'
            elif elapsed >= wall:
                status = ('proof_timeout' if 'Phase 3 of 3' in proc.stdout else 'preparation_timeout')
            else:
                status = 'resource_limit'
        elif errors:
            status = 'analysis_error'
        elif unproved:
            status = 'unproved_checks'
        elif proc.returncode != 0:
            status = 'tool_error'
        elif any(m['severity'] == 'warning' for m in messages):
            status = 'completed_with_warnings'
        elif not proof_checks:
            status = 'completed_no_proof_checks'
        else:
            status = 'completed_no_unproved'
        results[index] = dict(target=target, status=status, exit_code=proc.returncode,
                              seconds=round(elapsed, 2), unproved=unproved, errors=errors,
                              proof_checks=proof_checks, flow_checks=flow_checks,
                              messages=messages, log=str(log), command=command)
        save_report(out, manifest, results)
        print(f"  {status}: {unproved} unproved/flow, {errors} errors, {elapsed:.1f}s", flush=True)
        # An unavailable machine cannot improve by launching the remaining jobs.
        if status in ('resource_blocked', 'resource_limit', 'analysis_error'):
            for row in results[index + 1:]:
                row['status'] = 'not_run_analysis' if status == 'analysis_error' else 'not_run_resource'
            break
    save_report(out, manifest, results)
    print('Report:', out / 'report.md', flush=True)
    # Zero selected obligations is a diagnostic result, never a proof pass.
    return 0 if all(r['status'] == 'completed_no_unproved' for r in results) else 1


if __name__ == '__main__':
    sys.exit(main())
