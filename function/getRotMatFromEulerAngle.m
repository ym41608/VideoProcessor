% Get rotation matrix with three rotation angles
%
% Usage:
%   [R] = getRotMatFromEulerAngle(ax, ay, az, Factor)
%
% Inputs:
%   rx     = rotation angle about X-axis
%   ry     = rotation angle about Y-axis
%   rz     = rotation angle about Z-axis
%   Factor = 'RxRyRz'  or 'RzRyRx'
%
% Outputs:
%   rot = rotation matrix

%% Programmed by:
% Lab421
% Graduate Institute of Electronics Engineering, National Taiwan University, Taipei, Taiwan
% June 1, 2014

function R = getRotMatFromEulerAngle(rx, ry, rz, Factor)
    if(nargin < 4)
        Factor = 'RxRyRz';
    end
    sinx = sin(degtorad(rx));
    cosx = cos(degtorad(rx));
    siny = sin(degtorad(ry));
    cosy = cos(degtorad(ry));
    sinz = sin(degtorad(rz));
    cosz = cos(degtorad(rz));

    R = zeros(3);

    if Factor == 'RxRyRz'
        R(1,1) = cosy*cosz;
        R(1,2) = -cosy*sinz;
        R(1,3) = siny;
        R(2,1) = sinx*siny*cosz + cosx*sinz;
        R(2,2) = -sinx*siny*sinz + cosx*cosz;
        R(2,3) = -sinx*cosy;
        R(3,1) = -cosx*siny*cosz + sinx*sinz;
        R(3,2) = cosx*siny*sinz + sinx*cosz;
        R(3,3) = cosx*cosy;
    else % Factor == 'RzRyRx'
        R(1,1) = cosy*cosz;
        R(1,2) = sinx*siny*cosz-cosx*sinz;
        R(1,3) = cosx*siny*cosz+sinx*sinz;
        R(2,1) = cosy*sinz; 
        R(2,2) = sinx*siny*sinz+cosx*cosz;
        R(2,3) = cosx*siny*sinz-sinx*cosz;
        R(3,1) = -siny;
        R(3,2) = sinx*cosy;
        R(3,3) = cosx*cosy;
    end
end
