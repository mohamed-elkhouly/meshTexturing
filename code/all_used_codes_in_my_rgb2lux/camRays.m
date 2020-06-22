function [drays imgPnts projPnts unProjPnts] = camRays(img, K, R, t)
    
    % get image dimensions
    [rows,cols,chan] = size(img);
    
    % create meshgrid in order to get the cartesian coordinates of the
    % pixel values
    [xu,yu] = meshgrid(1:cols, 1:rows);
    
    % get cartesian coordinates together with pixel values
    imgPnts=[xu(:),yu(:),ones(rows*cols,1),img(:)];
    
    unProjPnts = inv(K)*imgPnts(:,1:3)';
%     test = unProjPnts' + t'; % gives unprojected translated image plane
    drays = R*unProjPnts; % gives the direction of the rays
    drays = drays';
    projPnts = drays + t'; % gives projected translated/rotated image plane

%     [width,height] = size(img);
%     cx = width/2;
%     cy = height/2;
%     
%     projectedPnts = [];
%     for x = 1 : width
%         for y = 1 : height
%             projectedX(y,1) = (x - cx) / (width * 0.5);
%             projectedY(y,1) = (y - cy) / (height * 0.5);
%             projectedZ(y,1) = 1;
%         end
%         projectedPnts = [projectedPnts; [projectedX projectedY projectedZ]];
%     end
%     unProjectedPnts = projectedPnts*inv(P(1:3,1:3)) + t';
%     direction = unProjectedPnts - repmat(t', length(unProjectedPnts), 1);
% %     norms = sqrt(sum(direction.^2,2));
% %     norms = 1 ./ norms;
% %     direction = direction .* norms;
% 
%     drays = direction;
%     upnts = unProjectedPnts;
end