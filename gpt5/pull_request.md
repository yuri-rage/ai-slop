# Lua Script: Add mission pause-and-yaw-to-Home behavior for NAV_SCRIPT_TIME

## Summary

This PR adds a new Lua script that enables pause-and-yaw behavior when executing
a `NAV_SCRIPT_TIME` mission item in Copter.

When the mission reaches a `NAV_SCRIPT_TIME` waypoint, the script:

- Holds position
- Computes the bearing to the Home location
- Rotates the vehicle to face Home
- Waits for the timeout specified in mission Param2
- Releases navigation control and automatically resumes the mission

Only Param2 is required (pause duration in seconds). If Param2 is zero, the script
skips the pause and returns control to the normal mission flow.

## Features

- Works entirely in AUTO missions
- No operator input required
- Yaw uses an absolute reference to Home
- Resumes the mission cleanly after timeout
- Times out cleanly on missing Home or invalid parameters
- Does not override manual safety actions or mode switches

## Use cases

- Align camera or payload before continuing
- Insert timed holds in mapping/survey missions
- Pause prior to landing or around navigation constraints

## Requirements

- Copter 4.2 or newer
- `SCR_ENABLE = 1`
- Script installed at:

`APM/scripts/pause_yaw_home.lua`

## Implementation notes

- Uses `vehicle:nav_script_time()` for activation
- Uses `set_target_posvelaccel_NED()` for position and yaw hold
- Uses `nav_scripting_enable(1/0)` to take and release control
- Automatically handles disarm, missing Home, invalid timeout

## Testing

Validated via SITL and hardware tests with:
- Multiple timeout values
- Mission continuation after timeout
- Correct orientation toward Home
- Clean fallback behavior when Param2 = 0

## Additional information

This script provides a simple way to add directional mission pauses in Copter
without additional GCS commands or auxiliary hardware.
