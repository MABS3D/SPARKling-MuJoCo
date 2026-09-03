# Runs gnatprove over the library and enforces the two proof rules of spec 2.2:
#   1. zero unproved checks (gnatprove exits non-zero via --checks-as-errors)
#   2. every pragma Annotate (GNATprove, ...) has a bullet in docs/proof-justifications.md
param([string[]]$Extra = @(), [int]$Jobs = 4, [int]$CapMB = 8000, [int]$TimeoutSec = 3600)
# gnatprove reports on stderr; PowerShell 5.1 would abort on that under "Stop".
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
# Always under the memory guard, and never -j0: a runaway gnat1/gnatwhy3 took this
# machine down on 2026-09-03 (see tools/guarded.ps1 and docs/toolchain.md).
& .\tools\guarded.ps1 -CapMB $CapMB -TimeoutSec $TimeoutSec -- alr exec -- gnatprove -P sparkling_mujoco.gpr `
    -XSPARKLING_BUILD_MODE=development "-j$Jobs" --level=2 --timeout=60 --report=fail `
    --checks-as-errors=on --warnings=continue @Extra
if ($LASTEXITCODE -ne 0) { Write-Host "PROOF FAILED (exit $LASTEXITCODE; 99 = watchdog)"; exit 1 }

$annotations = @(Get-ChildItem src -Recurse -Include *.ads, *.adb |
    Select-String -Pattern 'Annotate\s*\(\s*GNATprove' | Where-Object { $_.Line -notmatch '^\s*--' })
$ledger = @(Get-Content docs\proof-justifications.md | Select-String -Pattern '^- ')
if ($annotations.Count -ne $ledger.Count) {
    Write-Host ("{0} Annotate pragma(s) but {1} ledger entr(ies) in docs/proof-justifications.md" -f $annotations.Count, $ledger.Count)
    $annotations | ForEach-Object { Write-Host ("  {0}:{1}" -f $_.Path, $_.LineNumber) }
    exit 1
}
Write-Host ("PROOF OK: {0} justification(s), all documented" -f $annotations.Count)
