# Source this file; override CHOLESKY_TOOLCHAINS for another installation.
cholesky_tools=${CHOLESKY_TOOLCHAINS:-/var/tmp/sparkling-matrix-recovery/toolchains}
export PATH="$cholesky_tools/gnat/gnat-x86_64-linux-16.1.0-1/bin:$cholesky_tools/gprbuild/gprbuild-x86_64-linux-26.0.0-1/bin:$cholesky_tools/gnatprove/gnatprove-x86_64-linux-16.1.0-1/bin:$PATH"
