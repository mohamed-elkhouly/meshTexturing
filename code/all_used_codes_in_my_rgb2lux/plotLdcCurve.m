function [] = plotLdcCurve(anglesX, r, angleZ, c, posX, posY, posZ, rot)

    % convert to cartesian coordinates
    [p1, p2] = pol2cart(anglesX, r');

    % plot on x-axis (x=0)
    X = ones(size(p1))*posX;
    Y = p1+posY;
    Z = p2+posZ;
%     C = ones(size(Z)) .* c; % color input needed, you could e.g. C=sin(angles);
    
    % plot contours
    h = plot3(X,Y,Z,'b','LineWidth',1.5);
    
    origin = [posX posY 0];
    
    rotate(h, [0,0,1], angleZ, origin);
    
    if (~isempty(rot))
        rotate(h, rot(:,1:3), rad2deg(rot(4)), [posX posY posZ]);
    end
    
    xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
end