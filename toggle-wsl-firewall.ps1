Write-Host "Checking for WSL vEthernet interface..." -ForegroundColor Cyan

$wslInterface = (Get-NetAdapter | Where-Object { $_.Name -like "vEthernet (WSL*" } | Select-Object -First 1).Name

if (-not $wslInterface) {
    Write-Host "Error: Could not detect WSL vEthernet interface." -ForegroundColor Red
    exit 1
}

Write-Host "Detected interface: $wslInterface" -ForegroundColor Green
Write-Host ""

$firewallProfiles = Get-NetFirewallProfile
$currentState = $false

foreach ($p in $firewallProfiles) {
    if ($p.DisabledInterfaceAliases -contains $wslInterface) {
        $currentState = $true
    }
}

if ($currentState) {
    Write-Host "Current status: Firewall is DISABLED for $wslInterface" -ForegroundColor Yellow
} else {
    Write-Host "Current status: Firewall is ENABLED for $wslInterface" -ForegroundColor Green
}

Write-Host ""
$action = Read-Host "What do you want to do? (disable / enable / exit)"

switch ($action.ToLower()) {
    "disable" {
        Write-Host "Disabling firewall for $wslInterface ..." -ForegroundColor Cyan
        Set-NetFirewallProfile -DisabledInterfaceAliases $wslInterface
        Write-Host "Firewall disabled for $wslInterface" -ForegroundColor Green
    }
    "enable" {
        Write-Host "Enabling firewall for $wslInterface ..." -ForegroundColor Cyan

        netsh advfirewall set domainprofile state on | Out-Null
        netsh advfirewall set privateprofile state on | Out-Null
        netsh advfirewall set publicprofile state on | Out-Null

        $disabled = Get-NetFirewallProfile | Select-Object -ExpandProperty DisabledInterfaceAliases | Where-Object { $_ -eq $wslInterface }
        if ($disabled) {
            Write-Host "Clearing interface from DisabledInterfaceAliases..." -ForegroundColor Yellow
            foreach ($profile in @("Domain","Private","Public")) {
                Set-NetFirewallProfile -Profile $profile -DisabledInterfaceAliases @()
            }
        }

        Write-Host "Firewall successfully re-enabled for $wslInterface" -ForegroundColor Green
    }

    default {
        Write-Host "No changes made. Exiting." -ForegroundColor Yellow
    }
}

Write-Host "Done."
