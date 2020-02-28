function process_groups_faces_pure_vertices(mesh,faces_correspondences,region_faces,regions_edge_faces,all_used_groups_faces,region_frames,scene_name,folder_path,region_number)
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
% [~, groups]=get_faces_colors_for_texturing_mesh(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [~, groups]=get_faces_colors_for_texturing_mesh_vertices(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
[~, groups,faces_colors]=get_faces_colors_for_texturing_mesh_vertices2(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% save(['after_getting_faces_colors',num2str(region_number),'.mat']);
% load(['after_getting_faces_colors',num2str(region_number),'.mat']);
% new_faces_luminance=balance_Groups_Luminance3(faces_colors,mesh);
% % save('up_to_estimated_faces_smoothed21.mat');
% % load('up_to_estimated_faces_smoothed21.mat');
% global iteration;
% iteration=0;
% load('LDC/ldc_led.mat');
% ldc = struct('ldc', ldc, 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));
% 
% % tic;[F] = viewFactors4OPCODE_sparse3(mesh, 1000, 1);toc
% % f1=viewFactors4OPCODE_sparse3(mesh, 1000, 1);
% F=[];% it is not used so no problem;
% F_ldc=viewFactors4OPCODE_sparse3(mesh, 500, 1, ldc,F , (1:size(mesh.f,1))');
% % tic;[F_ldc_lsc] = viewFactors4OPCODE_sparse3(mesh, 1000, 1, lsc, , mesh.luxmeter.patches);toc 
% % save(['up_to_estimated_faces',num2str(region_number),'.mat']);
load(['up_to_estimated_faces',num2str(region_number),'.mat']);
nbf=size(F_ldc,1);
% agreement=check_agreement_with_LDC(F_ldc,new_faces_luminance);
indexes=1:nbf;
tic;
% F_ldc_lsc=sparse(F_ldc_lsc);
F_ldc=sparse(indexes,indexes,[ones(size(mesh.f,1),1)])*F_ldc;
% K=speye(nbf,nbf)-F_ldc_lsc;
K=F_ldc;
toc;

E=K*double(new_faces_luminance);
figure,plot_CAD(mesh.f, mesh.v, '',E);title('difference');delete(findall(gcf,'Type','light'));
E2=K*E;
E3=K*E2;

E1=E+abs(min(E));
E1=E./max(E);
aa=double(new_faces_luminance);
aa=aa./max(aa);
b=((E1-aa)./(aa+1));
% a=double(new_faces_luminance)-(E);
figure,plot_CAD(mesh.f, mesh.v, '',b);
title('difference1')
delete(findall(gcf,'Type','light'));
E2=K*double(a);
figure,plot_CAD(mesh.f, mesh.v, '',E2);
title('E2')
delete(findall(gcf,'Type','light'));
a2=a-E2;
figure,plot_CAD(mesh.f, mesh.v, '',a2);
title('a2')
delete(findall(gcf,'Type','light'));
%   K.R = E


clear groups2;
group_index=1;
% groups2(group_index)=estimate_un_appeared_faces_values_pure(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
groups2(group_index)=estimate_un_appeared_faces_values_for_balancing(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
groups2(group_index).frame(max(region_frames(:,1))+1).faces=[];
groups2(group_index).frame(max(region_frames(:,1))+1).values=[];
groups2(group_index).frame(max(region_frames(:,1))+1).values_a=[];
groups2(group_index).frame(max(region_frames(:,1))+1).values_b=[];
view_model_from_all_frames_pure(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name)
d=[];

