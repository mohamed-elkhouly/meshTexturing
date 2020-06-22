function  [num_faces_in_frames,groups,faces_colors]=get_faces_colors_for_texturing_mesh_vertices2(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number)
if(using_different_mesh)
    region_frames=region_frames(:);
end

groups(length(region_faces)).frames_index=[];
groups(length(region_faces)).should_be_estimated=[];

face_text_at_which_image=zeros(size(mesh.f,1),1);
stored_hitted_faces=cell(size(region_frames,1),1);

face_text_indices_in_img=cell(size(mesh.f,1),1);
faces_texture_information=zeros(size(mesh.f,1),2);% we store in it the frame of texture of each face, and the length of pixels in texture.
tic
width=1280;
height=1024;
texture_exist=false(height,width,size(region_frames,1));
vertex_exist=(zeros(height,width,size(region_frames,1)));
faces_coord_in_orig_img=zeros(size(mesh.f,1),6);
all_images=uint8(zeros(size(region_frames,1),height,width,3));
intrinsics=mesh.intrinsics;
for index=1:size(region_frames,1)
    
    current_vertices_frame=vertex_exist(:,:,index);
    i=region_frames(index);
    
    [height,width,L_channel,a_channel,b_channel,all_images]=prepare_our_image(i,folder_path,index,all_images) ;
    
    [hitted_faces_2,faces_places_in_image,back_idxx,index_f,index_in_hitted_faces_1,index_in_all_used_group_faces_1]=get_hitted_faces_in_mesh(i,using_different_mesh,folder_path,mesh,start_of_faces_indexing,end_of_faces_indexing,all_used_groups_faces);
    
    if(isempty(hitted_faces_2))
        continue;
    end
    
    ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces_2, :), mesh.normals(hitted_faces_2, :));
    if(sum(ind22)>1)
        d=[];
    end
    hitted_faces_2(ind22)=[];
    index_in_hitted_faces_1(ind22)=[];
    index_in_all_used_group_faces_1(ind22)=[];
    if(isempty(index_in_all_used_group_faces_1))
        continue;
    end
    all_indexes_in_idxx=back_idxx(:,2);
    % tic
    stored_hitted_faces(index)={hitted_faces_2};
    pose_matrix=mesh.pose(i+1).pose_matrix;
    rotation_matrix=pose_matrix(1:3,1:3)';
    camera_position_in_world=pose_matrix(1:3,4);
    translation=-1*rotation_matrix*camera_position_in_world;
    RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
    faces_places_in_image_2=faces_places_in_image;
    faces_places_in_image_2(index_in_hitted_faces_1(length(hitted_faces_2))+1)=length(index_f)+1;
    for ui=1:length(hitted_faces_2)
        m=index_in_hitted_faces_1(ui);
        length_required_indexes_for_access_image=length(all_indexes_in_idxx(index_f(faces_places_in_image_2(m):faces_places_in_image_2(m+1)-1)));
        % store the frame number in the first column and the texture indexes in the
        % second column.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(length_required_indexes_for_access_image>faces_texture_information(hitted_faces_2(ui),2))
            faces_texture_information(hitted_faces_2(ui),1)=index;
            faces_texture_information(hitted_faces_2(ui),2)=length_required_indexes_for_access_image;
            vertices_indexes_of_current_face=mesh.f(hitted_faces_2(ui),:);
            current_face_vertices=[mesh.v(vertices_indexes_of_current_face,:),[1;1;1]];
            
            point_2d=projection_matrix*current_face_vertices';
            point_2d=point_2d(1:2,:)./point_2d(3,:);
            indw=round(point_2d(1,:));
            indh=round(point_2d(2,:));
            vertices_flag=indw>width;% to know which vertices out of frame.
            indw(indw>width)=width;
            vertices_flag=vertices_flag|indh>height;
            indh(indh>height)=height;
            indw(indw<1)=1;
            indh(indh<1)=1;
            vertices_indices=sub2ind([height width],indh,indw);
            current_vertices_frame(vertices_indices(~vertices_flag))=vertices_indexes_of_current_face(~vertices_flag);% store vertices numbers in its corresponding position in frame& in the same time exclude out of frame vertices;
            [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
            height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
            img_indices=sub2ind([height width],height_inds,width_inds);
            
            if ~isempty(img_indices)
                faces_coord_in_orig_img(hitted_faces_2(ui),:)=[indh,indw];
                face_text_at_which_image(hitted_faces_2(ui))=index;
            end
            face_text_indices_in_img(hitted_faces_2(ui))={img_indices(:)};
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    vertex_exist(:,:,index)=current_vertices_frame;
end

num_faces_in_frames=[];
time_to_get_faces_colors=toc
% stored_hitted_faces
save(['get_faces_colors_',num2str(region_number),'.mat'])

%
load(['get_faces_colors_',num2str(region_number),'.mat']);
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
    current_frame=(reshape(all_images(index,:,:,:),height,width,3));
    [vertices_on_border_new, vertices_colors_new,groups_of_vertices,vertices_coordinates_on_border]=get_border_contour_vertices_and_colors(border_line_of_texture,current_frame,vertices_frame);
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
faces_colors=uint8(zeros(size(mesh.f,1),3));
textures=textures_images_and_faces(:,1);
faces_in_frame=textures_images_and_faces(:,2);
for i=1:length(textures)
    current_textue=cell2mat(textures(i));
    red_channel=current_textue(:,:,1);
    green_channel=current_textue(:,:,2);
    blue_channel=current_textue(:,:,3);
faces_in_current_texture=cell2mat(faces_in_frame(i));
    face_coordinate_in_image=faces_coord_in_orig_img(faces_in_current_texture,:);
    x_coord=face_coordinate_in_image(:,1:3);
    y_coord=face_coordinate_in_image(:,4:6);
    for k=1:length(faces_in_current_texture)
        current_face=faces_in_current_texture(k);
        indh=x_coord(k,:);
        indw=y_coord(k,:);
        [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
            height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
            img_indices=sub2ind([size(current_textue,1) size(current_textue,2)],height_inds,width_inds);
            
            faces_colors(current_face,:)=[mean(red_channel(img_indices)),mean(green_channel(img_indices)),mean(blue_channel(img_indices))];
    end
end
figure,plot_CAD(mesh.f, mesh.v, '',faces_colors);
delete(findall(gcf,'Type','light'));
mkdir(['mesh_texturing']);
mkdir(['mesh_texturing/',scene_name]);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number)]);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number),'/before']);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number),'/after']);

tex_path=['mesh_texturing/',scene_name,'/',num2str(region_number),'/before'];
combine_textures_in_one_for_consistent_texture(mesh,textures_images_and_faces,faces_coord_in_orig_img,tex_path,seems_coord);
time_to_finish_whole_function=toc
d=[];
