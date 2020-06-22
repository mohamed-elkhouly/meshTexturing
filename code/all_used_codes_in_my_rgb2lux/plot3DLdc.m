function plot3DLdc (ldc, pos, rot)

    if nargin < 2
        posX = 0;
        posY = 0;
        posZ = 0;
    else
        posX = pos(1);
        posY = pos(2);
        posZ = pos(3);
    end
    
    if nargin < 3
        rot = [];
    end

% angles around x-axis, need to turn by 90 degree right pol2cart output
% anglesX = (0:5:360)/180*pi+pi/2; % ldc
anglesX = (0:10:360)/180*pi+pi/2; % lsc

% angles around z-axis
% anglesZ = 0:15:90; % ldc
anglesZ = 0:10:90; % lsc

% data = flipud(ldc_norm);
% step = size(ldc,2) - 1;
step = 1;
% loop over columns
for i = 1:step:size(ldc,2)
    % you need to create a closed contour for fill3
    ldcJoined = [ldc(:,i);ldc((end-1):-1:1,i)];
    % plot for positive and negative angle around z, i as color-index
    plotLdcCurve(anglesX, ldcJoined, anglesZ(i), i, posX, posY, posZ, rot)
    hold on
    plotLdcCurve(anglesX, ldcJoined, -anglesZ(i), i, posX, posY, posZ, rot)
end