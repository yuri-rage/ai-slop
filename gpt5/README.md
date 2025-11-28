# Pause + Face-Home Lua Script for ArduPilot
### Automatically pause a mission, rotate toward Home, then continue

This Lua script adds a simple but powerful capability to ArduPilot **Copter** missions:  
When the mission reaches a designated waypoint, the vehicle will:

1. **Hold position**
2. **Rotate to face the Home location**
3. **Pause for a user-defined number of seconds**
4. **Continue the mission automatically**

No pilot input, no special flight mode changes, and no extra hardware.

---

## ✨ Why this script is useful

Typical use cases include:

- Aerial photography alignment  
- Giving time for sensors to stabilize  
- Survey missions that need timed pauses  
- Paused orientation before landing  
- Time for ground crew to verify attitude or payload

This behavior is normally difficult to achieve with mission items alone.  
This script makes it straightforward and reliable.

---

## 🚁 Requirements

- ArduPilot **Copter 4.2 or newer**
- Flight controller with an SD card
- Mission Planner or QGroundControl
- Scripting enabled

Enable scripting (only required once):

1. Connect to the vehicle in **Mission Planner**
2. Go to: `Config → Full Parameter List`
3. Set:

```
SCR_ENABLE = 1
```

4. Reboot the flight controller

---

## 📥 Installation

1. Download the file `pause_yaw_home.lua`
2. Copy it to the SD card at:

```
APM/scripts/pause_yaw_home.lua
```

3. Reboot the flight controller

That’s it. No configuration menus or parameter tuning are required.

---

## 🧭 Using the script in a mission

The script activates when a mission uses the command:

```
NAV_SCRIPT_TIME
```

Also known as:

- SCRIPT_TIME (Mission Planner)
- MAV_CMD_NAV_SCRIPT_TIME (QGroundControl)

You only need to set **one value**:

### Param 2 = pause duration in seconds

Examples:

| Param 2 | Behavior |
|---------|----------|
| 3       | Pause for 3 seconds |
| 10      | Pause for 10 seconds |
| 30      | Pause for 30 seconds |

If Param 2 is zero, the script ignores the command and the mission continues.

---

## ✔️ Example Mission Flow

1. Waypoint 1 – climb to altitude  
2. **SCRIPT_TIME, Param2 = 8**  
   (Drone pauses, faces Home for 8s)  
3. Waypoint 2 – continue mission  

Nothing else is required.

---

## 🧩 What the script actually does

On reaching the SCRIPT_TIME command:

- Enables scripting control
- Freeze position using EKF NED frame
- Calculates the heading from current position → Home
- Rotates to align with that bearing
- Runs a timer for Param2 seconds
- Releases scripting control
- Resumes mission execution

If the vehicle becomes disarmed or loses staging conditions, the script safely stops.

---

## 🛡 Safety behavior

- Works only in **AUTO** mode
- Cancels gracefully if:
  - GPS/Home is unavailable
  - Disarmed
  - Timeout invalid
- Does **not** override manual safety actions

You can always switch modes to take over immediately.

---

## 🧪 Recommended First Flight Test

1. Use a short pause (3–5 seconds)
2. Test in a safe area
3. Confirm yaw behavior
4. Increase pause duration as desired

Mission resume timing and yaw should be smooth and stable.

---

## 🔧 Troubleshooting

| Problem | Fix |
|--------|-----|
| The drone doesn’t pause | Param2 must be > 0 |
| Script never runs | `SCR_ENABLE` must be 1 |
| Doesn’t face Home | Must have GPS + Home |
| Script won’t activate | Must be in AUTO |

If the script aborts for any reason, the mission continues normally.

---

## 📂 File Structure

Your SD card should contain:

```
APM/
 └── scripts/
      └── pause_yaw_home.lua
```

---

## 📘 Example Mission (MP Format)

```
WP   SCRIPT_TIME   0   10   0   0   0   0
```

This pauses for 10 seconds.

---

## 📝 Notes

- This script operates entirely onboard
- No telem link required after upload
- Does not interfere with other mission items

---

## 💡 Want more features?

Possible extensions (just ask):

- Face next waypoint instead of Home
- Pause until RC switch toggles
- Trigger camera shutter during pause
- Apply yaw offset (e.g. +90°)
- Work for Plane or Rover

---
