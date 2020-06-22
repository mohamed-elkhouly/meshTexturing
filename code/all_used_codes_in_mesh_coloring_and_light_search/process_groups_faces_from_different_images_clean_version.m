function process_groups_faces_from_different_images_clean_version(mesh,faces_correspondences,region_faces,regions_edge_faces,all_used_groups_faces,region_frames,scene_name,folder_path,region_number)
% in this function we want to find the color for each face from all images.
% clear all
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));

using_different_mesh=0;

  start_of_faces_indexing=0;  
  end_of_faces_indexing=size(mesh.f,1);
% end
% [num_faces_in_frames, groups, original_faces_tracking, final_faces, final_vertices, final_faces_colors]=get_faces_colors_for_each_group_from_each_frame_separately_3(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh)
[~,groups]=get_faces_colors_from_each_frame_separately(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh);
% [~,groups]=get_faces_colors_for_each_group_from_each_frame_separately5(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [num_faces_in_frames, groups, faces_textures,faces_vertices_indices_in_textures]=get_faces_colors_for_each_group_from_each_frame_separately_2(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [~, groups]=get_faces_colors_for_each_group_from_each_frame_separately_4(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [~,groups]=get_faces_colors_for_each_group_from_each_frame_separately_lab(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh);
%%
clear groups2

tic
group_index=1;
    groups2(group_index)=estimate_un_appeared_faces_values_cb_cr(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
    groups2(group_index).frame(max(region_frames)).faces=[];
    groups2(group_index).frame(max(region_frames)).values=[];
    groups2(group_index).frame(max(region_frames)).values_a=[];
    groups2(group_index).frame(max(region_frames)).values_b=[];
toc

view_model_from_all_frames(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name)

% to view intermediate
save_frames_into_ply(mesh,region_frames,region_faces,groups2)

d=[];
