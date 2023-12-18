local baud_rate = 115200

local port = assert(serial:find_serial(0), "LUA: Puerto serial no configurado")

port:begin(baud_rate)
port:set_flow_control(0)

local file_name = "datos.csv"
file = io.open(file_name, "a")

local header = "init"
local header_count = 0
local bytes_to_read = 0
local buffer = ""

local new_save_time = 0

local max_bytes_per_update = 100
local lecturas = 0

function inicio()
    gcs:send_text(0, "LUA: Iniciado")
    new_save_time = millis() + 2000
    return update, 100
end

function update()
    local bytes = math.min(port:available(), max_bytes_per_update)
    while bytes > 0 or bytes_to_read > 0 do
        local n = port:read()
        if bytes_to_read == 0 then
            if n == string.byte(header, header_count + 1) then
                header_count = header_count + 1
                if header_count == string.len(header) then
                    header_count = 0
                    bytes_to_read = -1
                end
            else
                header_count = 0
            end
        elseif bytes_to_read == -1 then
            bytes_to_read = n
            buffer = {}
        elseif bytes_to_read > 0 then
            table.insert(buffer, string.char(n))
            bytes_to_read = bytes_to_read - 1
            if bytes_to_read == 0 then
                lecturas = lecturas + 1
                data = table.concat(buffer)
                values = table.pack(string.unpack("<ffffff", data))
                table.remove(values, #values)
                str = tostring(millis()) .. ","
                str = str .. table.concat(values, ",") .. ","
                local accel = ahrs:get_accel()
                local gyro = ahrs:get_gyro()
                local pos = ahrs:get_position()
                local vel = ahrs:get_velocity_NED()
                local wind = ahrs:wind_estimate()
                local airspeed = ahrs:airspeed_estimate()
                str = str .. table.concat({accel:x(), accel:y(), accel:z()}, ",") .. ","
                str = str .. table.concat({gyro:x(), gyro:y(), gyro:z()}, ",") .. ","
                str = str .. table.concat({ahrs:get_roll(), ahrs:get_pitch(), ahrs:get_yaw()}, ",") .. ","
                if (pos == nil) then
                    str = str .. "0,0,0,"
                else
                    str = str .. table.concat({pos:lat(), pos:lng(), pos:alt()}, ",") .. ","
                end
                if (vel == nil) then
                    str = str .. "0,0,0,"
                else
                    str = str .. table.concat({vel:x(), vel:y(), vel:z()}, ",") .. ","
                end
                str = str .. table.concat({wind:x(), wind:y(), wind:z()}, ",") .. ","
                if (airspeed == nil) then
                    str = str .. "0\n"
                else
                    str = str .. tostring(airspeed) .. "\n"
                end
                file:write(str)
            end
        end
        bytes = bytes - 1
    end
    local now = millis()
    if (now > new_save_time) then
        new_save_time = now + 2000
        gcs:send_text(0, "LUA: Guardadas " .. lecturas .. " lecturas en la SD")
        lecturas = 0
        file:flush()
    end
    
    return update, 1
end

return inicio, 100