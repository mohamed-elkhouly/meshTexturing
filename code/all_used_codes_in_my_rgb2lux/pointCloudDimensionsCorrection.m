function P_filtered = pointCloudDimensionsCorrection(Points)
    % Centers the points
    Points = Points(1:3,:) - mean(Points(1:3,:),2)*ones(1,size(Points,2));
    
    P_filtered = Points;
    
    % Translate points in the space
    minX = min(P_filtered(1,:));
    minY = min(P_filtered(2,:));
    minZ = min(P_filtered(3,:));

    P_filtered(1,:) = P_filtered(1,:)+ abs(minX);
    P_filtered(2,:) = P_filtered(2,:)+ abs(minY);
    P_filtered(3,:) = P_filtered(3,:)+ abs(minZ);
end