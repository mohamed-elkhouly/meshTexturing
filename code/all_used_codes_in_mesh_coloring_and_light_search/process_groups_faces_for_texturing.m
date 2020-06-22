function process_groups_faces_for_texturing(mesh,faces_correspondences,region_faces,regions_edge_faces,all_used_groups_faces,region_frames,scene_name,folder_path,region_number)
% in this function we want to find the color for each face from all images.
clear all
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
% save('required_for_process_groups_faces_from_different_images_region_15.mat');
%  save('required_for_process_groups_faces_from_different_images_region_0_lounge_0.2_.mat','-v7.3');

%  load('required_for_process_groups_faces_from_different_images_region_0_lounge_0.2_.mat');
load('required_for_process_groups_faces_from_different_images_region_21.mat');
% load('required_for_process_groups_faces_from_different_images_region_0.mat');
% load('required_for_process_groups_faces_from_different_images_region_15.mat');
%  load('required_for_process_groups_faces_from_different_images_region_29.mat');
%  load('required_for_process_groups_faces_from_different_images_region_26.mat');
% load('required_for_process_groups_faces_from_different_images_region_2.mat');
% load('required_for_process_groups_faces_from_different_images_region_17.mat');
% load('required_for_process_groups_faces_from_different_images_region_0_82se.mat');
% load('lounge_0.1_.mat');
using_different_mesh=0;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_c);
% delete(findall(gcf,'Type','light'));




% unify groups in one group
unify_groups=1;
if(unify_groups)
    region_faces_backup=region_faces;
    temp=[];
    for group_index=1:length(region_faces)
        temp=[temp;cell2mat(region_faces(group_index))];
    end
    region_faces={temp};
    clear temp;
end
divide_groups=0;


%%
if(~using_different_mesh)
regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end


end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;% -1 to go down to the last face number in the last region,+1 to use faces numbers as indexes in matlab
else
  start_of_faces_indexing=0;  
  end_of_faces_indexing=size(mesh.f,1);
end
% [num_faces_in_frames, groups, original_faces_tracking, final_faces, final_vertices, final_faces_colors]=get_faces_colors_for_each_group_from_each_frame_separately_3(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh)
% [~,groups]=get_faces_colors_for_each_group_from_each_frame_separately(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh);
% [~,groups]=get_faces_colors_for_each_group_from_each_frame_separately5(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [num_faces_in_frames, groups, faces_textures,faces_vertices_indices_in_textures]=get_faces_colors_for_each_group_from_each_frame_separately_2(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
[~, groups]=get_faces_colors_for_texturing_mesh(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
clear groups2;
group_index=1;
groups2(group_index)=estimate_un_appeared_faces_values_pure(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
view_model_from_all_frames_pure(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name)
d=[];
