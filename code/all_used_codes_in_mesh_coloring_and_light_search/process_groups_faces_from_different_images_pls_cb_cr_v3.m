function process_groups_faces_from_different_images_pls_cb_cr_v3(mesh,faces_correspondences,region_faces,regions_edge_faces,all_used_groups_faces,region_frames,scene_name,folder_path,region_number)
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

if(divide_groups)
    region_faces={};
    max_required_num_faces=5000;
    current_num_faces=size(mesh.f,1);
    required_divisions=ceil(current_num_faces/max_required_num_faces);
    for i=1:required_divisions
        if(i==required_divisions)
            region_faces(i)={(((i-1)*max_required_num_faces+1):current_num_faces)'};
        else
            region_faces(i)={((i-1)*max_required_num_faces+1:i*max_required_num_faces)'};
        end
        
    end
end
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
[~, groups]=get_faces_colors_for_each_group_from_each_frame_separately_4(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number);
% [~,groups]=get_faces_colors_for_each_group_from_each_frame_separately_lab(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh);
%%
clear groups2

tic
for group_index=1:length(region_faces)
    
%     groups2(group_index)=estimate_un_appeared_faces_values_cb_cr(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
    groups2(group_index)=estimate_un_appeared_faces_values_cb_cr_lab(groups(group_index),cell2mat(region_faces(group_index)),mesh,group_index);
    %     next two lines for view purpose only
    groups2(group_index).frame(888).faces=[];
    groups2(group_index).frame(888).values=[];
    groups2(group_index).frame(888).values_a=[];
    groups2(group_index).frame(888).values_b=[];
end
toc

% view_model_from_all_frames_2(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name, faces_textures,faces_vertices_indices_in_textures)
obj_path=['mesh_texturing/',scene_name,'/',num2str(region_number),'/before/'];
obj_name='result';
% obj_path=['C:/results_from_texture_mapping/region',num2str(region_number),'/Waechter_data/'];
% obj_name='textured';
% obj_path=['C:/results_from_texture_mapping/region',num2str(region_number),'/results_2018/'];
% obj_name='result_label';
% view_model_from_all_frames_3(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name,obj_path,obj_name);
view_model_from_all_frames_lab(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name)
d=[];
% groups=groups2;
% %% here I will iterate through each frame alone to transfer the luminance between activated groups only in this frame.
% for index=1:size(region_frames,1)
%     i=region_frames(index);
%     appeared_groups=frames_groups_tracker(i+1,2:frames_groups_tracker(i+1,1)+1);
%     all_edge_faces=regions_edge_faces(appeared_groups);
%     all_edge_faces=cell2mat(all_edge_faces(:));
%     all_groups_faces=[];
%     for k=1:length(appeared_groups)
%         all_groups_faces=[all_groups_faces;groups(appeared_groups(k)).frame(i+1).faces];
%     end
%     [vals]=intersect(all_groups_faces,all_edge_faces);
%     all_correspondences=[];
%     for k=1:length(appeared_groups)
%         group_correspondences=cell2mat(faces_correspondences(appeared_groups(k)));
%         group_correspondences(:,3)=[];
%         sss=logical(zeros(size(group_correspondences)));
%         [~,inds]=intersect(group_correspondences,vals);
%         sss(inds)=1;
%         group_correspondences(sum(sss,2)<2,:)=[];
%         all_correspondences=[all_correspondences;group_correspondences];
%     end
%     
%     
%     if(~isempty(all_correspondences))
%         
%         all_faces_numbers=[];
%         all_faces_values=[];
%         for group_index=1:length(appeared_groups)
%             all_faces_numbers=[all_faces_numbers;groups(appeared_groups(group_index)).frame(i+1).faces];
%             all_faces_values=[all_faces_values;groups(appeared_groups(group_index)).frame(i+1).values];
%         end
%         aaa=zeros(length(mesh.f),1);
%         aaa(all_faces_numbers)=all_faces_values;
%         figure,plot_CAD(mesh.f, mesh.v, '',aaa);
%         delete(findall(gcf,'Type','light'));
%         view=1;
%         new_groups(index).groups=propagate_and_distribute_illumination(groups,all_correspondences,appeared_groups,faces_correspondences,i+1,mesh,view);
%         
%     end
%     
% end
% 
% 
% 
% 
% % for viewing purpose
% % for region 15:
% % 34,68,139,140,141,142,143,144,149,223,224,225,226,227,228,337,338,339,340,341,342,417,601,602,606,633,638,639,
% frame_num=225;%32,469,648,664,665
% all_faces_numbers=[];
% all_faces_values=[];
% all_faces_values_a=[];
% all_faces_values_b=[];
% new_colors=[];
% for group_index=1:length(region_faces)
%     all_faces_numbers=[all_faces_numbers;groups2(group_index).frame(frame_num).faces];
%     all_faces_values=[all_faces_values;groups2(group_index).frame(frame_num).values];
%     all_faces_values_a=[all_faces_values_a;groups2(group_index).frame(frame_num).values_a];
%     all_faces_values_b=[all_faces_values_b;groups2(group_index).frame(frame_num).values_b];
%     
% end
% new_colors(:,:,1)=all_faces_values;
% new_colors(:,:,2)=all_faces_values_a;
% new_colors(:,:,3)=all_faces_values_b;
% % final_colors=(hsv2rgb(new_colors));
% final_colors=uint8(new_colors);
% aaa=zeros(length(mesh.f),3);
% aaa(all_faces_numbers,1)=final_colors(:,:,1);
% aaa(all_faces_numbers,2)=final_colors(:,:,2);
% aaa(all_faces_numbers,3)=final_colors(:,:,3);
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(aaa));
% delete(findall(gcf,'Type','light'));
% d=[];
% 
% 
% 
% 
% 
% 
% aaa=zeros(length(mesh.f),1);
% aaa(hitted_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% delete(findall(gcf,'Type','light'));
% 
% 
% 
% 
% 
% 
% 
% 
% all_faces_numbers=[];
% all_faces_values=zeros(length(mesh.f),size(region_frames,1)+1)-1;
% all_faces_values_a=zeros(length(mesh.f),size(region_frames,1)+1)-1;
% all_faces_values_b=zeros(length(mesh.f),size(region_frames,1)+1)-1;
% 
% new_colors=[];
% for kk=1:size(region_frames,1)
%     
%     frame_num=region_frames(kk,1);%32,469,648,664,665
%     
%     for group_index=1:length(region_faces)
%         if(group_index==7)
%             d=[];
%         end
%         current_faces=groups2(group_index).frame(frame_num).faces;
%         if(~isempty(current_faces))
%             indexes_of_column_from_big_array=all_faces_values(current_faces,1)+3;
%             indexes_of_elements_in_big_array=sub2ind(size(all_faces_values),current_faces,indexes_of_column_from_big_array);
%             all_faces_values(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values;
%             all_faces_values_a(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_a;
%             all_faces_values_b(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_b;
%         end
%         
%     end
% end
% new_colors=zeros(length(mesh.f),1);
% new_colors_a=zeros(length(mesh.f),1);
% new_colors_b=zeros(length(mesh.f),1);
% for kk2=1:length(mesh.f)
%     temp=all_faces_values(kk2,2:end);
%     temp(temp==-1)=[];
%     new_colors(kk2)=mean(temp);
%     temp=all_faces_values_a(kk2,2:end);
%     temp(temp==-1)=[];
%     new_colors_a(kk2)=mean(temp);
%     temp=all_faces_values_b(kk2,2:end);
%     temp(temp==-1)=[];
%     new_colors_b(kk2)=mean(temp);
% end
% new_c(:,:,1)=new_colors;
% new_c(:,:,2)=new_colors_a;
% new_c(:,:,3)=new_colors_b;
% % new_c=lab2rgb(new_c);
% % new_colors=[new_colors,new_colors_a,new_colors_b];
% % final_colors=uint8(new_colors);
% aaa=zeros(length(mesh.f),3);
% aaa(:,1)=new_c(:,:,1);
% aaa(:,2)=new_c(:,:,2);
% aaa(:,3)=new_c(:,:,3);
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(aaa));
% delete(findall(gcf,'Type','light'));
% d=[];
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
