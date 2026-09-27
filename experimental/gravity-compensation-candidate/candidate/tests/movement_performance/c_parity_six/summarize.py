#!/usr/bin/env python3
"""Compare independent recorded sessions without pooling their confidence limits."""
import argparse
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--session', action='append', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
runs = [json.loads((directory/'measurements.json').read_text()) for directory in a.session]
assert all(run['complete'] for run in runs)
models = list(dict.fromkeys(row['case'].rsplit('-',1)[0] for row in runs[0]['summary']))
summary = dict(sessions=[str(x) for x in a.session], models=[],
    max_absolute_error=max(row['max_absolute_error'] for run in runs for row in run['summary']),
    timed_processes=sum(len(run['records']) for run in runs),
    timed_steps=sum(len(row['rows'])*100 for run in runs for row in run['records']),
    uncertainty='Ranges of per-state medians across sessions; each CI is within-session paired bootstrap, unadjusted for multiplicity.')
for model in models:
    rows = [row for run in runs for row in run['summary'] if row['case'].rsplit('-',1)[0] == model]
    changes = [100*(1-row['current_over_baseline']['median']) for row in rows]
    ratios = [row['current_over_c']['median'] for row in rows]
    summary['models'].append(dict(model=model,time_reduction_percent=[min(changes),max(changes)],
        current_over_c=[min(ratios),max(ratios)],
        intervals_below_one=sum(row['current_over_baseline']['ci95'][1]<1 for row in rows),
        cases=len(rows)))
a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(summary,indent=2)+'\n')
print('| Model | Time saved vs prior Ada | Current / C | CI below 1 |')
print('| --- | ---: | ---: | ---: |')
for row in summary['models']:
    lo,hi = row['time_reduction_percent']; c0,c1 = row['current_over_c']
    print(f"| `{row['model']}` | {lo:.1f}–{hi:.1f}% | {c0:.2f}–{c1:.2f}× | {row['intervals_below_one']}/{row['cases']} |")
