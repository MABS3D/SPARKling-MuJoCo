param([string]$Mode = "validation")
# gprbuild warns on stderr; PowerShell 5.1 would abort on that under "Stop".
$ErrorActionPreference = "Continue"
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
# Under the memory guard with bounded parallelism (see docs/toolchain.md, "Memory guard").
& (Join-Path $PSScriptRoot "..\tools\guarded.ps1") -CapMB 4000 -TimeoutSec 900 -- alr exec -- gprbuild -P tests/tests.gpr "-XSPARKLING_BUILD_MODE=$Mode" -j4 -p -q
if ($LASTEXITCODE -ne 0) { Write-Host "test build failed (exit $LASTEXITCODE; 99 = watchdog)"; exit 1 }
$failed = 0
Get-ChildItem bin -Filter "test_*.exe" | Sort-Object Name | ForEach-Object {
    Write-Host "== $($_.Name)"
    & $_.FullName
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -ne 0) { Write-Host "$failed test program(s) failed"; exit 1 }
Write-Host "all test programs passed"
