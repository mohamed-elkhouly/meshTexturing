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

%{
%     ldc = [426.0060  426.0060  426.0060  426.0060  426.0060  426.0060  426.0060
%            424.7540  425.0980  425.5810  425.9940  425.6490  425.1670  424.7540
%            421.8600  422.2040  422.7550  423.1690  422.6860  422.2040  421.8600
%            415.5200  416.0020  416.1400  416.8980  416.6910  416.2780  415.7960
%            408.6290  406.9060  407.0440  408.0090  409.0420  407.3890  406.5620
%            394.1580  394.2960  394.5030  395.1920  395.0540  394.5720  394.5720
%            374.5880  375.8290  376.9310  376.6550  374.6570  376.3800  377.4820
%            349.7810  351.3660  352.8130  351.9170  350.7460  352.1930  353.9150
%            317.8070  316.2910  318.2210  316.2910  316.8420  317.1870  319.8750
%            267.2280  269.4330  264.4720  267.9170  267.9170  269.6400  266.1260
%            200.4280  162.1010  174.1260  163.2380  199.5320  163.8650  174.8770
%            111.4940  118.7160  150.0280  118.3780  112.6450  116.1870  151.6540
%             73.5810   78.4390   99.5180   80.3960   75.7450   78.4250  100.4280
%             49.7660   69.2120   54.2240   71.2930   52.1980   71.8860   56.8360
%             35.5290   49.5180   46.4930   48.3810   35.8390   47.2780   48.2220
%             34.3720   37.9410   35.3290   38.5750   33.9930   39.9950   35.4050
%             24.1730   24.9380   28.9690   25.8750   24.7800   24.6350   28.5140
%             14.3050   15.9870   19.6670   16.4830   15.1460   15.9450   19.7770
%              6.0920    6.5390    7.0420    7.2350    6.9940    6.8220    6.6840
%              4.7550    4.9550    5.2780    5.2160    5.2090    5.4780    5.6640
%              3.8590    3.8520    3.8930    3.9000    3.8870    4.3210    4.4380
%              3.1150    3.1420    2.9350    2.8530    3.0870    3.4660    3.5970
%              2.8670    2.6670    2.4740    2.3500    2.5700    2.9290    3.1700
%              2.4120    2.4050    2.3360    2.0330    2.3500    2.6050    2.7840
%              1.6540    1.6670    1.9090    1.8880    1.7300    1.5920    1.6810
%              1.1300    1.1990    1.2680    1.4880    1.2270    1.1580    1.1300
%              1.0470    1.0400    1.0400    1.1440    1.0750    1.0540    1.0470
%              1.1300    1.1640    1.2060    1.1850    1.2130    1.1850    1.1710
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0
%                   0         0         0         0         0         0         0];
%
%     ldc = struct('ldc', ldc, 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));
%     ldc = struct('lsc', lsc, 'lscSymetric', cat(2, lsc, fliplr(lsc(:,1:end-1))), 'ldcZ', (0:10:180)', 'ldcX', (0:10:180));
%
% %%%%%%%% Method 2 %%%%%%%%%%%%%%%%%%%%%
% %     ldc = struct('ldc', ldc, 'ldcNorm', normalizeLDC(ldc, 0, 1), 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));
% %     ldc.ldcSymetricNorm = cat(2, ldc.ldcNorm, fliplr(ldc.ldcNorm(:,1:end-1)));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}
t = opcodemesh(v',f');
% [~,~,idxx,~,~] = t.intersect(cadModel.campos(60,:)',[-5.0281, 0.9996 0.0111]');
d=[];


%% Dahy added this  this one is to find light using isocell
% % shift a bit the centroids so that rays do not stop at the self
% % face thrown from
% using_isocell=1;
% offset = sign(cadModel.camdir);
% offset = offset*1e-3;
% cadModel.campos = cadModel.campos + offset; 
% 
% region_specular_frames=cadModel.region_specular_frames+1;
% Fij_specular=zeros([size(region_specular_frames,1), cadModel.max_num_specular_faces]);
% Fij_all=zeros([size(region_specular_frames,1), size_n]);
% intersected_specular_faces_in_f_all=zeros([size(region_specular_frames,1), cadModel.max_num_specular_faces]);
% cam_to_spec_array=[];
% 
% hit_faces_count_array=zeros([size_n,1]);
% 
% track_intersections_numbers=[]; % this array contain the [total number of intersected rays, number of intersected spec rays]
% for index=1:size(region_specular_frames)
% %     if using_isocell==1
%         faces_flag_array=zeros([size_n,1]);
% %     end
%     frame=region_specular_frames(index);
%     current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
%     current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
%     current_pose_direction=cadModel.camdir(frame,:);
%     r = vrrotvec(current_pose_direction,[0 0 1]); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
%     M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
%     draysR = drays*M; % coincident rays to the normal vector of the origin point (centroid) of face
%     [hit,tt,idxx,bary,xnodee] = t.intersect(repmat(cadModel.campos(frame,:), size(draysR,1), 1)',draysR');
%     intersections = unique(idxx); % find which faces are hit from the rays
%     intersections(intersections==0)=[];
%     intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
%     if ~isempty(intersections)% extract only indices of faces with parallel normals
%         ind22 = ~isFacing(cadModel.campos(frame,:), cadModel.camdir(frame,:), centroids(intersections, :), normals(intersections, :));
%         % and remove them since they do not face each other
%         intersections(ind22) = [];
%         if using_isocell==1
%             amount_of_intersections  = histc(idxx,intersections);
%             Fij_all(index,intersections)=amount_of_intersections;
%             
%             
%             intersections_of_specular = intersect(intersections,current_pose_spec_faces);
%             amount_of_specular_intersections=[];
%             for eee =1:length(intersections_of_specular)
%                 amount_of_specular_intersections(eee)=sum((idxx==intersections_of_specular(eee)));
%             end
%             if(~isempty(amount_of_specular_intersections))
%                 intersected_specular_faces_in_f_all(index,1:length(intersections_of_specular))=intersections_of_specular;
%                 Fij_specular(index,1:length(intersections_of_specular)) = amount_of_specular_intersections;
%             end
%             
%             faces_flag_array(intersections)=1;
%             
%             track_intersections_numbers=[track_intersections_numbers;[length(intersections), sum(faces_flag_array(current_pose_spec_faces)),length(current_pose_spec_faces)]];
%             ratio_intersected_specular_faces(index)=sum(faces_flag_array(current_pose_spec_faces))/length(current_pose_spec_faces);
%         end
%     end
%     if ~isempty(intersections)
% %         the next line should be for light sources not for specular faces.
% %     hit_faces_count_array(intersections)=hit_faces_count_array(intersections)+1;
%     
%     end    
% end
% Fij_all=Fij_all/size(drays,1);
% Fij_specular=Fij_specular/size(drays,1);
% plot(1:length(track_intersections_numbers),track_intersections_numbers(:,1),'*r')
% hold on 
% plot(1:length(track_intersections_numbers),track_intersections_numbers(:,2),'*b')
% plot(1:length(track_intersections_numbers),track_intersections_numbers(:,3),'*g')
% legend('Total intesections','Intersected specular faces', 'Total number of specular faces')
% title([num2str(rays)," Rays"])
% hold off
% d=[];

%% End here

show_annotated_light_sources_flag=0;
show_auto_detected_light_sources_from_my_method_flag=0;
% show_as_a_heat_map=1;
if (show_annotated_light_sources_flag || show_auto_detected_light_sources_from_my_method_flag)
%% these next few lines is just for viewing the annotated light sources on the 3d mesh. to use it you have to uncomment the line which is : specular_pixels=[sunlight_pixels;artificial_pixels;skylight_pixels]; 
% in the get_specular_faces file. then you should comment it again directly
% because it will mess the work totally.
hit_light_faces_count_array=zeros([size_n,1]);
hit_light_faces_count_array2=zeros([size_n,1]);
region_specular_frames=cadModel.region_specular_frames+1;
for index=1:size(region_specular_frames)
    frame=region_specular_frames(index);
    current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
    current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
    current_pose_cam_pos=cadModel.campos(frame-1,:);
    current_pose_cam_dir=cadModel.camdir(frame-1,:);
    if ~isempty(current_pose_spec_faces)     
        % extract only indices of faces with parallel normals
%         ind22 = ~isFacing(current_pose_cam_pos, current_pose_cam_dir, centroids(current_pose_spec_faces, :), normals(current_pose_spec_faces, :));        
%         % and remove them since they do not face each other
%         current_pose_spec_faces(ind22) = [];
    end
%     if(show_as_a_heat_map)
    hit_light_faces_count_array(current_pose_spec_faces)=hit_light_faces_count_array(current_pose_spec_faces)+1;
%     else
    hit_light_faces_count_array2(current_pose_spec_faces)=200;
%     end
end
% in this line I am removing these faces which appeared only for one time.
current_date=datestr(datetime('now'));
figure, plot_CAD(f(1:length(cadModel.f_c),:), v, '', hit_light_faces_count_array(1:length(cadModel.f_c),:));
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_plus_mono_viewHM.fig']);
figure, plot_CAD(f, v, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_plus_mono_view_plus_sphere.fig']);
hit_light_faces_count_array(hit_light_faces_count_array==1)=0;
figure, plot_CAD(f, v, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_minus_mono_view_plus_sphere.fig']);

figure, plot_CAD(f(1:length(cadModel.f_c),:), v, '', hit_light_faces_count_array2(1:length(cadModel.f_c),:));
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'GT_light_',scene_name,'_REG_',num2str(region_number),'.fig']);
figure, plot_CAD(f, v, '', hit_light_faces_count_array2);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'GT_light_',scene_name,'_REG_',num2str(region_number),'plus_sphere.fig']);
d=[];
end
%% Dahy added this   this one is to find light using rays shooted only to light sources (not complete till 6/5/2019)
%     % shift a bit the centroids so that rays do not stop at the self
% face thrown from
% using_isocell=1;
% offset = sign(cadModel.camdir);
% offset = offset*1e-3;
% cadModel.campos = cadModel.campos + offset;

cam_to_spec_array=[];
region_specular_frames=cadModel.region_specular_frames+1;
hit_light_faces_count_array=zeros([size_n,1]);
angled_rays=drays(1:1000,:);

for index=1:size(region_specular_frames)
%     if (index==9)
%         d=[];
%     end
    frame=region_specular_frames(index);
    current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
    current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
    current_pose_direction=cadModel.camdir(frame,:);
    current_pose_position=cadModel.campos(frame,:);
    rays_from_spec_faces_to_cam(index).frame=frame;
    rays_from_spec_faces_to_cam(index).rays=current_pose_position-centroids(current_pose_spec_faces,:);
    
    faces_vertices=f(current_pose_spec_faces,:);
    vertices_normals=normals(current_pose_spec_faces,:);
    vertices_normals=[vertices_normals,vertices_normals,vertices_normals];
    faces_vertices=v((faces_vertices(:)),:);
    faces_vertices_normal=[vertices_normals(:,1:3);vertices_normals(:,4:6);vertices_normals(:,7:9)];
    
    
    
    required_normals=normals(current_pose_spec_faces,:);
    required_centroids=centroids(current_pose_spec_faces,:);
    % the next three lines to add the faces vertices alongside with center, if you commented them
    % it will use only center
%     rays_from_spec_faces_to_cam(index).rays=[rays_from_spec_faces_to_cam(index).rays;current_pose_position-faces_vertices];
%     required_normals=[required_normals;faces_vertices_normal];
%     required_centroids=[required_centroids;faces_vertices];
    
    for ray_index=1:size(rays_from_spec_faces_to_cam(index).rays,1)
%         ray_index
        current_ray=rays_from_spec_faces_to_cam(index).rays(ray_index,:);
        current_spec_face_normal=required_normals(ray_index,:);
        r = vrrotvec(current_spec_face_normal,current_ray); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
        r(4)=2*r(4);% here we want to increase the angle twice to give the effect of mirror on the normal
        M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
        mirrored_ray = current_ray*M; % coincident rays to the normal vector of the origin point (centroid) of face
        r = vrrotvec(mirrored_ray,[0 0 1]); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
        M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
        angled_rays_rotated = angled_rays*M;
        
        
        temp_index=ones([size(angled_rays_rotated,1),1])*ray_index;
        [hit,tt,idxx,bary,xnodee] = t.intersect(required_centroids(temp_index,:)',angled_rays_rotated');
        intersections=idxx;
%         intersections = unique(idxx); % find which faces are hit from the rays
%         mirrored_ray(intersections==0,:)=[]
        intersections(intersections==0)=[];
        
%         mirrored_ray(isnan(intersections) | isinf(intersections),:) = [];
        intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
        if ~isempty(intersections)
            hit_light_faces_count_array(intersections)=hit_light_faces_count_array(intersections)+1;
%             % HERE we can hit a the second pass from the second hitted face
%             % toward the third
%             current_ray=-1*mirrored_ray;
%             current_spec_face_normal=normals(intersections,:);
%             r = vrrotvec(current_spec_face_normal,current_ray); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
%             r(4)=2*r(4);% here we want to increase the angle twice to give the effect of mirror on the normal
%             M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
%             mirrored_ray = current_ray*M; % coincident rays to the normal vector of the origin point (centroid) of face
%             [hit,tt,idxx,bary,xnodee] = t.intersect(required_centroids',mirrored_ray');
%             intersections=idxx;
%             intersections(intersections==0)=[];
%         
% %         mirrored_ray(isnan(intersections) | isinf(intersections),:) = [];
%             intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
%             if ~isempty(intersections)
% %              hit_light_faces_count_array(intersections)=hit_light_faces_count_array(intersections)+1;   
%             end
        end
    end
end
figure, plot_CAD(f, v, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));

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