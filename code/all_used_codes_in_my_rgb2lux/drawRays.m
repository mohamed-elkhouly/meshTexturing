function drawRays(center, rotPnts, color, scale)

    %args
    if nargin < 3 
        % initialize color of rays
        color = 'b';
    end
    
    if nargin < 4 
        % initialize color of rays
        scale = 1;
    end
    
    if size(center,1)>size(center,2)
        center = center';
    end

    centers = repmat(center(1,:), size(rotPnts,1), 1);
    
%     for i = 1:size(rotPnts,1)
        quiver3(centers(:,1), centers(:,2), centers(:,3), scale*rotPnts(:,1), scale*rotPnts(:,2), scale*rotPnts(:,3), color);
%         arrow3D(centers(1,:), rotPnts(i,:), 'b');
%     end
   
end