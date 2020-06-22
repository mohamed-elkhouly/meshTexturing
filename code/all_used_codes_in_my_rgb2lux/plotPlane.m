function [] = plotPlane(anglesX, r, angleZ, c, posX, posY, posZ)

    % convert to cartesian coordinates
    [p1, p2] = pol2cart(anglesX, r');

    % plot on x-axis (x=0)
    X = ones(size(p1))*posX;
    Y = p1+posY;
    Z = p2+posZ;
    C = ones(size(Z)) .* c; % color input needed, you could e.g. C=sin(angles);
    
    % plot filled contours
    h = fill3(X,Y,Z,C);
    
%     surf(X,Y,-Z);
    origin = [posX posY 0];
    rotate(h, [0,0,1], angleZ, origin);
    
    xlabel('x'); ylabel('y'); zlabel('z');
end