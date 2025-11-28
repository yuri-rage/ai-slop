# Pause + Face-Home Lua Script for ArduPilot

This script allows a mission to pause for a user-defined time and rotate to face the Home location, then continue automatically.

## Requirements
- ArduPilot Copter 4.2 or newer
- SD card installed
- Scripting enabled

### Enable scripting in Mission Planner
1. Open Mission Planner
2. Go to **Config → Full Parameter List**
3. Find `SCR_ENABLE` and set it to `1`.

Reboot the flight controller once.

## Installing the script
1. Download the script
2. Copy it to the SD card:

```
APM/scripts/pause_yaw_home.lua
```

Reboot the flight controller.

## Using it in a mission

### Mission Planner
1. Add a waypoint.
2. Change command to:

```
SCRIPT_TIME (NAV_SCRIPT_TIME)
```

3. Set **Param 2** to pause duration in seconds.

Example: `10` = pause for 10 seconds.

### QGroundControl
1. Add a mission item.
2. Select:

```
MAV_CMD_NAV_SCRIPT_TIME
```

3. Set the **Timeout** field.

## What happens during the pause?
- The vehicle stops in place
- Turns to face Home
- Holds until timer expires
- Continues to the next waypoint automatically

## Troubleshooting

| Problem | Solution |
|--------|----------|
| Script never runs | `SCR_ENABLE` must be 1 |
| Drone doesn’t pause | Param 2 must be > 0 |
| Drone doesn’t yaw | GPS lock + home must exist |

## Safety Notes
- Works only in AUTO mode
- Cleanly cancels if disarmed
- Requires GPS Home

