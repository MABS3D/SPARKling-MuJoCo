# Rebuilds the C table dumpers, regenerates the tables and the Ada units, and
# fails if anything checked in is out of date (spec 2.8).
# Native tools write diagnostics to stderr; PowerShell 5.1 would abort on them
# under "Stop", so every native call is followed by an explicit exit-code check.
$ErrorActionPreference = "Continue"
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
New-Item -ItemType Directory -Force obj\tools | Out-Null

# The C compiler is the one bundled with the Alire GNAT toolchain (alr exec resolves it).
alr exec -- gcc -std=c11 -Wall -I mujoco\include tools\xmacro_dump.c -o obj\tools\xmacro_dump.exe
if ($LASTEXITCODE -ne 0) { exit 1 }
alr exec -- gcc -std=c11 -Wall -I mujoco\include tools\layout_dump.c -o obj\tools\layout_dump.exe
if ($LASTEXITCODE -ne 0) { exit 1 }

& obj\tools\xmacro_dump.exe tools\fields.txt
if ($LASTEXITCODE -ne 0) { exit 1 }
& obj\tools\layout_dump.exe tools\layout.txt
if ($LASTEXITCODE -ne 0) { exit 1 }

$python = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
if (-not (Test-Path $python)) { $python = "python" }
& $python tools\gen.py
if ($LASTEXITCODE -ne 0) { exit 1 }

git diff --exit-code --stat -- tools\fields.txt tools\layout.txt tools\refs.txt src\gen tests\gen
if ($LASTEXITCODE -ne 0) { Write-Host "generated files are out of date: run tools\check-gen.ps1 and commit"; exit 1 }
Write-Host "generated files are up to date"
