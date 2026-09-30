"""Local-only build helpers; no mutations outside this candidate and scratch."""
import os
import hashlib
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
SCRATCH = Path(os.environ.get("SPATIAL_SCRATCH", "/var/tmp/sparkling-spatial-tendons-20260930"))
PIN = "9ecbb9d7b5ee623f54745638d36799ff90e6f7cd"


def environment():
    env = os.environ.copy()
    tc = Path(env.get("SPATIAL_TOOLCHAINS", "/var/tmp/sparkling-matrix-recovery/toolchains"))
    bins = [str(p) for component in ("gnat", "gprbuild", "gnatprove")
            for p in (tc / component).glob("*/bin")]
    env["PATH"] = ":".join(bins + [env["PATH"]])
    env["SPATIAL_BUILD_ROOT"] = str(SCRATCH / "build")
    return env


def build(mode):
    subprocess.run(["gprbuild", "-p", "-P", str(ROOT / "spatial.gpr"),
                    "-XSPATIAL_MODE=" + mode, "-j2"], env=environment(), check=True)
    return SCRATCH / "build" / mode / "bin" / "spatial_probe"


def reference_library():
    import mujoco
    src = REPO / "mujoco"
    head = subprocess.check_output(["git", "-C", str(src), "rev-parse", "HEAD"], text=True).strip()
    if head != PIN or mujoco.__version__ != "3.14.0":
        raise RuntimeError("Requires the pinned MuJoCo 3.14.0 reference and Python wheel")
    subprocess.run(["git", "-C", str(src), "diff", "--exit-code", PIN, "--", "src", "include"],
                   check=True, stdout=subprocess.DEVNULL)
    # Read pinned git blobs, not possibly modified working files, for the oracle.
    original = subprocess.check_output(["git", "-C", str(src), "show",
                                       PIN + ":src/engine/engine_util_misc.c"], text=True)
    extracted = original[:original.index("//------------------------------ misc geometry")]
    SCRATCH.mkdir(parents=True, exist_ok=True)
    reference_dir = Path(tempfile.mkdtemp(prefix="wrap-reference-", dir=SCRATCH))
    oracle = reference_dir / "wrap_reference.c"
    oracle.write_text(extracted)
    lib = next(Path(mujoco.__file__).parent.glob("libmujoco.so*"))
    output = reference_dir / "libwrap_reference.so"
    subprocess.run(["cc", "-std=gnu11", "-O3", "-fPIC", "-shared", "-march=native", "-flto",
                    "-ffp-contract=off", "-DmjUSEPLATFORMSIMD",
                    "-I" + str(src / "include"), "-I" + str(src / "src"), str(oracle),
                    str(src / "src/engine/engine_util_blas.c"),
                    str(src / "src/engine/engine_util_spatial.c"),
                    "-Wl,-Bsymbolic", "-Wl,-rpath," + str(lib.parent), str(lib), "-lm",
                    "-o", str(output)], check=True)
    return output


def source_hashes():
    files = [p for p in ROOT.rglob("*") if p.is_file() and p.suffix in
             (".ads", ".adb", ".gpr", ".py", ".c")]
    files += [REPO / "src" / name for name in ("mj.ads", "mj-types.ads", "mj-quaternion_math.ads")]
    files += [REPO / "mujoco/src/engine" / name for name in
              ("engine_util_misc.c", "engine_core_smooth.c", "engine_util_blas.c", "engine_util_spatial.c")]
    files += list((REPO / "mujoco/include/mujoco").glob("*.h"))
    files += list((REPO / "mujoco/src/engine").glob("*.h"))
    return {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}
