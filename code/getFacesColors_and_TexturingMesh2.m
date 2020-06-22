function  [faces_colors]=getFacesColors_and_TexturingMesh2(mesh)
% if(using_different_mesh)
%     region_frames=region_frames(:);
% end
warning ('off','all');
[face_text_at_which_image,vertex_exist,face_text_indices_in_img,all_images,faces_coord_in_orig_img]=computeForVisibleFaces2(mesh);% THIS ONE CALCULATE AVERAGE COLORS
#[face_text_at_which_image,vertex_exist,face_text_indices_in_img,all_images,faces_coord_in_orig_img]=computeForVisibleFaces(mesh);

region_frames=mesh.frame_number;%
texture_exist=false(mesh.frame_height,mesh.frame_width,size(region_frames,1));%

% save(['get_faces_colors_',mesh.scene_name,'.mat'])
% %
% load(['get_faces_colors_',mesh.scene_name,'.mat']);

se50 = strel('disk',50);
se1 = strel('disk',1);
textures_images_and_faces=cell(size(region_frames,1),4);
vertices_on_border_info=cell(size(region_frames,1),3);
G_vertices=cell(size(region_frames,1),3);
border_vertices_coord=cell(size(region_frames,1),1);
to_be_removed=[];
for_sorting_purpose=zeros(size(region_frames,1),1);
seems_coord=cell(size(region_frames,1),1);
for index=1:size(region_frames,1)
    
    faces_in_current_frame=find(face_text_at_which_image==index);
    
    vertices_frame=vertex_exist(:,:,index);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    indexes_of_faces_in_image=face_text_indices_in_img(faces_in_current_frame);
    indexes_of_faces_in_image=cell2mat(indexes_of_faces_in_image(:));
    BW=texture_exist(:,:,index);
    BW(indexes_of_faces_in_image)=1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     BW=texture_exist(:,:,index)>0;
    BW_back=BW;
    BW=padarray(BW,[1 1 ],0,'both');
    border_line_of_texture=padarray(imdilate(BW_back,se1),[1 1],0,'both')-imerode(imclose(BW,se1),se1);
    border_line_of_texture(:,[1,end])=[];
    border_line_of_texture([1,end],:)=[];
    
    %     current_frame=rgb2ycbcr(reshape(all_images(index,:,:,:),height,width,3));
    current_frame=(reshape(all_images(index,:,:,:),mesh.frame_height	,mesh.frame_width,3));
    [vertices_on_border_new, vertices_colors_new,~,vertices_coordinates_on_border]=get_border_contour_vertices_and_colors(border_line_of_texture,current_frame,vertices_frame);
    nearest_vertices=[];
    %     [vertices_on_border_new, vertices_colors_new,groups_of_vertices,vertices_coordinates_on_border,nearest_vertices]=get_border_contour_vertices_and_colors_v2(border_line_of_texture,current_frame,vertices_frame);
    
    vertices_on_border=vertices_on_border_new;
    vertices_colors=vertices_colors_new;
    
    BW=BW_back;
    BW = (imdilate(BW,se50));
    [r,c]=find(BW);
    if(isempty(r))
        to_be_removed=[to_be_removed;index];
        continue;
    end
    vr=vertices_coordinates_on_border(:,1);
    vc=vertices_coordinates_on_border(:,2);
    G_vertices(index,1)={[r,c]};
    G_vertices(index,2)={min(r)};
    G_vertices(index,3)={min(c)};
    border_vertices_coord(index,1)={[vr,vc]};
    for_sorting_purpose(index)=length(vertices_on_border);
    vertices_on_border_info(index,1)={vertices_on_border};
    vertices_on_border_info(index,2)={vertices_colors};
    vertices_on_border_info(index,3)={nearest_vertices};
    faces_coord_in_orig_img(faces_in_current_frame,1:3)=faces_coord_in_orig_img(faces_in_current_frame,1:3)-min(r)+1;
    faces_coord_in_orig_img(faces_in_current_frame,4:6)=faces_coord_in_orig_img(faces_in_current_frame,4:6)-min(c)+1;
    a=all_images(index,min(r):max(r),min(c):max(c),:);
    %     a=rgb2ycbcr(reshape(a,[size(a,2) size(a,3) size(a,4)]));
    a=(reshape(a,[size(a,2) size(a,3) size(a,4)]));
    textures_images_and_faces(index,1)={a};
    textures_images_and_faces(index,2)={faces_in_current_frame};
    textures_images_and_faces(index,3)={max(r)-min(r)+1};
    textures_images_and_faces(index,4)={max(c)-min(c)+1};
end
textures_images_and_faces(to_be_removed,:)=[];
G_vertices(to_be_removed,:)=[];
vertices_on_border_info(to_be_removed,:)=[];
border_vertices_coord(to_be_removed)=[];
% save('after_sorting.mat');
% load('after_sorting.mat');
textures_images_and_faces=create_A_omega_F_matrices_v2(vertices_on_border_info,mesh,border_vertices_coord,G_vertices,textures_images_and_faces);
% 
% save(['get_faces_colors_',mesh.scene_name,'.mat'],'-v7.3');
% %
% load(['get_faces_colors_',mesh.scene_name,'.mat']);
faces_colors=uint8(zeros(size(mesh.f,1),3));
textures=textures_images_and_faces(:,1);
faces_in_frame=textures_images_and_faces(:,2);
for i=1:length(textures)
    current_textue=cell2mat(textures(i));
    [height,width,~]=size(current_textue);
    red_channel=current_textue(:,:,1);
    green_channel=current_textue(:,:,2);
    blue_channel=current_textue(:,:,3);
faces_in_current_texture=cell2mat(faces_in_frame(i));
    face_coordinate_in_image=faces_coord_in_orig_img(faces_in_current_texture,:);
    x_coord=face_coordinate_in_image(:,1:3);
    y_coord=face_coordinate_in_image(:,4:6);
    
    min_indh=face_coordinate_in_image(:,7);
    min_indw=face_coordinate_in_image(:,8);
    for k=1:length(faces_in_current_texture)
        current_face=faces_in_current_texture(k);
        indh=x_coord(k,:);
        indw=y_coord(k,:);
        [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
            height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
            if(min_indw(k)<1);width_inds=width_inds+(min_indw(k))-1;end
    if(min_indh(k)<1);height_inds=height_inds+(min_indh(k))-1;end
    width_inds(width_inds>width)=width;% this step moved to here
    height_inds(height_inds>height)=height ;% this step moved to here
    width_inds(width_inds<1)=1;% this step moved to here
    height_inds(height_inds<1)=1;% this step moved to here
    
            img_indices=sub2ind([size(current_textue,1) size(current_textue,2)],height_inds,width_inds);
            
            faces_colors(current_face,:)=[mean(red_channel(img_indices)),mean(green_channel(img_indices)),mean(blue_channel(img_indices))];
    end
end
figure,plot_CAD(mesh.f, mesh.v, '',faces_colors);
delete(findall(gcf,'Type','light'));
mkdir(['Result']);
mkdir(['Result/',mesh.scene_name]);
mkdir(['Result/',mesh.scene_name,'/before']);
mkdir(['Result/',mesh.scene_name,'/after']);

tex_path=['Result/',mesh.scene_name,'/before'];
combine_textures_in_one_for_consistent_texture(mesh,textures_images_and_faces,faces_coord_in_orig_img,tex_path,seems_coord);
d=[];
