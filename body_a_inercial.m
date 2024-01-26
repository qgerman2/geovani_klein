% ** Sistema body frame **
% The +X axis points to the right side of the aircraft.
% The +Y axis points up.
% The +Z axis points to the tail of the aircraft.

function [out_x, out_y, out_z] = body_a_inercial(x, y, z, phi, theta, psi)

out_x = (x*cos(phi) + y*sin(phi)) * cos(psi) - (z*cos(theta) + (y*cos(phi) - x*sin(phi))*sin(theta)) * sin(psi);
out_y = (y*cos(phi) - x*sin(phi)) * cos(theta) - z*sin(theta);
out_z = (z*cos(theta) + (y*cos(phi) - x*sin(phi))*sin(theta)) * cos(psi) + (x*cos(phi) + y*sin(phi)) * sin(psi);

end

% ** Sistema inercial **
% The +X axis points east from the reference point.
% The +Y axis points straight up away from the center of the earth at the reference point.
% The +Z axis points south from the reference point.