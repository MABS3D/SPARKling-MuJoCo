# Runs a toolchain command under a memory watchdog.
#
#   .\tools\guarded.ps1 -CapMB 6000 -TimeoutSec 600 -- alr exec -- gprbuild -P ... -j1
#
# Every second it samples the processes descending from the launched command
# (gnat1/gnatwhy3/gnat2why/z3/cvc5/alt-ergo/colibri/...). If any of them exceeds
# CapMB of private memory, if the command runs longer than TimeoutSec, or if the
# system's free commit drops below MinFreeMB, that process tree is killed and the
# script exits 99. Otherwise it reports peak memory and elapsed time and returns
# the command's exit code. This exists because gnat1.exe reached 65 GB on
# 2026-09-03 and took the machine down (fixed 4 GB pagefile).
#
# Only the command's own tree is watched and killed, so two guarded runs (for
# example a proof of the project and a measurement on a scratch copy) do not
# kill each other. A process whose parent has already exited stays in the tree.
[CmdletBinding(PositionalBinding = $false)]
param(
    [int]$CapMB = 6000,
    [int]$TimeoutSec = 900,
    [int]$MinFreeMB = 12000,   # abort when the system's free commit (RAM + pagefile) drops below this
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$Command
)
$ErrorActionPreference = "Continue"
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
$watched = '^(gnat1|gnatwhy3|gnat2why|why3server|z3|cvc5|alt-ergo|colibri|gnatprove|gprbuild)$'

if ($Command.Count -gt 0 -and $Command[0] -eq '--') { $Command = $Command[1..($Command.Count - 1)] }
if ($Command.Count -eq 0) { Write-Error "no command given"; exit 2 }

$exe = $Command[0]
$toolArguments = if ($Command.Count -gt 1) { $Command[1..($Command.Count - 1)] } else { @() }
$sw = [Diagnostics.Stopwatch]::StartNew()
# Start-Process joins ArgumentList into a command line. Quote each argument with
# the Windows native argv rules so spaces, quotes and trailing slashes survive.
function ConvertTo-NativeArgument([string]$Value) {
    if ($Value -ne "" -and $Value -notmatch '[\s"]') { return $Value }
    $quotedValue = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $quotedValue = [regex]::Replace($quotedValue, '(\\+)$', '$1$1')
    return '"' + $quotedValue + '"'
}
$startParameters = @{ FilePath = $exe; NoNewWindow = $true; PassThru = $true }
if ($toolArguments.Count -gt 0) {
    $startParameters.ArgumentList = @($toolArguments | ForEach-Object { ConvertTo-NativeArgument $_ })
}
$proc = Start-Process @startParameters
$tree = @{}                 # every process id ever seen below the command (kept after its parent exits)
$tree[[int]$proc.Id] = $true
$peakMB = 0
$peakName = ""
$killed = $false

function Update-Tree {
    $all = Get-CimInstance Win32_Process | Select-Object ProcessId, ParentProcessId, Name
    $grew = $true
    while ($grew) {
        $grew = $false
        foreach ($p in $all) {
            $id = [int]$p.ProcessId
            if (-not $tree.ContainsKey($id) -and $tree.ContainsKey([int]$p.ParentProcessId)) {
                $tree[$id] = $true
                $grew = $true
            }
        }
    }
    return $all | Where-Object { $tree.ContainsKey([int]$_.ProcessId) }
}

while (-not $proc.HasExited) {
    Start-Sleep -Milliseconds 1000
    $members = Update-Tree
    foreach ($m in $members) {
        $name = [IO.Path]::GetFileNameWithoutExtension($m.Name)
        if ($name -notmatch $watched) { continue }
        $p = Get-Process -Id $m.ProcessId -ErrorAction SilentlyContinue
        if ($null -eq $p) { continue }
        $mb = [math]::Round($p.PrivateMemorySize64 / 1MB)
        if ($mb -gt $peakMB) { $peakMB = $mb; $peakName = "$name($($p.Id))" }
        if ($mb -gt $CapMB) {
            Write-Host ("WATCHDOG: {0} at {1} MB exceeds cap {2} MB after {3:n0} s; killing the tool tree" -f $name, $mb, $CapMB, $sw.Elapsed.TotalSeconds)
            $killed = $true
        }
    }
    if (-not $killed -and $sw.Elapsed.TotalSeconds -gt $TimeoutSec) {
        Write-Host ("WATCHDOG: timeout after {0} s; killing the tool tree" -f $TimeoutSec)
        $killed = $true
    }
    if (-not $killed) {
        $freeMB = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory / 1024)
        if ($freeMB -lt $MinFreeMB) {
            Write-Host ("WATCHDOG: only {0} MB of commit free (floor {1} MB) after {2:n0} s; killing the tool tree" -f $freeMB, $MinFreeMB, $sw.Elapsed.TotalSeconds)
            $killed = $true
        }
    }
    if ($killed) {
        foreach ($id in @($tree.Keys)) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue }
        try { $proc.Kill() } catch {}
        break
    }
}
$sw.Stop()
Write-Host ("guarded: elapsed {0:n1} s, peak {1} MB in {2}" -f $sw.Elapsed.TotalSeconds, $peakMB, $peakName)
if ($killed) { exit 99 }
exit $proc.ExitCode
