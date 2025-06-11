# Config
$RepoPath = "https://github.com/Sys-Dev-Ops/battery-simulator.git"
$BatteryFile = Join-Path $RepoPath "battery.txt"
$Percent = 100

# Appliance weights
$Weights = @{
    LED     = 1
    FAN     = 2
    AC      = 5
    GEYSER  = 7
}

# Appliance states (set 0 or 1)
$Appliances = @{
    LED     = 1
    FAN     = 1
    AC      = 0
    GEYSER  = 0
}

# Compute total load
$TotalLoad = 0
foreach ($key in $Appliances.Keys) {
    $TotalLoad += $Appliances[$key] * $Weights[$key]
}

if ($TotalLoad -eq 0) { $TotalLoad = 1 }

# Discharge interval based on load
$Interval = [Math]::Max(1, [Math]::Round(3600 / (100 / $TotalLoad)))

# Start simulation
Set-Location $RepoPath
while ($Percent -ge 0) {
    "$Percent" | Set-Content $BatteryFile -Encoding utf8
    git add battery.txt
    git commit -m "Battery update: $Percent%" --quiet
    git push origin main
    Start-Sleep -Seconds $Interval
    $Percent--
}
