"""Diagnostic wrapping microbenchmark, not an engine-step parity claim."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import statistics
import subprocess
import mujoco
import numpy as np
from common import ROOT, REPO, SCRATCH, PIN, environment, reference_library, source_hashes
from test_spatial import geometry_cases, tokens


def main():
    # Keep both arms on the same allowed logical CPU. Other host activity
    # remains uncontrolled; report samples instead of a whole-engine claim.
    allowed = sorted(os.sched_getaffinity(0))
    os.sched_setaffinity(0, {allowed[-1]})
    before = source_hashes()
    reference = reference_library()
    src = REPO / "mujoco"
    lib = next(Path(mujoco.__file__).parent.glob("libmujoco.so*"))
    cexe = SCRATCH / "wrap_benchmark_c"
    cflags = ["-std=gnu11", "-O3", "-march=native", "-flto", "-ffp-contract=off",
              "-DmjUSEPLATFORMSIMD", "-ffunction-sections", "-fdata-sections"]
    subprocess.run(["gcc", *cflags, "-I"+str(src/"include"), "-I"+str(src/"src"),
                    str(ROOT/"tests/wrap_benchmark.c"), str(reference.parent/"wrap_reference.c"),
                    str(src/"src/engine/engine_util_blas.c"), str(src/"src/engine/engine_util_spatial.c"),
                    "-Wl,--gc-sections", "-Wl,-rpath,"+str(lib.parent), str(lib), "-lm", "-o", str(cexe)], env=environment(), check=True)
    subprocess.run(["gprbuild", "-p", "-P", str(ROOT/"benchmark.gpr"), "-XSPATIAL_MODE=release", "-j2"],
                   env=environment(), check=True)
    ada = SCRATCH/"build/benchmark/bin/wrap_benchmark"
    results = []
    all_cases = geometry_cases()
    for kind, label in ((0,"sphere"),(1,"cylinder")):
        selected = [c for c in all_cases if c[0] == kind][48:304]
        repeats = 20000
        data = f"{len(selected)} {repeats}\n" + "\n".join(tokens([k,r,int(s is not None),
          *a,*b,*c,*m.flat,*(np.zeros(3) if s is None else s)]) for k,r,a,b,c,m,s in selected)+"\n"
        samples = {"ada": [], "c": []}
        checksums = {}
        for rep in range(8):
            for name, exe in (("ada",ada),("c",cexe)) if rep % 2 == 0 else (("c",cexe),("ada",ada)):
                result = subprocess.run([str(exe)], input=data, text=True, capture_output=True, check=True)
                elapsed, checksum = map(float, result.stdout.split())
                if rep:  # discard warm-up for both arms
                    samples[name].append(elapsed*1e9/(len(selected)*repeats))
                checksums[name] = checksum
        np.testing.assert_allclose(checksums["ada"], checksums["c"], rtol=1e-12)
        am, cm = statistics.median(samples["ada"]), statistics.median(samples["c"])
        results.append({"kind":label,"cases":len(selected),"repeats":repeats,
                        "nanoseconds_per_wrap":samples,"median_ada":am,"median_c":cm,
                        "ada_over_c":am/cm,"checksums":checksums})
    output = {"timestamp":datetime.now(timezone.utc).isoformat(),"reference_commit":PIN,
              "scope":"geometry with arc and all six contact-point coordinates consumed; prepared inputs; no full mj_step parity claim", "cflags":cflags,
              "logical_cpu":allowed[-1],
              "c_compiler":subprocess.check_output(["gcc","--version"],env=environment(),text=True).splitlines()[0],
              "ada_compiler":subprocess.check_output(["gcc","--version"],env=environment(),text=True).splitlines()[0],
              "results":results}
    output["sha256"] = source_hashes()
    assert output["sha256"] == before, "Sources changed during benchmark"
    (ROOT/"evidence/benchmark.json").write_text(json.dumps(output,indent=2)+"\n")
    print(json.dumps(output,indent=2))


if __name__ == "__main__": main()
