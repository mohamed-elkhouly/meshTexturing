function consistent_mesh_colors()
% important note: for matterport 3d scenes you will need to project the
% regions from their original ply mesh file for the whole scene, which we
% did not provide here, we used opengl for this and managed to get the
% desired scene alone, for this reason you will find some differences between
% reported results on matterport scenes and the output results from here.
clear all;
image_height=1024;image_width=1280; % for matterport
% image_height=480;image_width=640; % for lounge and apt0;

scene_path='D:/';
region_number=17;
folder_path=[scene_path,'region',num2str(region_number),'/'];
scene_name='1LXtFkjw3qL_1';
ply_name=['region',num2str(region_number),'.ply'];
our_mesh_file=['region',num2str(region_number),'clean.mat'];
try
    % load previously processed mesh data (only used for fast trials, but new models has to be preprocessed)
%                     delete([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    load([scene_path,scene_name,'/created_mesh_regions/',our_mesh_file]);
catch
    % load mesh data
    mesh=load_mesh_data(ply_name, folder_path, image_height, image_width);
    mkdir([scene_path,scene_name,'/created_mesh_regions/']);
    save([scene_path,scene_name,'/created_mesh_regions/',our_mesh_file],'-v7.3');
end
appeared_faces=find(mesh.appeared_faces);
all_used_groups_faces=[appeared_faces,ones(size(appeared_faces,1),1)];
region_frames=(mesh.original_frame_number)';
% region_frames=0:(length(mesh.campos)-1);
process_groups_faces_from_different_images_clean_version(mesh,[],{appeared_faces},[],all_used_groups_faces,region_frames,scene_name,folder_path,region_number);
