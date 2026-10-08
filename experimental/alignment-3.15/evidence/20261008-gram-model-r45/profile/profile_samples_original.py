"""Map native gmon histogram samples when gprof's line table is unavailable.

Only little-endian 64-bit glibc GMON_VERSION=1 is supported, using the layout
in sys/gmon_out.h. Four-byte (or wider) sample bins and inlining make this
approximate source attribution, not an exact instruction-cost measurement.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--gmon", type=Path, required=True)
    parser.add_argument("--symbol", required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    elf = args.binary.read_bytes()[:16]
    assert elf[:4] == b"\x7fELF" and elf[4:6] == b"\x02\x01", "Expected ELF64 little-endian"
    raw = args.gmon.read_bytes()
    assert raw[:4] == b"gmon" and struct.unpack_from("<I", raw, 4)[0] == 1
    position, histograms, arcs = 20, [], 0
    while position < len(raw):
        tag = raw[position]
        position += 1
        if tag == 0:
            low, high, count, rate, dimension, unit = struct.unpack_from("<QQII15sc", raw, position)
            position += 40
            assert high > low and count > 0 and rate > 0
            assert position + 2 * count <= len(raw)
            samples = struct.unpack_from("<" + str(count) + "H", raw, position)
            position += 2 * count
            histograms.append((low, high, count, rate, samples))
        elif tag == 1:
            assert position + 20 <= len(raw)
            position += 20
            arcs += 1
        else:
            raise ValueError("Unsupported gmon record: " + str(tag))
    assert position == len(raw) and len(histograms) == 1
    low, high, count, rate, samples = histograms[0]
    symbols = []
    command = ["nm", "-n", "-S", "--defined-only", str(args.binary)]
    for line in subprocess.check_output(command, text=True).splitlines():
        fields = line.split()
        if len(fields) == 4 and fields[2] in ("t", "T"):
            symbols.append((int(fields[0], 16), int(fields[1], 16), fields[3]))
    matches = [item for item in symbols if item[2] == args.symbol]
    assert len(matches) == 1 and matches[0][1] > 0, "Expected one sized text symbol"
    start, size, _ = matches[0]
    end = start + size
    selected = []
    for index, ticks in enumerate(samples):
        address = low + ((2 * index + 1) * (high - low)) // (2 * count)
        if ticks and start <= address < end:
            selected.append((address, ticks))
    locations = subprocess.check_output(
        ["addr2line", "-e", str(args.binary), *[hex(address) for address, _ in selected]],
        text=True).splitlines() if selected else []
    assert len(locations) == len(selected)
    lines = Counter()
    buckets = []
    for (address, ticks), location in zip(selected, locations, strict=True):
        lines[location] += ticks
        buckets.append(dict(address=hex(address), samples=ticks, location=location))
    total, selected_total = sum(samples), sum(ticks for _, ticks in selected)
    receipt = dict(binary_sha256=sha(args.binary), gmon_sha256=sha(args.gmon),
                   runner_sha256=sha(Path(__file__)), symbol=args.symbol,
                   symbol_start=hex(start), symbol_end=hex(end), rate_hz=rate,
                   symbol_size_bytes=size, symbol_range_source="ELF symbol size; excludes padding and adjacent symbols",
                   histogram_low=hex(low), histogram_high=hex(high), histogram_bins=count,
                   bin_bytes=(high-low)/count, total_samples=total,
                   selected_samples=selected_total,
                   selected_percent=100*selected_total/total if total else None,
                   arc_records=arcs, nm_command=command,
                   lines=dict(lines.most_common()), buckets=buckets,
                   scope="Approximate instrumented histogram attribution; no release timing or exact guard-cost claim")
    args.out.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({key: receipt[key] for key in ("total_samples", "selected_samples", "selected_percent", "bin_bytes")}))


if __name__ == "__main__":
    main()
