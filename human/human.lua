--[[
    script to pause during auto missions and yaw toward home before resuming
    use SCRIPT_TIME command 25 to activate; timeout argument is pause time
]]

local RUN_INTERVAL_MS = 100
local TRIGGER_CMD = 25
local MAV_SEVERITY_INFO = 6
local NAV_SCRIPT_TIME_CMD = 42702

local target_pos = nil
local is_running = false
local last_id = -1

function update()
    if not arming:is_armed() then return update, RUN_INTERVAL_MS end

    local loc = ahrs:get_location()
    local home = ahrs:get_home()
    if not loc or not home then return update, RUN_INTERVAL_MS end

    if is_running then
        if mission:get_current_nav_id() ~= NAV_SCRIPT_TIME_CMD then
            is_running = false
            target_pos = nil
            gcs:send_text(MAV_SEVERITY_INFO, "SCRIPT_TIME: Complete")
            return update, RUN_INTERVAL_MS
        end

        if not target_pos then
            gcs:send_text(MAV_SEVERITY_INFO, "SCRIPT_TIME: Invalid target position")
            is_running = false
            return update, RUN_INTERVAL_MS
        end

        local yaw_target = math.deg(loc:get_bearing(home))
        vehicle:set_target_pos_NED(target_pos, true, yaw_target, false, 0, false, false)
        return update, RUN_INTERVAL_MS
    end

    local id, cmd, arg1, arg2, arg3, arg4 = vehicle:nav_script_time()
    if id then
        if id ~= last_id and cmd == TRIGGER_CMD then
            target_pos = ahrs:get_relative_position_NED_origin()
            is_running = true
            last_id = id
            gcs:send_text(MAV_SEVERITY_INFO, "SCRIPT_TIME: Pointing toward home")
        end
    end

    return update, RUN_INTERVAL_MS
end

gcs:send_text(MAV_SEVERITY_INFO, "Yaw->Home: Script loaded (human version)")

return update()
