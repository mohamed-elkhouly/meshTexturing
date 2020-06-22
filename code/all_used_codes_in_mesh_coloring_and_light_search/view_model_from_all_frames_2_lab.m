function view_model_from_all_frames_2_lab(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name, faces_textures,faces_vertices_indices_in_textures)
tic
region_frames=region_frames+1;
% group_index=76
% all_required_faces_for_group=cell2mat(region_faces(group_index));
all_faces_numbers=[];
all_faces_values=zeros(length(mesh.f),size(region_frames,1)+1)-1;
all_faces_values_a=zeros(length(mesh.f),size(region_frames,1)+1)-1;
all_faces_values_b=zeros(length(mesh.f),size(region_frames,1)+1)-1;

new_colors=[];
for kk=1:size(region_frames,1)
    
    frame_num=region_frames(kk,1);%32,469,648,664,665
    
    for group_index=1:length(region_faces)
        %      if(group_index==76)
        %         d=[];
        %     end
        current_faces=groups2(group_index).frame(frame_num).faces;
        if(~isempty(current_faces))
                    if(group_index==4)
                    d=[];
                end
            indexes_of_column_from_big_array=all_faces_values(current_faces,1)+3;
            indexes_of_elements_in_big_array=sub2ind(size(all_faces_values),current_faces,indexes_of_column_from_big_array);
            all_faces_values(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values;
            all_faces_values_a(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_a;
            all_faces_values_b(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_b;
            all_faces_values(current_faces,1)=all_faces_values(current_faces,1)+1;
        end
        
    end
end
new_colors=zeros(length(mesh.f),1);
new_colors_a=zeros(length(mesh.f),1);
new_colors_b=zeros(length(mesh.f),1);

% current_faces=groups2(4).frame(469).faces;
% for kk2=1:length(current_faces)
%     temp1=all_faces_values(current_faces(kk2),2:end);
%     temp1(temp1==-1|temp1==0)=[];
%     temp2=all_faces_values_a(current_faces(kk2),2:end);
%     temp2(temp2==-1|temp2==0)=[];
%     temp3=all_faces_values_b(current_faces(kk2),2:end);
%     temp3(temp3==-1|temp3==0)=[];
%     if(~isempty(temp1)&&~isempty(temp2)&&~isempty(temp3))
%         
%         new_colors(current_faces(kk2))=median(temp1);        
%         new_colors_a(current_faces(kk2))=median(temp2);        
%         new_colors_b(current_faces(kk2))=median(temp3);
%     else
%         d=[];
%         
%     end
% end



for kk2=1:length(mesh.f)
    temp1=all_faces_values(kk2,2:end);
    temp1(temp1==-1|temp1==0)=[];
    temp2=all_faces_values_a(kk2,2:end);
    temp2(temp2==-1|temp2==0)=[];
    temp3=all_faces_values_b(kk2,2:end);
    temp3(temp3==-1|temp3==0)=[];
    if(~isempty(temp1)&&~isempty(temp2)&&~isempty(temp3))
        
%         new_colors(kk2)=median(temp1);        
%         new_colors_a(kk2)=median(temp2);        
%         new_colors_b(kk2)=median(temp3);
        
        new_colors(kk2)=trimmean(temp1,30);        
        new_colors_a(kk2)=trimmean(temp2,30);        
        new_colors_b(kk2)=trimmean(temp3,30);
        
    end
end
new_c(:,:,1)=new_colors;
new_c(:,:,2)=new_colors_a;
new_c(:,:,3)=new_colors_b;
% new_c=lab2rgb(new_c);
% new_colors=[new_colors,new_colors_a,new_colors_b];
% final_colors=uint8(new_colors);
aaa=zeros(length(mesh.f),3);
aaa(:,1)=new_c(:,:,1);
aaa(:,2)=new_c(:,:,2);
aaa(:,3)=new_c(:,:,3);
aaa=uint8(aaa);

for i=1:size(mesh.f,1)
% current_faces_textures=cell2mat(faces_textures(i));
 img=(cell2mat(faces_textures(i)));
 if(~isempty(img))
current_faces_colors_mean=[mean2(img(:,:,1)) mean2(img(:,:,2)) mean2(img(:,:,3))];
% current_faces_colors_mean=mean(current_faces_textures);
estimated_face_color=aaa(i,:);
ratio_estimated_texture_pix=double(estimated_face_color)./current_faces_colors_mean;
img(:,:,1)=uint8(double(img(:,:,1))*ratio_estimated_texture_pix(1));
img(:,:,2)=uint8(double(img(:,:,2))*ratio_estimated_texture_pix(2));
img(:,:,3)=uint8(double(img(:,:,3))*ratio_estimated_texture_pix(3));
faces_textures(i)={img};
 end
end
tex_path=['mesh_texturing/',scene_name,'/',num2str(region_number),'/after'];
combine_textures_in_one(mesh,faces_textures,faces_vertices_indices_in_textures,tex_path);
% figure,plot_CAD(final_faces, final_vertices, '',final_faces_colors);
% delete(findall(gcf,'Type','light'));

% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(new_colors));
% delete(findall(gcf,'Type','light'));
toc

write_mesh_down_into_images2(mesh,region_frames,final_faces,final_vertices,final_faces_colors,scene_name,region_number,0);
% write_mesh_down_into_images(folder_path,region_frames,end_of_faces_indexing,start_of_faces_indexing,aaa,scene_name,region_number,0);
% write_mesh_down_into_images(folder_path,region_frames,end_of_faces_indexing,start_of_faces_indexing,((mesh.f_c)*255),scene_name,region_number,1);
    
d=[];
