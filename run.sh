#!/bin/bash

BATTERY_FILE="/var/www/html/battery.txt"
PERCENT=100

# Load weights (modify as needed)
LED_LOAD=1
FAN_LOAD=2
AC_LOAD=5
GEYSER_LOAD=7

# Appliance usage (0 = OFF, 1 = ON)
LED=1
FAN=1
AC=0
GEYSER=0

# Calculate total load factor
LOAD=$(( (LED * LED_LOAD) + (FAN * FAN_LOAD) + (AC * AC_LOAD) + (GEYSER * GEYSER_LOAD) ))

# Discharge rate: how many seconds between each 1% drop
# The more load, the faster the drain (minimum 1 second)
[[ $LOAD -eq 0 ]] && LOAD=1
INTERVAL=$(( 3600 / (100 / LOAD) ))  # dynamic discharge rate over 1 hour

while [ $PERCENT -ge 0 ]; do
    echo $PERCENT > "$BATTERY_FILE"
    sleep $INTERVAL
    ((PERCENT--))
done
