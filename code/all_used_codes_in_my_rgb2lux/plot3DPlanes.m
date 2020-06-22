function plot3DPlanes (ldc, pos)
% angles around x-axis, need to turn by 90 degree right pol2cart output
anglesX = (0:5:360)/180*pi+pi/2;

% angles around z-axis
anglesZ = 0:15:90;

% loop over columns
posX = pos(1);
posY = pos(2);
posZ = pos(3);
% data = flipud(ldc_norm);
step = size(ldc,2) - 1;
% step = 1;
for i = 1:step:size(ldc,2)
    % you need to create a closed contour for fill3
    ldcJoined = [ldc(:,i);ldc((end-1):-1:1,i)];
    % plot for positive and negative angle around z, i as color-index
    plotPlane(anglesX, ldcJoined, anglesZ(i), i, posX, posY, posZ)
    hold on
    plotPlane(anglesX, ldcJoined, -anglesZ(i), i, posX, posY, posZ)
end