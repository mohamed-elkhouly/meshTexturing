function remove_texture_v0_5()
clear all
image_height=1024;
image_width=1280;
% load('1LXtFkjw3qL_1.ply.mat');
% mesh=convert_python_generated_mat_to_similar_to_ours(dahy);
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
scene_path='D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux/dataset/';
matterport_scene=1;
region_number=21;

scene_name='1LXtFkjw3qL_1'; %2,15,17,21,26,29
% scene_name='lounge';
%   scene_name='82sE5b5pLXE_1'; %0,1,3
use_simplified=0;
smooth=1;
region_file_no_simplification_path=[scene_path,scene_name,'/original_regions/','region',num2str(region_number),'.mat'];
folder_path=[scene_path,scene_name];
use_simplified=0;
if use_simplified>0
    simplified_version='_0.2_';
    insider_directory=['simplified_regions/','region',num2str(region_number),'/'];
else
    simplified_version='';
    insider_directory='';
end
if smooth
    mesh_file=['meshregion',num2str(region_number),simplified_version,'smmothed','.mat'];
else
    mesh_file=['meshregion',num2str(region_number),simplified_version,'.mat'];
end
region_file_all=['region',num2str(region_number),simplified_version,'.mat'];
% load('lounge_0.2_.mat');
% mesh.region_frames=0:length(mesh.pose)-1;
try
%                     delete([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    load([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    
catch
    load([scene_path,scene_name,'/original_regions/',insider_directory,region_file_all])
    tic
    if(matterport_scene)
        mesh=convert_python_generated_mat_to_similar_to_ours_v_0_6(dahy,region_file_no_simplification_path,use_simplified,folder_path,region_number,scene_name,smooth);
    else
        [mesh,image_height,image_width]=convert_python_generated_mat_to_similar_to_ours_v_0_7(dahy,region_file_no_simplification_path,use_simplified,folder_path,region_number,scene_name,smooth,simplified_version);
    end
    toc
    mkdir([scene_path,scene_name,'/created_mesh_regions/']);
    save([scene_path,scene_name,'/created_mesh_regions/',mesh_file],'-v7.3');
end

tic
mesh.f_lum(:)=0
[required_edges_faces,~]=get_faces_on_hard_edges(mesh.f,mesh.v,7);
time_to_find_3d_edges=toc
mesh.f_lum=zeros(size(mesh.f,1),1);
mesh.f_lum(required_edges_faces)=255;
figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
%

t = opcodemesh((mesh.v)',(mesh.f)');
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
region_frames=mesh.region_frames;

mesh=find_2d_edges(mesh,region_frames,scene_name,image_height,image_width,t);


% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
detected_edge_faces_using_images1=sum((mesh.f_lum>0),2)>0;
% create a new mesh which will contain the only the edges  faces itself and
% the faces touching theses edges
tempmesh_faces=mesh.f;
% add big value to faces which did not appear at all in projections  to be
% removed in next lines with edges.
mesh.f_lum(~mesh.appeared_faces_in_all_projections)=255;
% next three lines we remove faces corresponding to edges
detected_edge_faces_using_images2=sum((mesh.f_lum>0),2)>0;
mesh.v=[mesh.v;min(mesh.v)-0.00001];
mesh.f(detected_edge_faces_using_images2,:)=size( mesh.v,1);
fSets=create_groups_from_mesh(mesh,tempmesh_faces,detected_edge_faces_using_images2);
mesh.f=tempmesh_faces;
mesh.v(end,:)=[];
[mesh,region_faces,all_used_groups_faces,regions_edge_faces]=find_border_faces_of_mesh(mesh,fSets);

figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
% dot_prod_matrix=create_dot_prod_matrix(mesh,regions_edge_faces);
dot_prod_matrix=[];
plot_lines=1;
[faces_correspondences,all_used_edge_faces]=find_nearest_faces_from_other_groups(mesh,regions_edge_faces,region_faces,region_number,tempmesh_faces,dot_prod_matrix,plot_lines);
process_groups_faces_from_different_images(mesh,[],[],[],all_used_groups_faces,region_frames,scene_name,folder_path,region_number);
