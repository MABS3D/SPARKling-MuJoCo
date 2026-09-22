# Prove the whole library in serial unit order with resource and report gates.
param([string[]]$Extra = @(), [ValidateRange(1, 8)][int]$Jobs = 1,
      [int]$CapMB = 4000, [int]$TimeoutSec = 3600)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
$python = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
if (-not (Test-Path $python)) { $python = "python" }
& $python tools/prove.py --alire --jobs $Jobs --cap-mb $CapMB --guard-timeout $TimeoutSec -- @Extra
exit $LASTEXITCODE
