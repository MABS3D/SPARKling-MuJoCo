# Runs a toolchain command under a memory watchdog.
#
#   .\tools\guarded.ps1 -CapMB 6000 -TimeoutSec 600 -- alr exec -- gprbuild -P ... -j1
#
# Every second it samples every gnat1/gnatwhy3/gnat2why/z3/cvc5/alt-ergo/colibri
# process on the machine. If any of them exceeds CapMB of private memory, or the
# command runs longer than TimeoutSec, the whole tool process tree is killed and
# the script exits 99. Otherwise it reports peak memory and elapsed time and
# returns the command's exit code. This exists because gnat1.exe reached 65 GB on
# 2026-09-03 and took the machine down (fixed 4 GB pagefile).
param(
    [int]$CapMB = 6000,
    [int]$TimeoutSec = 900,
    [int]$MinFreeMB = 12000,   # abort when the system's free commit (RAM + pagefile) drops below this
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Command
)
$ErrorActionPreference = "Continue"
$env:Path += ";$env:LOCALAPPDATA\Programs\alr\bin"
$watched = '^(gnat1|gnatwhy3|gnat2why|why3server|z3|cvc5|alt-ergo|colibri|gnatprove|gprbuild)$'

if ($Command.Count -gt 0 -and $Command[0] -eq '--') { $Command = $Command[1..($Command.Count - 1)] }
if ($Command.Count -eq 0) { Write-Error "no command given"; exit 2 }

$exe = $Command[0]
$args = if ($Command.Count -gt 1) { $Command[1..($Command.Count - 1)] } else { @() }
$sw = [Diagnostics.Stopwatch]::StartNew()
$proc = Start-Process -FilePath $exe -ArgumentList $args -NoNewWindow -PassThru
$peakMB = 0
$peakName = ""
$killed = $false
while (-not $proc.HasExited) {
    Start-Sleep -Milliseconds 1000
    $ps = Get-Process | Where-Object { $_.ProcessName -match $watched }
    foreach ($p in $ps) {
        $mb = [math]::Round($p.PrivateMemorySize64 / 1MB)
        if ($mb -gt $peakMB) { $peakMB = $mb; $peakName = "$($p.ProcessName)($($p.Id))" }
        if ($mb -gt $CapMB) {
            Write-Host ("WATCHDOG: {0} at {1} MB exceeds cap {2} MB after {3:n0} s; killing tool processes" -f $p.ProcessName, $mb, $CapMB, $sw.Elapsed.TotalSeconds)
            $killed = $true
        }
    }
    if (-not $killed -and $sw.Elapsed.TotalSeconds -gt $TimeoutSec) {
        Write-Host ("WATCHDOG: timeout after {0} s; killing tool processes" -f $TimeoutSec)
        $killed = $true
    }
    if (-not $killed) {
        $freeMB = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory / 1024)
        if ($freeMB -lt $MinFreeMB) {
            Write-Host ("WATCHDOG: only {0} MB of commit free (floor {1} MB) after {2:n0} s; killing tool processes" -f $freeMB, $MinFreeMB, $sw.Elapsed.TotalSeconds)
            $killed = $true
        }
    }
    if ($killed) {
        Get-Process | Where-Object { $_.ProcessName -match $watched } | Stop-Process -Force -ErrorAction SilentlyContinue
        try { $proc.Kill() } catch {}
        break
    }
}
$sw.Stop()
Write-Host ("guarded: elapsed {0:n1} s, peak {1} MB in {2}" -f $sw.Elapsed.TotalSeconds, $peakMB, $peakName)
if ($killed) { exit 99 }
exit $proc.ExitCode
