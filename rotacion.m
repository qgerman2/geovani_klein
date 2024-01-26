%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 10);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["time", "body_vx", "body_vy", "body_vz", "inertial_vx", "inertial_vy", "inertial_vz", "phi", "theta", "psi1"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, ["time", "body_vx", "body_vy", "body_vz", "inertial_vx", "inertial_vy", "inertial_vz", "phi", "theta", "psi1"], "ThousandsSeparator", ",");
% Import the data
tbl = readtable("datos_velocidades.txt", opts);
%% Convert to output type
time = tbl.time;
body_vx = tbl.body_vx;
body_vy = tbl.body_vy;
body_vz = tbl.body_vz;
inertial_vx = tbl.inertial_vx;
inertial_vy = tbl.inertial_vy;
inertial_vz = tbl.inertial_vz;
phi = deg2rad(tbl.phi);
theta = deg2rad(tbl.theta);
psi = deg2rad(tbl.psi1);

i = 15000;
Q = body_a_inercial_matriz(phi(i), theta(i), psi(i));
v_body = [body_vx(i); body_vy(i); body_vz(i)];
Q * v_body
v_inercial = [inertial_vx(i); inertial_vy(i); inertial_vz(i)]
