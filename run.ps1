$BatteryFile = "C:\inetpub\wwwroot\battery.txt"
$Percent = 100

# Load weights
$LoadWeights = @{
    LED     = 1
    FAN     = 2
    AC      = 5
    GEYSER  = 7
}

# Appliance status (1 = ON, 0 = OFF)
$Appliances = @{
    LED     = 1
    FAN     = 1
    AC      = 0
    GEYSER  = 0
}

# Compute total load
$TotalLoad = 0
foreach ($item in $Appliances.Keys) {
    $TotalLoad += $Appliances[$item] * $LoadWeights[$item]
}

if ($TotalLoad -eq 0) { $TotalLoad = 1 }

# Discharge interval in seconds
$Interval = [math]::Max(1, [math]::Round(3600 / (100 / $TotalLoad)))

# Simulate battery drain
Set-Content -Path $BatteryFile -Value $Percent
while ($Percent -ge 0) {
    Set-Content -Path $BatteryFile -Value $Percent
    Start-Sleep -Seconds $Interval
    $Percent--
}
