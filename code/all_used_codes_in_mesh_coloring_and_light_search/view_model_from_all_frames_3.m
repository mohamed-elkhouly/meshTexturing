function view_model_from_all_frames_3(groups2,mesh,region_frames,region_faces,folder_path,start_of_faces_indexing,end_of_faces_indexing,region_number,scene_name,obj_path,obj_name)
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global seems_coord_and_faces;

obj_object=read_wobj([obj_path,obj_name,'.obj']);
mkdir([obj_path,'new/']);
save('region21_2018_data_tex_view.mat')
load('region21_2018_data_tex_view.mat')
% object_name='result_label';
number_of_materials=length(obj_object.objects)/2;
materials=[];
ind=1;
% text_data=
for i=1:2:length(obj_object.objects)
    materials=[materials;obj_object.objects(i).data];
    curr_new_faces=obj_object.objects(i+1).data.vertices ;
    obj_object.objects(i+1).data.centroids=get_faces_centers(curr_new_faces,obj_object.vertices) ;
    obj_object.objects(i+1).data.centroids(:,4)=[];
    image_file_name=[obj_path,obj_name,'_',obj_object.objects(i).data,'_map_Kd.png'];texture_image=imread(image_file_name);
    textures_index=obj_object.objects(i+1).data.texture;
%     texture_coord_in_image=obj_object.vertices_texture;
    text_height=round((1-obj_object.vertices_texture(:,2))*size(texture_image,1));% (1-) because its indexes stored as 0 in height is bottom left but matlab 0 height is top left so we are changing to matlab convention 
    text_width=round(obj_object.vertices_texture(:,1)*size(texture_image,2));
    corresponding_faces_in_original_mesh=get_nearest_corresponing_face(mesh.centroids,obj_object.objects(i+1).data.centroids);
    estimated_faces_colors=aaa(corresponding_faces_in_original_mesh,:);
%     save('region21_2018_data_tex_view2.mat')
% load('region21_2018_data_tex_view2.mat')
already_modified=[];
already_modified=false(size(texture_image,1),size(texture_image,2));
textures_index(estimated_faces_colors(:,1)==0,:)=[];
estimated_faces_colors(estimated_faces_colors(:,1)==0,:)=[];
estimated_faces_colors(textures_index(:,1)==0,:)=[];
textures_index(textures_index(:,1)==0,:)=[];

    for m=1:size(estimated_faces_colors,1)
        face_heights=text_height(textures_index(m,:));
        face_widths=text_width(textures_index(m,:));
        current_face_img=texture_image(min(face_heights):max(face_heights),min(face_widths):max(face_widths),:);
        already_modified_pt=already_modified(min(face_heights):max(face_heights),min(face_widths):max(face_widths));
%         subplot(1,2,1);imshow(current_face_img);
        face_heights_1=face_heights-min(face_heights)+1;
        face_widths_1=face_widths-min(face_widths)+1;
        indexes_of_face_d=[];
%         indexes_of_face_d=true(min(face_heights):max(face_heights),min(face_widths):max(face_widths));
        [indexes_of_face,curr_modified]=get_face_indexes(face_heights_1,face_widths_1,already_modified_pt);
        already_modified(min(face_heights):max(face_heights),min(face_widths):max(face_widths))=curr_modified|already_modified_pt;
        r=current_face_img(:,:,1);
        g=current_face_img(:,:,2);
        b=current_face_img(:,:,3);
        
            current_faces_colors_mean=[mean2(r(indexes_of_face)) mean2(g(indexes_of_face)) mean2(b(indexes_of_face))];
            % current_faces_colors_mean=mean(current_faces_textures);
            estimated_face_color=estimated_faces_colors(m,:);
            ratio_estimated_texture_pix=double(estimated_face_color)./current_faces_colors_mean;
            r(indexes_of_face)=uint8(double(r(indexes_of_face))*ratio_estimated_texture_pix(1));
            g(indexes_of_face)=uint8(double(g(indexes_of_face))*ratio_estimated_texture_pix(2));
            b(indexes_of_face)=uint8(double(b(indexes_of_face))*ratio_estimated_texture_pix(3));
               current_face_img(:,:,1)=r;
        current_face_img(:,:,2)=g;
        current_face_img(:,:,3)=b;
        texture_image(min(face_heights):max(face_heights),min(face_widths):max(face_widths),:)=current_face_img;
%        subplot(1,2,2);imshow(current_face_img);
    end
    %%  modifying seems colors
%     load('to_this_p.mat')
    array_of_seems=[];
    for qq=1:size(seems_coord_and_faces,1)
        array_of_seems=[array_of_seems;cell2mat(seems_coord_and_faces(qq))];
    end
    text_height=array_of_seems(:,1:3);
        text_width=array_of_seems(:,4:6);
        already_modified=[];
already_modified=false(size(texture_image,1),size(texture_image,2));
    for m=1:size(array_of_seems,1)
        face_heights=text_height(m,:);
        face_widths=text_width(m,:);
        current_face_img=texture_image(min(face_heights):max(face_heights),min(face_widths):max(face_widths),:);
        already_modified_pt=already_modified(min(face_heights):max(face_heights),min(face_widths):max(face_widths));
%         subplot(1,2,1);imshow(current_face_img);
        face_heights_1=face_heights-min(face_heights)+1;
        face_widths_1=face_widths-min(face_widths)+1;
        indexes_of_face_d=[];
%         indexes_of_face_d=true(min(face_heights):max(face_heights),min(face_widths):max(face_widths));
        [indexes_of_face,curr_modified]=get_face_indexes(face_heights_1,face_widths_1,already_modified_pt);
        already_modified(min(face_heights):max(face_heights),min(face_widths):max(face_widths))=curr_modified|already_modified_pt;
        r=current_face_img(:,:,1);
        g=current_face_img(:,:,2);
        b=current_face_img(:,:,3);
        
            current_faces_colors_mean=[mean2(r(indexes_of_face)) mean2(g(indexes_of_face)) mean2(b(indexes_of_face))];
            % current_faces_colors_mean=mean(current_faces_textures);
            estimated_face_color=aaa(array_of_seems(m,7),:);
            ratio_estimated_texture_pix=double(estimated_face_color)./current_faces_colors_mean;
            r(indexes_of_face)=uint8(double(r(indexes_of_face))*ratio_estimated_texture_pix(1));
            g(indexes_of_face)=uint8(double(g(indexes_of_face))*ratio_estimated_texture_pix(2));
            b(indexes_of_face)=uint8(double(b(indexes_of_face))*ratio_estimated_texture_pix(3));
               current_face_img(:,:,1)=r;
        current_face_img(:,:,2)=g;
        current_face_img(:,:,3)=b;
        texture_image(min(face_heights):max(face_heights),min(face_widths):max(face_widths),:)=current_face_img;
%        subplot(1,2,2);imshow(current_face_img);
    end
    
    %% end of this material ans save the image
    imwrite(texture_image,[obj_path,'new/',obj_name,'_',obj_object.objects(i).data,'_map_Kd.png'])
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
