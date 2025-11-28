-- copter_pause_face_home.lua
--
-- Use NAV_SCRIPT_TIME to pause an Auto mission for a user-specified time.
-- While paused, Copter holds position and yaws to face HOME, then continues
-- the mission when the time expires.
--
-- Usage (mission item NAV_SCRIPT_TIME / MAV_CMD_NAV_SCRIPT_TIME):
--   Param1 (Command):   any value (not used by this script)
--   Param2 (Timeout):   pause duration in seconds (this script uses it)
--   Param3..6 (Args):   unused by this script (can be left 0)
--
-- Requirements:
--   - Copter 4.2+ (NAV_SCRIPT_TIME and Lua scripting)
--   - SCR_ENABLE = 1
--   - Script placed in APM/scripts and board rebooted

local interval_ms      = 100 -- script update interval (ms)
local stage            = 0 -- simple state machine
local last_auto_id
local pause_start_ms
local pause_duration_s = 0
local target_yaw_deg   = 0
local target_pos       = nil

-- pre-allocated zero vectors for velocity and acceleration
local zero_vec         = Vector3f()
zero_vec:x(0)
zero_vec:y(0)
zero_vec:z(0)

-- compute heading from current position toward home in degrees [0,360)
local function compute_home_bearing_deg()
    local home = ahrs:get_home()
    local pos  = ahrs:get_position()

    if not home or not pos then
        return nil
    end

    -- bearing from current position to home
    local bearing_rad = pos:get_bearing(home) -- radians
    if not bearing_rad then
        return nil
    end

    local bearing_deg = math.deg(bearing_rad)
    if bearing_deg < 0 then
        bearing_deg = bearing_deg + 360.0
    elseif bearing_deg >= 360.0 then
        bearing_deg = bearing_deg - 360.0
    end

    return bearing_deg
end

local function reset_state()
    stage            = 0
    last_auto_id     = nil
    pause_start_ms   = nil
    pause_duration_s = 0
    target_pos       = nil
end

local function update()
    local now_ms = millis()

    -- Check whether we are currently executing a NAV_SCRIPT_TIME
    -- nav_script_time() returns:
    --   id, cmd, param2(timeout), param3, param4, param5
    -- We treat param2 (3rd returned value) as "pause duration" in seconds.
    local auto_id, script_cmd, timeout_s, arg1, arg2, arg3 = vehicle:nav_script_time()

    if (not arming:is_armed()) or (not auto_id) then
        -- Not armed or not executing a NAV_SCRIPT_TIME command
        reset_state()
        return update, interval_ms
    end

    if stage == 0 then
        --------------------------------------------------------------------
        -- Stage 0: initialize pause and yaw target
        --------------------------------------------------------------------
        last_auto_id = auto_id

        pause_duration_s = timeout_s or 0
        -- Optional fallback: if timeout_s == 0, allow Arg1 (param3) to hold the time
        if (pause_duration_s <= 0) and arg1 and (arg1 > 0) then
            pause_duration_s = arg1
        end

        -- If no positive pause duration was provided, just mark done and skip
        if pause_duration_s <= 0 then
            gcs:send_text(5, "PauseYaw: zero timeout, skipping")
            vehicle:nav_script_time_done(last_auto_id)
            stage = 3
            return update, interval_ms
        end

        -- Compute yaw toward home
        local bearing_deg = compute_home_bearing_deg()
        if not bearing_deg then
            gcs:send_text(5, "PauseYaw: no home/position, abort")
            vehicle:nav_script_time_done(last_auto_id)
            stage = 3
            return update, interval_ms
        end
        target_yaw_deg = bearing_deg

        -- Capture current NED position (relative to EKF origin) to hold position
        local rel_pos_NED = ahrs:get_relative_position_NED_origin()
        if not rel_pos_NED then
            gcs:send_text(5, "PauseYaw: no NED pos, abort")
            vehicle:nav_script_time_done(last_auto_id)
            stage = 3
            return update, interval_ms
        end
        target_pos = rel_pos_NED

        -- Enable navigation scripting control
        vehicle:nav_scripting_enable(1)

        pause_start_ms = now_ms
        gcs:send_text(5, string.format("PauseYaw: holding for %.1f s", pause_duration_s))

        stage = 1
    elseif stage == 1 then
        --------------------------------------------------------------------
        -- Stage 1: actively hold pos & yaw toward home until time expires
        --------------------------------------------------------------------
        if target_pos then
            -- Hold current NED position, zero velocity/accel, yaw toward home
            vehicle:set_target_posvelaccel_NED(
                target_pos,
                zero_vec,
                zero_vec,
                true,           -- use_pos
                target_yaw_deg, -- yaw target (deg)
                false,          -- use_yaw_rate
                0,              -- yaw_rate (ignored)
                false           -- use_thrust
            )
        end

        if pause_start_ms then
            local elapsed_s = (now_ms - pause_start_ms):tofloat() / 1000.0
            if elapsed_s >= pause_duration_s then
                stage = 2
            end
        end
    elseif stage == 2 then
        --------------------------------------------------------------------
        -- Stage 2: release control and mark SCRIPT_TIME complete
        --------------------------------------------------------------------
        vehicle:nav_scripting_enable(0)

        if last_auto_id then
            vehicle:nav_script_time_done(last_auto_id)
        end

        gcs:send_text(5, "PauseYaw: done")
        stage = 3
    end

    return update, interval_ms
end

return update, interval_ms
