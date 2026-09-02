# Runs gnatprove over the library and enforces the two proof rules of spec 2.2:
#   1. zero unproved checks (gnatprove exits non-zero via --checks-as-errors)
#   2. every pragma Annotate (GNATprove, ...) has a bullet in docs/proof-justifications.md
param([string[]]$Extra = @())
# gnatprove reports on stderr; PowerShell 5.1 would abort on that under "Stop".
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
alr exec -- gnatprove -P sparkling_mujoco.gpr -XSPARKLING_BUILD_MODE=development `
    -j0 --level=2 --timeout=60 --report=fail --checks-as-errors=on --warnings=continue @Extra
if ($LASTEXITCODE -ne 0) { Write-Host "PROOF FAILED"; exit 1 }

$annotations = @(Get-ChildItem src -Recurse -Include *.ads, *.adb |
    Select-String -Pattern 'Annotate\s*\(\s*GNATprove' | Where-Object { $_.Line -notmatch '^\s*--' })
$ledger = @(Get-Content docs\proof-justifications.md | Select-String -Pattern '^- ')
if ($annotations.Count -ne $ledger.Count) {
    Write-Host ("{0} Annotate pragma(s) but {1} ledger entr(ies) in docs/proof-justifications.md" -f $annotations.Count, $ledger.Count)
    $annotations | ForEach-Object { Write-Host ("  {0}:{1}" -f $_.Path, $_.LineNumber) }
    exit 1
}
Write-Host ("PROOF OK: {0} justification(s), all documented" -f $annotations.Count)
