function view_model_from_all_frames(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name, original_faces_tracking, final_faces, final_vertices, final_faces_colors)
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

aaa=uint8(aaa);
new_vertices=zeros(size(mesh.f,1)*3,3);
new_faces=zeros(size(mesh.f));
new_colors=zeros(size(mesh.f,1)*3,3);
ind=1;
for i=1:size(mesh.f,1)
    new_faces(i,:)=[ind,ind+1,ind+2];
    current_face_verts=mesh.f(i,:);
    current_vertices=mesh.v(current_face_verts(:),:);
    current_colores=aaa(i,:);
    current_colores=[current_colores;current_colores;current_colores];
    new_vertices(ind:ind+2,:)=current_vertices;
    new_colors(ind:ind+2,:)=current_colores;
    ind=ind+3;
end
% 
% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% delete(findall(gcf,'Type','light'));
plywrite(['our_face_based_estimations.ply'],new_faces,new_vertices,new_colors);
% for i=1:size(mesh.f,1)
% current_faces_indexes=cell2mat(original_faces_tracking(i));
% current_faces_colors=final_faces_colors(current_faces_indexes,:);
% current_faces_colors_mean=mean(current_faces_colors);
% estimated_face_color=aaa(i,:);
% ratio_estimated_texture_pix=double(estimated_face_color)./current_faces_colors_mean;
% final_faces_colors(current_faces_indexes,:)=uint8(double(current_faces_colors).*ratio_estimated_texture_pix);
% end

% figure,plot_CAD(final_faces, final_vertices, '',final_faces_colors);
% delete(findall(gcf,'Type','light'));

% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(new_colors));
% delete(findall(gcf,'Type','light'));
toc

% write_mesh_down_into_images2(mesh,region_frames,final_faces,final_vertices,final_faces_colors,scene_name,region_number,0);
% write_mesh_down_into_images(folder_path,region_frames,end_of_faces_indexing,start_of_faces_indexing,aaa,scene_name,region_number,0);
% write_mesh_down_into_images(folder_path,region_frames,end_of_faces_indexing,start_of_faces_indexing,((mesh.f_c)*255),scene_name,region_number,1);
    
d=[];