function [F] = viewFactorsPointCloudLdc(cadModel, rays, method, technique)

    pnts = cadModel.centroids;
    size_n = length(pnts);
    
    lights = cadModel.lightPoints.allLights;
    
    % room 1
    luxmeterPoints = [64; 49; 36; 25; 128; 56; 42; 30;   121; 114; 107; 101;  168; 156; 151; 202; 175; 193; 174; 162; 167; 161;   328; 324; 320; 300; 329; 301;   398; 393; 388; 384; 403; 409; 397; 392;   411; 418; 420; 419];
    
    % room 2
%     luxmeterPoints = [1855;1853;1854;1845; 2300;2236;2228;2221;2214;2208;2202;2197; 2293;2288;2279;2273; 2380;2360;2352;2345;2339;2333;2346;2353;2361;2384; 2516;2512;2517;2489; 2610;2603;2597;2591;2580;2585;2590;2598; 2623;2622;2621;2613; 1476;1485;1495;1531];

    Fij = cadModel.Fij;

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
%     Fij = zeros(size_n,size_n);
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

ldc = [426.0060  426.0060  426.0060  426.0060  426.0060  426.0060  426.0060
           424.7540  425.0980  425.5810  425.9940  425.6490  425.1670  424.7540
           421.8600  422.2040  422.7550  423.1690  422.6860  422.2040  421.8600
           415.5200  416.0020  416.1400  416.8980  416.6910  416.2780  415.7960
           408.6290  406.9060  407.0440  408.0090  409.0420  407.3890  406.5620
           394.1580  394.2960  394.5030  395.1920  395.0540  394.5720  394.5720
           374.5880  375.8290  376.9310  376.6550  374.6570  376.3800  377.4820
           349.7810  351.3660  352.8130  351.9170  350.7460  352.1930  353.9150
           317.8070  316.2910  318.2210  316.2910  316.8420  317.1870  319.8750
           267.2280  269.4330  264.4720  267.9170  267.9170  269.6400  266.1260
           200.4280  162.1010  174.1260  163.2380  199.5320  163.8650  174.8770
           111.4940  118.7160  150.0280  118.3780  112.6450  116.1870  151.6540
            73.5810   78.4390   99.5180   80.3960   75.7450   78.4250  100.4280
            49.7660   69.2120   54.2240   71.2930   52.1980   71.8860   56.8360
            35.5290   49.5180   46.4930   48.3810   35.8390   47.2780   48.2220
            34.3720   37.9410   35.3290   38.5750   33.9930   39.9950   35.4050
            24.1730   24.9380   28.9690   25.8750   24.7800   24.6350   28.5140
            14.3050   15.9870   19.6670   16.4830   15.1460   15.9450   19.7770
             6.0920    6.5390    7.0420    7.2350    6.9940    6.8220    6.6840
             4.7550    4.9550    5.2780    5.2160    5.2090    5.4780    5.6640
             3.8590    3.8520    3.8930    3.9000    3.8870    4.3210    4.4380
             3.1150    3.1420    2.9350    2.8530    3.0870    3.4660    3.5970
             2.8670    2.6670    2.4740    2.3500    2.5700    2.9290    3.1700
             2.4120    2.4050    2.3360    2.0330    2.3500    2.6050    2.7840
             1.6540    1.6670    1.9090    1.8880    1.7300    1.5920    1.6810
             1.1300    1.1990    1.2680    1.4880    1.2270    1.1580    1.1300
             1.0470    1.0400    1.0400    1.1440    1.0750    1.0540    1.0470
             1.1300    1.1640    1.2060    1.1850    1.2130    1.1850    1.1710
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0
                  0         0         0         0         0         0         0];

    ldc = struct('ldc', ldc, 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));
    
    for i = [lights' luxmeterPoints'];
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
%                     D(j,r)= inf; %1e9;
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

        
        % plot point cloud, text over points, plane, origin point ray from
        % origin point and normal from closest found intersecting point
%         figure, plot_vertices(pnts, 'b.', 3);
%         text(pnts(intersectedPnts, 1), pnts(intersectedPnts, 2), pnts(intersectedPnts, 3), num2str(intersectedPnts'), 'Color', 'k', 'FontSize', 6);
%         drawPlane3d(plane, 'm');
%         plot_vertices(pnts(i,:), 'g.', 15);
%         drawRays(pnts(i,:), draysR(450,:));
%         drawRays(pnts(532,:), normals(532,:),'g');

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
        
        amount_of_intersections = zeros(length(intersections), 1);
        
        if ~isempty(intersections) && (ismember(i, luxmeterPoints) || ismember(i, lights)) 
            rayPnts = draysR + repmat(pnts(i,:), rays, 1); % create points on the rays and their directions
%             xnodee(any(isnan(xnodee) | isinf(xnodee), 2), :) = rayPnts(any(isnan(xnodee) | isinf(xnodee), 2), :); % replace any non intersected ray with the previous points on the rays
            points = rayPnts'; % needed in order to make the interpolate them according to the ldc values
%             points = pnts(idxx,:)';
            init_pos = pnts(i,:)';

            n_vis = size(points,2);
            % Compute the relative position of each point with respect to the camera center
            v_points = points - repmat(init_pos,[1,n_vis]);

            % Compute the distance between each point and the center of the camera
            norms = sqrt(sum(v_points .* v_points));

            v_center = M(3,:)';
            % Compute the angle between the principal axis (Z-axis) and the ray connecting the light source to each point
            vcenter_to_vpoint_angle = acosd(sum(repmat(v_center,[1,n_vis]) .* v_points) ./ norms);

            % Compute the angle between the principal axis (X-axis) and the ray connecting the light source to each point
            v_centerX = M(1,:)';
            vcenter_to_vpoint_angle_X_axis = acosd(sum(repmat(v_centerX,[1,n_vis]) .* v_points) ./ norms);

            descriptor = struct('initialPosition',  init_pos, 'pointsPosition', points, ...
                        'angleZ', vcenter_to_vpoint_angle, 'angleX', vcenter_to_vpoint_angle_X_axis, 'distance', norms, 'v_center', v_center);

            descriptor.candelas = interp2(ldc.ldcZ, ldc.ldcX, ldc.ldcSymetric', descriptor.angleZ, descriptor.angleX)';
            descriptor.candelasNorm = rays*(descriptor.candelas / sum(descriptor.candelas));

%%%%%%%% Method 2 %%%%%%%%%%%%%%%%%%%%%
%             or
%             descriptor.candelasNorm = interp2(ldc.ldcZ, ldc.ldcX, ldc.ldcSymetricNorm', descriptor.angleZ, descriptor.angleX);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            for ii = 1:length(intersections)
                tmp = find(idxx == intersections(ii));
                amount_of_intersections(ii) = sum(descriptor.candelasNorm(tmp));
            end
        else
            amount_of_intersections  = histc(idxx,intersections); % and find how many rays are hit each of the above found faces
        end        
        
%         amount_of_intersections  = histc(idxx,intersections); % and find how many rays are hit each of the above found faces
        
        fprintf(' (iteration %i) : %i : %i \n',i, length(intersections), length(amount_of_intersections));
        Fij(i,intersections) = amount_of_intersections;
        
        if ~isempty(valid_rays) %|| valid_rays ~= 0
            Fij(i,:) = Fij(i,:) / valid_rays;
        else
            Fij(i,:) = Fij(i,:) / rays;
        end
        
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

