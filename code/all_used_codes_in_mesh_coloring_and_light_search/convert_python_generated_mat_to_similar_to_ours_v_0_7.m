function   [mesh,image_height,image_width]=convert_python_generated_mat_to_similar_to_ours_v_0_7(in_var,original_path,simplified,folder_path,region_number,scene_name,smooth,simplified_version)
image_height=480;
image_width=640;
mesh.v=double(in_var{1});
% mesh.v_c=double(in_var{2})/255;
% mesh.v_n=double(in_var{3});
mesh.f=cell2mat(in_var{2})+1;
% mesh.f_c=meshFaceColors(mesh.v_c, mesh.f);



% mesh.areas = meshArea(mesh.f,mesh.v);
region_frames=[];

%% read camera poses and intrinsics
mesh=read_poses_and_intrinsics_not_matterport(mesh,folder_path,scene_name);
% v=mesh.v;
% f=mesh.f;
% pose=mesh.pose_matrix;
% intrinsics=mesh.intrinsics;
% campos=mesh.campos;
t = opcodemesh((mesh.v)',(mesh.f)');
step=1;
mesh.frame_face_mapping(3000/step,image_height,image_width)=0;
size_of_image=(image_height*image_width);
[hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],1:size_of_image);
temp_ones=ones([size_of_image,1]);
tic
for i=1:step:length(mesh.pose)
    i
    break;
    [rays_directions,~]=get_ray_direction(mesh.pose(i).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
%     temp_index=ones([size(rays_directions,2),1])*i;
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_ones*i,:)',rays_directions);
    mesh.frame_face_mapping(i,:,:)=reshape(idxx,[image_height image_width]);
end
toc

%% calculate region frames
% if(1); [~,region_frames]=calculate_region_frames(mesh,folder_path,region_frames,region_number); end
load('lounge_0.2_.mat')
smooth=1;
mesh.region_frames=0:length(mesh.pose)-1;
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
%% smooth region using neigbourhood
mkdir([folder_path,'/smoothed_regions/']);
if (smooth)
    %  figure, plot_CAD(mesh.f, mesh.v, '');
    try
        delete([folder_path,'/smoothed_regions/','smoothed_region',num2str(region_number),simplified_version,'_',scene_name,'.mat']);
        load([folder_path,'/smoothed_regions/','smoothed_region',num2str(region_number),simplified_version,'_',scene_name,'.mat']);
    catch
        [mesh.v,mesh.f]=smooth_mesh_v_0_2(region_number,mesh.v,mesh.f,mesh.normals,mesh.centroids);
        save([folder_path,'/smoothed_regions/','smoothed_region',num2str(region_number),simplified_version,'_',scene_name,'.mat'],'mesh','-v7.3');
    end
    % figure, plot_CAD(mesh.f, mesh.v, '');
end
%% get region frames by projecting mesh
% current_cam_pos=1;
%  [all_image_pixels(2,:), all_image_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
%  [rays_directions,~]=get_ray_direction(mesh.pose(current_cam_pos).pose_matrix,mesh.intrinsics,all_image_pixels);
%  t = opcodemesh(mesh.v',mesh.f');
%  temp_index=ones([size(rays_directions,2),1])*current_cam_pos;
%             [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);

%%

fill_holes=0;
if (fill_holes)
    max_face_area=(max(mesh.areas)+min(mesh.areas))/2;
intersect_thrsh=0.2;% this was ratio intersection,to decide to merge regions or no
intersect_thrsh2=0.5;
angle_thrsh=0.3;% this is the threshold of angle between the planes normal, to decide to merge regions or no
dividing_distance=0.35;% this is the distance used to divide the axes (x or y or z) to parts to fit plane to each.
view_after_fill=0;
mesh=fill_missing_mesh_using_planes_fitting(mesh,folder_path,scene_name,region_number,view_after_fill,dividing_distance,max_face_area,intersect_thrsh,angle_thrsh,intersect_thrsh2);
end
%%
d=[];
%%
if(smooth||fill_holes)
% mesh.rho=double(in_var{6});
mesh.areas = meshArea(mesh.f,mesh.v);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.luxmeter.patches=[];
else
    mesh.normals = meshFaceNormals(mesh.v,mesh.f);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
end
% if simplified
%     try  % this try and catch to skip this part in case that I didn't annotate this region for lights
%         load(original_path);
%         centroids = meshFaceCentroids(dahy{1},cell2mat(dahy{4})+1);% of the original
%         light1=double(dahy{5})+1;% of the original
%         light1_faces_centers=centroids(light1(:),:);% of the original
%         for i=1:length(light1_faces_centers)
%             [~,ind(i)]=min(abs(sum(abs(mesh.centroids-light1_faces_centers(i,:)),2))); %find the minimum distance between new centroids and old light faces centroids
%         end
%         mesh.lightPatches.light1=unique(ind);
%         mesh.lightPatches.allLights=mesh.lightPatches.light1;
%     catch
%         mesh.lightPatches.light1=double(in_var{5})+1;
%         mesh.lightPatches.allLights=double(in_var{5})+1;
%     end
% else
%     mesh.lightPatches.light1=double(in_var{5})+1;
%     mesh.lightPatches.allLights=double(in_var{5})+1;
% end
% mesh=get_specular_faces_v_0_3(mesh,folder_path,region_number,scene_name);