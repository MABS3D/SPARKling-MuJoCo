#!/usr/bin/env python3
"""Inventory a completed full-unit run; passing checks alone do not label Gold."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[1]


def source_hashes():
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted((ROOT / "src").glob("*.ad?"))}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build-root", type=Path,
                    default=Path("/var/tmp/sparkling-cholesky-sparse-band-20260930"))
    ap.add_argument("--begin", action="store_true")
    args = ap.parse_args()
    manifest = args.build_root / "proof-sources.json"
    if args.begin:
        manifest.write_text(json.dumps(dict(started=time.time(), sources_sha256=source_hashes()), indent=2)+"\n")
        return
    before = json.loads(manifest.read_text())
    assert before["sources_sha256"] == source_hashes(), "Sources changed during the proof run"
    units = {}
    for name in ["arithmetic", "band", "sparse"]:
        path = args.build_root / "obj/validation/gnatprove" / ("mj-cholesky_" + name + ".spark")
        assert path.stat().st_mtime >= before["started"], ("stale proof", path)
        report = json.loads(path.read_text())
        assert report["stop_reason"] == "STOP_REASON_NONE", report["stop_reason"]
        assert not report["skip_proof"] and not report["skip_flow_proof"] and not report["pragma_assume"]
        groups = {}
        entities = {int(key): value for key, value in report["entities"].items()}
        for item in report["proof"]:
            ent = entities[item["entity"]]
            label = ent["name"]
            group = groups.setdefault(label, dict(proved=0, open=0, locations=[]))
            if item["severity"] == "info": group["proved"] += 1
            else:
                group["open"] += 1
                group["locations"].append(dict(file=item["file"], line=item["line"],
                                               rule=item["rule"], message=item["message"]["text"]))
        proof_open = [p for p in report["proof"] if p["severity"] != "info"]
        flow_open = [p for p in report["flow"] if p["severity"] in ["low", "medium", "high", "error"]]
        units[name] = dict(proved=len(report["proof"])-len(proof_open), open=len(proof_open),
                           open_by_rule=dict(Counter(p["rule"] for p in proof_open)),
                           flow_open=flow_open, subprograms=groups,
                           project_body_modes={report["entities"][key]["name"]: mode
                               for key, mode in report["spark"].items()
                               if report["entities"][key]["sloc"][0]["file"].startswith("mj-cholesky_")})
    result = dict(completed=time.time(), sources_sha256=source_hashes(), units=units,
                  note="Open obligations remain unfinished proof engineering; not Silver exceptions. "
                       "Per-subprogram success is conditional on called contracts. "
                       "Dots have no ordered functional postcondition yet; global algorithms are candidates.")
    target = args.build_root / "proof-inventory.json"
    target.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({key: {x: value[x] for x in ["proved", "open", "open_by_rule"]}
                      for key, value in units.items()}, indent=2))


if __name__ == "__main__": main()
