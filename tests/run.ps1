param([ValidateSet("development", "validation", "release")][string]$Mode = "validation",
      [ValidateRange(1, 8)][int]$Jobs = 2)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
$python = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
if (-not (Test-Path $python)) { $python = "python" }
# Validate expected executables and freshness even when Alire hides child failures.
& $python tests/run.py --mode $Mode --jobs $Jobs --alire
exit $LASTEXITCODE
