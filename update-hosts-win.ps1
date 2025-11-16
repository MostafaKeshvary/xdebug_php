param(
    [string]$ManualIP
)
# --- Permission Check Block ---
# Check if hosts file is writable
$hostsFile = "$env:WinDir\System32\drivers\etc\hosts"
$backupTest = "$hostsFile.bak.test"
$header = '# Added by update-hosts-win.ps1'
$footer = '# End of update-hosts-win.ps1'

try
{
    Copy-Item -Path $hostsFile -Destination $backupTest -Force -ErrorAction Stop
    Remove-Item $backupTest -Force -ErrorAction Stop
}
catch
{
    Write-Error "ERROR: Cannot write to HOSTS file or create backup. Run PowerShell as Administrator."
    exit 1
}
# --- End Permission Check Block ---

# Safe Write Function (Prevents corrupt/empty hosts file)
function SafeWrite-Hosts
{
    param(
        [string]$Path,
        [string]$Content
    )

    Start-Sleep -Milliseconds 150  # allow Windows to release lock

    try
    {
        [IO.File]::WriteAllText($Path, $Content, [Text.Encoding]::ASCII)
    }
    catch
    {
        Write-Error "ERROR: Could not write to hosts file. It may be locked by system/antivirus."
        exit 1
    }
}

# save as update-hosts-win.ps1
$backup = "$hostsFile.bak.$((Get-Date).ToString('yyyyMMddHHmmss') )"

Write-Host "Backing up hosts to $backup"
Copy-Item -Path $hostsFile -Destination $backup -Force

# Read whole file
$text = Get-Content $hostsFile -Raw

# Cleanup blank lines (2+ → 1)
$text = [regex]::Replace($text, "(\r?\n){3,}", "`r`n`r`n")

# TEMP CLEAN write (safe)
SafeWrite-Hosts -Path $hostsFile -Content $text

# get candidate Windows IPv4 (exclude virtual adapters)
$ip = $null
if ($ManualIP) {
    $ip = $ManualIP
} else {
    $ip = Get-NetIPAddress `
        | Where-Object {
        $_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -eq 'Dhcp'
    } | Select-Object -First 1 -ExpandProperty IPAddress
}

$ipv4Pattern = '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

if (-not ($ip -match $ipv4Pattern)) {
    Write-Host "ERROR: Invalid IPv4 address. Provide manually with -ManualIP <x.x.x.x>." -ForegroundColor Yellow
    exit 1
}

Write-Host "Detected Windows IP: $ip"

# Read cleaned hosts (line-based)
$content = Get-Content -Path $hostsFile

# Remove ANY previous host.docker / gateway.docker / kubernetes entries or old markers
$cleaned = $content | Where-Object {
    $_ -notmatch 'host\.docker\.internal' -and
            $_ -notmatch 'gateway\.docker\.internal' -and
            $_ -notmatch 'kubernetes\.docker\.internal' -and
            $_ -notmatch $header -and
            $_ -notmatch $footer
}

# Compose new block
$newBlock = @()
$newBlock += $header
$newBlock += "$ip host.docker.internal"
$newBlock += "$ip gateway.docker.internal"
$newBlock += "127.0.0.1 kubernetes.docker.internal"
$newBlock += $footer
$newBlock += ""
$newBlock += ""

# Merge content
$final = @()
$final += $cleaned
$final += $newBlock

# Join to a single CRLF text
$finalText = ($final -join "`r`n")

# Final Safe Write
SafeWrite-Hosts -Path $hostsFile -Content $finalText

Write-Host "hosts file updated successfully."
