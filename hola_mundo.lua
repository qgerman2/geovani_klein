local baud_rate = 115200

local port = assert(serial:find_serial(0), "couldnt find serial port")

port:begin(baud_rate)
port:set_flow_control(0)

local file_name = "datos.csv"
file = io.open(file_name, "a")

local header = "init"
local header_count = 0
local bytes_to_read = 0
local buffer = ""

local max_bytes_per_update = 100

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
            gcs:send_text(0, "hay que leer " .. bytes_to_read .. " bytes")
        elseif bytes_to_read > 0 then
            table.insert(buffer, string.char(n))
            bytes_to_read = bytes_to_read - 1
            if bytes_to_read == 0 then
                gcs:send_text(0, "lectura completa de " .. #buffer)
                data = table.concat(buffer)
                values = table.pack(string.unpack("<fffff", data))
                table.remove(values, #values)
                for i, v in ipairs(values) do
                    file:write(v)
                    if i < #values then
                        file:write("")
                    end
                    gcs:send_text(0, i .. ": " .. v)
                end
                str = table.concat(values, ",") .. '\n'
                file:write(str)
                file:flush()
            end
        end
        bytes = bytes - 1
    end
    return update, 100
end

return update()
