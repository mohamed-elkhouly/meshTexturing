function intersections = filterLightPerceptionFaces(origin, points, faces, mesh)

    if size(origin,1)>size(origin,2)
        origin = origin';
    end
    
    if size(points,2)>size(points,1) && size(points,1) > 2
        points = points';
    end
    
    drays = mesh.centroids(faces,:) - repmat(origin, size(mesh.centroids(faces,:),1), 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % could be improved if needed by using the following plane based face filtering
%     plane = createPlane(origin, normal);
%     
%     % filter patches that do not face each other and are below the
%     % plane structured from the throwing point
%     if ~isempty(normals)
%         ind2 = isBelowPlane(centroids, plane);
% 
%         % and remove them since they do not face each other or are
%         % below the plane
%         filteredFaces = [1:1:size_n]';
%         filteredFaces(ind2) = [];
% 
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     t = opcodemesh(mesh.v',mesh.f');
%     [tt,uu,vv,idxx,xnodee]=raysurf(repmat(origin, size(mesh.centroids(faces,:),1), 1), drays , mesh.v, mesh.f(faces,:));
    [hit,tt,idxx,bary,xnodee] = t.intersect(repmat(origin, size(drays,1), 1)',drays');
%     xnodee = xnodee';
    
%     [tt,uu,vv,idxx,xnodee]=raysurf(mesh.centroids(faces,:), repmat(origin, size(mesh.centroids(faces,:),1), 1) - mesh.centroids(faces,:), mesh.v, mesh.f(faces,:));
    
    % correct the indices to match the ones from the original f
%     idxx(~any(isnan(idxx) | isinf(idxx), 2)) = faces(idxx(~any(isnan(idxx) | isinf(idxx), 2)));
    
    intersections = unique(idxx); % find which faces are hit from the rays
    intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
    intersections(intersections == 0) = [];

end