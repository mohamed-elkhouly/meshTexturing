function [F] = viewFactorsPointCloud(cadModel, rays, method, technique)

    pnts = cadModel.centroids;
    size_n = length(pnts);

    %args
    if nargin < 4 
        % if beckers is chosen the specify technique the rays would be
        % arranged, i.e. random = 1 or deterministic = 2
        technique = 2;
    end
    if nargin < 3 
        % method to be used for constracting the globe and throwing the
        % rays isocell = 1, or beckers = 2
        method = 1;
    end
    if nargin < 2 
        % initialize number of rays to be thrown in the scene each time
        rays = 1000;
    end
    if ~isfield(cadModel, 'normals')
        % extract normal unit vector of each face/patch
        normals = findPointNormals(pnts,[],[0,0,10],true); %meshFaceNormals(v, f); to be fixed it is not working well for now
    else
        normals = cadModel.normals;
    end
%     if ~isfield(cadModel, 'centroids')
%         % extract center of each face/patch 
%         centroids = faceCentroids(v, f);
%     else
%         centroids = cadModel.centroids;
%     end
    if ~isfield(cadModel, 'areas')
        % extract the area of each point a cuboic voxel of 0.5
        % widht/height/length or a sphere with radius 0.5
        areas = ones(size_n,1)*(0.5*0.5*0.5);
%         areas = ones(size_n,1)*((4/3)*(pi)*(0.5.^3)); % sphere
    else
        areas = cadModel.areas;
    end
    
    if method == 1
        % distribute points on a unit circle according to the Isocell method
        [~,Xr,Yr,~,~]=isocell_distribution(rays, 3, 0);

        % define rays in the 3D space, on the unit sphere
        drays = [Xr; Yr; sqrt(1-Xr.^2-Yr.^2)];
        if size(drays,1)<size(drays,2)
            drays = drays';
        end
    end
    
    if method == 2
        S = Bvfmd(rays,1);
        if technique == 1
            colo=Bvf(S);
        end
        if technique == 2
            colo=BvfD(S);
        end
        
%         figure; Bsrays(colo); % plot drays
        drays = geod2cart(colo);
        if size(drays,1)<size(drays,2)
            drays = drays';
        end
    end
    
    % correct size of rays created from the isocell distribution
    rays = size(drays,1);

    % initialize the view/form factors matrix
    Fij = zeros(size_n,size_n);
%     Ftest = zeros(size_n,size_n);
    
%     % arrange faces/patches to what the TriangleRayIntersection() function
%     % accepts as input
%     vert1 = v(f(:,1),:);
%     vert2 = v(f(:,2),:);
%     vert3 = v(f(:,3),:);
    
%     % shift a bit the centroids so that rays do not stop at the self
%     % face thrown from
%     offset = sign(normals);
%     offset = offset*1e-3;
%     centroids = centroids + offset;
    
    for i = 1:size_n
        r = vrrotvec(normals(i,:),[0 0 1]); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
        M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
        draysR = drays*M; % coincident rays to the normal vector of the origin point (centroid) of face
        
        % shift a bit the origin point of the plane so that coplanar points
        % go below plane and do not given as the shortest points
        offset = sign(normals(i,:));
%         offset = offset*1e-3;
        plane_origin = pnts(i,:) + offset;
        
        plane = createPlane(plane_origin, normals(i,:));
        
        % draw plane
        % figure, plot_vertices(pnts, 'b.', 3);
        % drawPlane3d(plane, 'm');
        
        if ~isempty(normals)
%             % extract only indices with parallel normals
%             ind = find(vectorNorm3d(crossProduct3d(normals(i, :), normals)) < 1e-3); % experimentally the threshold of 1e-3 seems to work fine
% 
%             % and over these find points with only same normals
%             ind2 = [];
%             for k = 1:length(ind)
%                 rotVec = vrrotvec(normals(i,:),normals(ind(k),:));
%                 if rotVec(4) < 1e-3 % experimentally the threshold of 1e-3 seems to work fine
%                     ind2 = cat(1, ind2, ind(k));
%                 end
%             end
            
            ind2 = (~isFacing(pnts(i, :), normals(i, :), pnts, normals)) | isBelowPlane(pnts, plane);

            % and remove them since they do not face each other
            intersectedPnts = [1:1:size_n];
            intersectedPnts(ind2) = [];
            
        end
               
        % start throwing rays in space and finding intersections with
        % all other points
        D = ones(size_n, rays)*Inf;%1e9;
        C = ones(size_n, rays, 3)*Inf;
        t0 = ones(size_n, rays)*Inf;
%         for r = 1:rays
%             for j = intersectedPnts
%                 rotVec = vrrotvec(draysR(r, :), normals(j,:));
%                 if norm(pnts(i,:)-pnts(j,:)) == 0 || isBelowPlane(pnts(j,:), plane) || ~isParallel3d(draysR(r, :), normals(j,:), 0.85) || rotVec(4) < 1.5
%                     
%                     D(j,r)= Inf; %1e9;
%                     C(j,r,:) = Inf;
%                     t0(j,r) = Inf;
%                     continue;
% %                 elseif ((vectorNorm3d(crossProduct3d(draysR(r, :), normals(j,:))) < 1) && (rotVec(4) < 2))
% %                     D(j,r)= inf; %1e9;
% %                     C(j,r,:) = Inf;
% %                     t0(j,r) = Inf;
% %                     continue;
%                 else
%                     [D(j,r), C(j,r,:), t0(j,r)] = distancePoint2Line(pnts(i,:), (pnts(i,:) + draysR(r,:)), pnts(j,:), 'ray');
% %                     [D(j,r), c, t0(j,r)] = distancePoint2Line(pnts(i,:), draysR(r,:), pnts(j,:), 'ray');
%                 end
%             end
%         end

        [D(intersectedPnts,:), C(intersectedPnts,:,:), t0(intersectedPnts,:)] = distancePoint2LineVec(pnts(i,:), draysR, pnts(intersectedPnts, :), 'ray');

        [distances, idxx] = min(D);
        
        % TODO: check whether removing infs and max distances affects the
        % indexing of idxx with the rays. Could be realy important if there
        % is a bug here.
        idxx(isinf(distances) | distances >= 200) = []; % remove all points/rays with a distance greater than 500
        idxx = idxx';
        
%         [tt,uu,vv,idxx,xnodee]=raysurf(repmat(centroids(i,:), size(draysR,1), 1), draysR , v, f);
%         
%         % check whether some rays do not hit any of the existing faces and
%         % remove them or hit at the face joints/borders
%         tt(isnan(tt) | isinf(tt)) = [];
%         uu(isnan(uu) | isinf(uu)) = [];
%         vv(isnan(vv) | isinf(vv)) = [];
%         idxx(isnan(idxx) | isinf(idxx)) = [];
%         xnodee(any(isnan(xnodee) | isinf(xnodee), 2), :) = [];
        
%         if ~isempty(idxx)
%             valid_rays = size(idxx,2);
%         else
%             valid_rays = [];
%         end
        
        intersections = unique(idxx); % find which points are hit from the rays
        
%         if ~isempty(intersections)
%             % extract only indices of faces with parallel normals
%             ind = find(vectorNorm3d(crossProduct3d(normals(i, :), normals(intersections, :))) < 1e-3); % experimentally the threshold of 1e-3 seems to work fine
% 
%             % and over these find faces with only same normals
%             ind2 = [];
%             for k = 1:length(ind)
%                 rotVec = vrrotvec(normals(i,:),normals(intersections(ind(k)),:));
%                 if rotVec(4) < 1e-3 % experimentally the threshold of 1e-3 seems to work fine
%                     ind2 = cat(1, ind2, ind(k));
%                 end
%             end
% 
%             % and remove them since they do not face each other
%             intersections(ind2) = [];
%         end        
        
        amount_of_intersections  = histc(idxx,intersections); % and find how many rays are hit each of the above found faces
        
        fprintf(' (iteration %i) : %i : %i \n',i, length(intersections), length(amount_of_intersections));
        Fij(i,intersections) = amount_of_intersections;
        
%         if ~isempty(valid_rays) %|| valid_rays ~= 0
%             Fij(i,:) = Fij(i,:) / valid_rays;
%         else
            Fij(i,:) = Fij(i,:) / rays;
%         end
        
%         % plot the isocell rays and the intersections to the other patches
%         figure, plot_CAD(f, v, 'LAB'); % show full cad
%         scatter3(xnodee(:,1),xnodee(:,2),xnodee(:,3), 2 ,[1 0 0], 'filled') % show intersections
%         plot_vertices(centroids(i,:)); % show center of the patch
%         drawRays(centroids(i,:), draysR); % show icosell starting from the center of the patch

%         % plot the ldc on the cad
%         figure, plot_CAD(f, v, 'LAB'); % show full cad
%         scatter3(xnodee(:,1),xnodee(:,2),xnodee(:,3), 3 ,descriptor.candelas, 'filled') % show intersections
%         plot_vertices(centroids(i,:), 'g.', 10);
%         plot3DLdc(ldc.ldc, init_pos, r);
        
    end
    
    F.ij = Fij;
%     F.ij = Fij / rays; % normalize view factor according to the total rays thrown each time
    
%%%%%%%% Method 2 %%%%%%%%%%%%%%%%%%%%%
%       or    
%       F.ij = Fij / sum(descriptor.candelas); % normalize view factor according to the total weights from the LDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    F.sp = 1 - sum(F.ij,2); % extract the space view factors vector in order to address the non-closure of the scene, I use 1 instead of number of rays because Fij is already normalized
    F.nRays = rays;
    
    [F.ji, ~] = RT_ViewFactorsReciprocityClosure(F.ij, F.sp, areas, 1, 0.000001, F.nRays);
    
    % check whether error got small or not
    A = areas * transpose(areas);
    AF = A.*F.ji;
    err = norm((AF-transpose(AF))./A)

end

