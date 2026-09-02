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

# --- generator and diff are added in Task 4 ---
Write-Host "tables regenerated"
