"""Compare raw Ada decoding with every real 3.17 ABI fixture, without skips."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compare(binary, fixtures, out):
    binary, fixtures = binary.resolve(), fixtures.resolve()
    out.mkdir(parents=True, exist_ok=False)
    specification = fixtures / "fixtures.json"
    corpus = json.loads(specification.read_text())
    assert corpus["complete"] and corpus["reference"] == "3.17.0"
    receipt = dict(reference=corpus["reference"], commit=corpus["commit"],
                   corpus_sha256=digest(specification), binary_sha256=digest(binary),
                   runner_sha256=digest(Path(__file__)), cases=[], complete=False, passed=False)
    for case in corpus["cases"]:
        image = fixtures / case["image"]
        assert digest(image) == case["image_sha256"]
        command = [str(binary), str(image)]
        if case.get("mutation"):
            command.append(case["mutation"])
        run = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        (out / (case["name"] + ".stdout")).write_text(run.stdout)
        (out / (case["name"] + ".stderr")).write_text(run.stderr)
        record = dict(name=case["name"], command=command, exit=run.returncode, passed=False)
        receipt["cases"].append(record)
        try:
            assert run.returncode == 0, run.stderr
            rows = {}
            for line in run.stdout.splitlines():
                parts = line.split()
                assert parts and parts[0] not in rows, line
                rows[parts[0]] = parts[1:]
            assert rows["STATUS"] == [case["expected_status"]], rows
            assert rows["ALL_NULL"] == ["TRUE"], rows
            if case["expected_status"] == "OK":
                assert rows["ROUNDTRIP"] == [str(case["expected_roundtrip"]).upper()], rows
                assert rows["VALIDATION"] == [case["expected_validation"]], rows
                assert rows["PERM_VALID"] == [str(not case.get("mutation", "").startswith("perm_")).upper()], rows
                assert rows["TEXTURES_VALID"] == [str(case.get("mutation") != "texture_path").upper()], rows
                expected_keys = set(case["expected"]) | {"STATUS", "ALL_NULL", "ROUNDTRIP", "PERM_VALID", "TEXTURES_VALID", "VALIDATION"}
                assert set(rows) == expected_keys, (set(rows), expected_keys)
                for key, values in case["expected"].items():
                    assert [int(x) for x in rows[key]] == values, (key, rows[key], values)
            else:
                assert set(rows) == {"STATUS", "ALL_NULL"}, rows
            record["passed"] = True
        except (AssertionError, KeyError, ValueError) as error:
            record["error"] = repr(error)
        (out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    assert digest(binary) == receipt["binary_sha256"]
    assert digest(specification) == receipt["corpus_sha256"]
    receipt.update(complete=True, passed=all(case["passed"] for case in receipt["cases"]),
                   scope="Exact raw ABI fields/byte roundtrip, forged-label rejection, and explicit owned-model corruption rejections through Validate; not whole engine correctness.")
    (out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--fixtures", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = compare(args.binary, args.fixtures, args.out)
    print(json.dumps({"complete": result["complete"], "passed": result["passed"], "cases": len(result["cases"])}))
    raise SystemExit(not result["passed"])


if __name__ == "__main__":
    main()
