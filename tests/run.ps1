param([string]$Mode = "validation")
# gprbuild warns on stderr; PowerShell 5.1 would abort on that under "Stop".
$ErrorActionPreference = "Continue"
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
alr exec -- gprbuild -P tests/tests.gpr "-XSPARKLING_BUILD_MODE=$Mode" -p -q
if ($LASTEXITCODE -ne 0) { Write-Host "test build failed"; exit 1 }
$failed = 0
Get-ChildItem bin -Filter "test_*.exe" | Sort-Object Name | ForEach-Object {
    Write-Host "== $($_.Name)"
    & $_.FullName
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -ne 0) { Write-Host "$failed test program(s) failed"; exit 1 }
Write-Host "all test programs passed"
