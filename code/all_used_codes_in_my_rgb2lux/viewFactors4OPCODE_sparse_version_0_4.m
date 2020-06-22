function [F] = viewFactors4OPCODE_sparse_version_0_3(cadModel, rays, method, ldc, Fij, ldcPatches)


f = cadModel.f;
v = cadModel.v;

size_n = length(f);

%     max_intersections=0;
global iteration;
global data_vectors;
global index_vectors;
global counter;
global  scene_name;
global region_number;
iteration=iteration+1;
if iteration==1
    % data_vectors(:,1)>> i-index    data_vectors(:,j)>> j-index
    %     data_vectors=zeros(ceil(size_n*size_n*0.01),1);
    %     index_vectors=zeros(ceil(size_n*size_n*0.01),1);
    data_vectors=zeros(size_n,rays);
    index_vectors=zeros(size_n,rays);
end

% if beckers is chosen the specify technique the rays would be
% arranged, i.e. random = 1 or deterministic = 2
technique = 2;

%args
if nargin < 5
    patches = 1:1:size_n;
else
    patches = ldcPatches;
    if size(patches,2)<size(patches,1)
        patches = patches';
    end
end
if nargin < 4
    % initialize the view/form factors matrix
    %%%%%%%         Fij = zeros(size_n,size_n);
end
%     if nargin < 4
%         % if beckers is chosen the specify technique the rays would be
%         % arranged, i.e. random = 1 or deterministic = 2
%         technique = 2;
%     end
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
    normals = meshFaceNormals(v, f);
else
    normals = cadModel.normals;
end
if ~isfield(cadModel, 'centroids')
    % extract center of each face/patch
    centroids = meshFaceCentroids(v, f);
else
    centroids = cadModel.centroids;
end
if ~isfield(cadModel, 'areas')
    % extract the area of each face/patch
    areas = meshArea(f,v);
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

% shift a bit the centroids so that rays do not stop at the self
% face thrown from
offset = sign(normals);
offset = offset*1e-3;
centroids = centroids + offset;


t = opcodemesh(v',f');
% [~,~,idxx,~,~] = t.intersect(cadModel.campos(60,:)',[-5.0281, 0.9996 0.0111]');
d=[];


%% End here

show_annotated_light_sources_flag=1;
show_annotated_light_sources(show_annotated_light_sources_flag,size_n,cadModel,centroids,normals,scene_name,region_number,f,v);
%% Dahy added this   this one is to find light using rays shooted only to light sources (not complete till 6/5/2019)
%     % shift a bit the centroids so that rays do not stop at the self
% face thrown from
% using_isocell=1;
% offset = sign(cadModel.camdir);
% offset = offset*1e-3;
% cadModel.campos = cadModel.campos + offset;
shoot_rays_toward_specularities=1;
if (shoot_rays_toward_specularities)
    shoot_rays_to_specularities(cadModel,size_n,drays,normals,centroids,scene_name,region_number,f,v,t);
end
% other_test=hit_light_faces_count_array;
% for index=1:size(region_specular_frames)
%     frame=region_specular_frames(index);
%     current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
%     current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
%     other_test(current_pose_spec_faces)=0;
% end
% figure, plot_CAD(f, v, '', other_test);
% delete(findall(gcf,'Type','light'));
d=[];
%% End here
%% Dahy added this:
% possiple_specular_faces=cadModel.max_num_specular_faces;% we may not be able to put it same like rays numbers as we may have more number of specular faces
% region_specular_frames=cadModel.region_specular_frames+1;
% cam_f_matrix_index=zeros([length(region_specular_frames),possiple_specular_faces]);
% cam_f_matrix_value=zeros([length(region_specular_frames),possiple_specular_faces]);
% for index=1:size(region_specular_frames)
%     frame=region_specular_frames(index);
%     current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
%     current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
%     cam_f_matrix_index(index,1:length(current_pose_spec_faces))=current_pose_spec_faces;
%     cam_f_matrix_value(index,1:length(current_pose_spec_faces))=1/1000;
% end
%% End here

for i = patches;
    r = vrrotvec(normals(i,:),[0 0 1]); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
    M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
    draysR = drays*M; % coincident rays to the normal vector of the origin point (centroid) of face
    
    %         plane = createPlane(centroids(i,:), normals(i,:));
    %
    %         % filter patches that do not face each other and are below the
    %         % plane structured from the throwing point
    %         if ~isempty(normals)
    %             ind2 = isBelowPlane(centroids, plane);
    %
    %             % and remove them since they do not face each other or are
    %             % below the plane
    %             filteredFaces = [1:1:size_n]';
    %             filteredFaces(ind2) = [];
    %
    %         end
    
    % start throwing rays in space and finding intersections with
    % other pactches/faces
    %         [tt,uu,vv,idxx,xnodee]=raysurf(repmat(centroids(i,:), size(draysR,1), 1), draysR , v, f(filteredFaces,:));
    [hit,tt,idxx,bary,xnodee] = t.intersect(repmat(centroids(i,:), size(draysR,1), 1)',draysR');
    xnodee = xnodee';
    
    intersections = unique(idxx); % find which faces are hit from the rays
    intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
    intersections(intersections == 0) = [];
    
    if ~isempty(intersections)
        %{
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
        %}
        
        ind22 = ~isFacing(centroids(i, :), normals(i, :), centroids(intersections, :), normals(intersections, :));
        
        % and remove them since they do not face each other
        intersections(ind22) = [];
    end
    
    amount_of_intersections = zeros(length(intersections), 1);
    
    if ~isempty(intersections) && exist('ldc', 'var')
        rayPnts = draysR + repmat(centroids(i,:), rays, 1); % create points on the rays and their directions
        xnodee(any(isnan(xnodee) | isinf(xnodee), 2), :) = rayPnts(any(isnan(xnodee) | isinf(xnodee), 2), :); % replace any non intersected ray with the previous points on the rays
        points = xnodee'; % needed in order to make the interpolate them according to the ldc values
        init_pos = centroids(i,:)';
        
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
        
        
        for ii = 1:length(intersections)
            tmp = find(idxx == intersections(ii));
            amount_of_intersections(ii) = sum(descriptor.candelasNorm(tmp));
        end
    else
        amount_of_intersections  = histc(idxx,intersections); % and find how many rays are hit each of the above found faces
    end
    
    %         fprintf(' (iteration %i) : %i : %i \n',i, length(intersections), length(amount_of_intersections));
    %         Fij(i,intersections) = amount_of_intersections;
    if iteration==1
        index_vectors(i,1:length(intersections))=intersections;
        data_vectors(i,1:length(intersections))=amount_of_intersections;
        counter=counter+length(intersections);
        %             if length(intersections)>max_intersections
        %                 max_intersections=length(intersections);
        %             end
    else
        for j=1:length(intersections)
            if sum(index_vectors(i,:)==intersections(j))>0
                data_vectors(i,index_vectors(i,:)==intersections(j))=amount_of_intersections(j);
            elseif(isempty(find(index_vectors(i,:))))
                data_vectors(i,1)=amount_of_intersections(j);
                index_vectors(i,1)=intersections(j);
            else
                non_zero_index=max(find(index_vectors(i,:)));
                data_vectors(i,non_zero_index+1)=amount_of_intersections(j);
                index_vectors(i,non_zero_index+1)=intersections(j);
            end
        end
    end
    %         if ~isempty(valid_rays) %|| valid_rays ~= 0
    %             Fij(i,:) = Fij(i,:) / valid_rays;
    %         else
    %             Fij(i,:) = Fij(i,:) / rays; % normalize view factor according to the total rays thrown each time
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
F=[];


%     F.ij = Fij;

% if iteration==3

%     tot_num=1;
%     F_row_V=[];
%     F_col_V=[];
%     F_val_V=[];
%     rows=find(sum(cam_f_matrix_index>0,2)>0);
%     for jk=1:length(rows)
%         rr=rows(jk);
%         current_indexes=cam_f_matrix_index(rr,cam_f_matrix_index(rr,:)>0);
%         current_values=cam_f_matrix_value(rr,cam_f_matrix_value(rr,:)>0);
%         F_row_V(tot_num:tot_num+length(current_indexes)-1)=rr;
%         F_col_V(tot_num:tot_num+length(current_indexes)-1)=current_indexes;
%         F_val_V(tot_num:tot_num+length(current_indexes)-1)=current_values;
%         tot_num=tot_num+length(current_indexes);
%     end
%     cam_row_v=[F_col_V,F_row_V+size_n];
%     cam_col_v=[F_row_V+size_n,F_col_V];
%     cam_val_v=[F_val_V,F_val_V];

tot_num=1;
F_row_V=[];
F_col_V=[];
F_val_V=[];
rows=find(sum(index_vectors>0,2)>0);
for jk=1:length(rows)
    rr=rows(jk);
    current_indexes=index_vectors(rr,index_vectors(rr,:)>0);
    current_values=data_vectors(rr,index_vectors(rr,:)>0);
    F_row_V(tot_num:tot_num+length(current_indexes)-1)=rr;
    F_col_V(tot_num:tot_num+length(current_indexes)-1)=current_indexes;
    F_val_V(tot_num:tot_num+length(current_indexes)-1)=current_values;
    tot_num=tot_num+length(current_indexes);
end
F_val_V=F_val_V/rays;
F_row_V=[F_row_V,cam_row_v];
F_col_V=[F_col_V,cam_col_v];
F_val_V=[F_val_V,cam_val_v];
F_row_V=[F_row_V];
F_col_V=[F_col_V];
F_val_V=[F_val_V];
F=sparse(F_row_V,F_col_V,F_val_V,size_n,size_n);

% end
d=[];
%% Apply reciprocity closure on the computed form factors (it is a time consuming calculation which might not be neccessary)
%     F.sp = 1 - sum(F.ij,2); % extract the space view factors vector in order to address the non-closure of the scene, I use 1 instead of number of rays because Fij is already normalized
%     F.nRays = rays;
%
%     [F.ji, ~] = RT_ViewFactorsReciprocityClosure(F.ij, F.sp, areas, 1, 0.000001, F.nRays);
%
%     % check whether error got small or not
%     A = areas * transpose(areas);
%     AF = A.*F.ji;
%     err = norm((AF-transpose(AF))./A)

end