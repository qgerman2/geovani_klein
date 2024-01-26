DataRef("body_vx", "sim/flightmodel/forces/vx_acf_axis")
DataRef("body_vy", "sim/flightmodel/forces/vy_acf_axis")
DataRef("body_vz", "sim/flightmodel/forces/vz_acf_axis")

DataRef("inertial_vx", "sim/flightmodel/position/local_vx")
DataRef("inertial_vy", "sim/flightmodel/position/local_vy")
DataRef("inertial_vz", "sim/flightmodel/position/local_vz")

DataRef("phi", "sim/flightmodel/position/phi")
DataRef("theta", "sim/flightmodel/position/theta")
DataRef("psi", "sim/flightmodel/position/psi")

DataRef("time", "sim/time/local_time_sec")

file = io.open("datos.txt", "a")
logMsg("Hello World!")

function update()
    local texto = table.concat({time, body_vx, body_vy, body_vz, inertial_vx, inertial_vy, inertial_vz, phi, theta, psi}, ",")
    file:write(texto .. "\n")
end

do_every_draw('update()')