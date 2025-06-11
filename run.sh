#!/bin/bash
# run.sh - Shell script for Linux to simulate battery drain and appliance states

BATTERY_FILE="battery.txt"
APPLIANCES_FILE="appliances.json"
GITHUB_REPO="https://github.com/Sys-Dev-Ops/battery-simulator.git"
LOCAL_REPO="battery-simulator"

# Clone repo if not already cloned
if [ ! -d "$LOCAL_REPO" ]; then
  git clone "$GITHUB_REPO"
fi
cd "$LOCAL_REPO"

# Initialize files if missing
if [ ! -f "$BATTERY_FILE" ]; then
  echo 100 > "$BATTERY_FILE"
fi

if [ ! -f "$APPLIANCES_FILE" ]; then
  cat <<EOF > "$APPLIANCES_FILE"
{
  "LED": false,
  "FAN": false,
  "AC": false,
  "GEYSER": false
}
EOF
fi

PERCENT=$(cat "$BATTERY_FILE")

# Load appliance power draw values (watts)
declare -A power_draw=(
  [LED]=5
  [FAN]=40
  [AC]=2000
  [GEYSER]=1500
)

# Discharge every 10 seconds
while [ "$PERCENT" -gt 0 ]; do
  # Read appliance state
  STATES=$(jq -r 'to_entries[] | select(.value == true) | .key' "$APPLIANCES_FILE")
  LOAD=0
  for APP in $STATES; do
    LOAD=$((LOAD + power_draw[$APP]))
  done

  # Calculate discharge rate (scale load to battery percentage drain)
  let "DRAIN = LOAD / 500" # Simple conversion
  [ "$DRAIN" -lt 1 ] && DRAIN=1
  let "PERCENT = PERCENT - DRAIN"
  [ "$PERCENT" -lt 0 ] && PERCENT=0

  echo "$PERCENT" > "$BATTERY_FILE"

  git add "$BATTERY_FILE" "$APPLIANCES_FILE"
  git commit -m "Update battery to $PERCENT%" >/dev/null 2>&1
  git push origin main

  echo "[$(date +%T)] 🔋 Battery: $PERCENT% (Load: $LOAD W)"
  sleep 10
done
