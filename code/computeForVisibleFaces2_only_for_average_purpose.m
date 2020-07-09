function [final_average_colors]=computeForVisibleFaces2_only_for_average_purpose(mesh)
tic
% scene_name=mesh.scene_name;
region_faces={find(mesh.all_visible_faces)};%
average_face_color_trackR=zeros(size(mesh.f,1),2);% first column for sum, second column for count
average_face_color_trackG=zeros(size(mesh.f,1),2);% first column for sum, second column for count
average_face_color_trackB=zeros(size(mesh.f,1),2);% first column for sum, second column for count
region_frames=mesh.frame_number;%
face_text_at_which_image=zeros(size(mesh.f,1),1);%
stored_hitted_faces=cell(size(region_frames,1),1);%
face_text_indices_in_img=cell(size(mesh.f,1),1);%
faces_texture_information=zeros(size(mesh.f,1),2);% we store in it the frame of texture of each face, and the length of pixels in texture.
width=mesh.frame_width;%
height=mesh.frame_height;%
vertex_exist=(zeros(height,width,size(region_frames,1)));%
faces_coord_in_orig_img=zeros(size(mesh.f,1),8);%
all_images=uint8(zeros(size(region_frames,1),height,width,3));%
intrinsics=mesh.intrinsics;%
size_faces_in_frames=zeros(size(mesh.f,1),size(region_frames,1));
data_term_faces_in_frames=zeros(size(mesh.f,1),size(region_frames,1));
consistency_term_faces_in_frames=zeros(size(mesh.f,1),size(region_frames,1));
all_proj_mat=cell(size(region_frames,1),1);
% size_faces_in_frames_replacement=cell()
tic;
for index=1:size(region_frames,1)
    
    %     current_vertices_frame=vertex_exist(:,:,index);
    frame_number=region_frames(index);
    [~,image_gradients,image]=prepare_our_image(frame_number,index,all_images,mesh.data_path) ;
    all_images(index,:,:,:)=image;
    RR=image(:,:,1);
    GG=image(:,:,2);
    BB=image(:,:,3);
    [hitted_faces_2,faces_places_in_image,back_idxx,index_f,index_in_hitted_faces_1,index_in_all_used_group_faces_1]=get_hitted_faces_in_mesh(index,mesh);
    
    for  avg_c_ind=1:size(hitted_faces_2,1)
        curr_face_ind=hitted_faces_2(avg_c_ind);
        curr_face_pos_in_img=back_idxx(back_idxx(:,1)==curr_face_ind,2);
        average_face_color_trackR(curr_face_ind,1)=average_face_color_trackR(curr_face_ind,1)+sum(RR(curr_face_pos_in_img));
        average_face_color_trackG(curr_face_ind,1)=average_face_color_trackG(curr_face_ind,1)+sum(GG(curr_face_pos_in_img));
        average_face_color_trackB(curr_face_ind,1)=average_face_color_trackB(curr_face_ind,1)+sum(BB(curr_face_pos_in_img));
        
        length_of_poss=length(curr_face_pos_in_img);
        average_face_color_trackR(curr_face_ind,2)=average_face_color_trackR(curr_face_ind,2)+length_of_poss;
        average_face_color_trackG(curr_face_ind,2)=average_face_color_trackG(curr_face_ind,2)+length_of_poss;
        average_face_color_trackB(curr_face_ind,2)=average_face_color_trackB(curr_face_ind,2)+length_of_poss;
        
    end
    
    
    if(isempty(hitted_faces_2))
        continue;
    end
    
    ind22 = ~isFacing(mesh.campos(index, :), mesh.camdir(index, :), mesh.centroids(hitted_faces_2, :), mesh.normals(hitted_faces_2, :));
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
    pose_matrix=mesh.pose(index).pose_matrix;
    rotation_matrix=pose_matrix(1:3,1:3)';
    camera_position_in_world=pose_matrix(1:3,4);
    translation=-1*rotation_matrix*camera_position_in_world;
    RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
    all_proj_mat(index)={projection_matrix};
    faces_places_in_image_2=faces_places_in_image;
    faces_places_in_image_2(index_in_hitted_faces_1(length(hitted_faces_2))+1)=length(index_f)+1;
    for ui=1:length(hitted_faces_2)
        m=index_in_hitted_faces_1(ui);
        face_indexes_in_the_image=all_indexes_in_idxx(index_f(faces_places_in_image_2(m):faces_places_in_image_2(m+1)-1));
        length_required_indexes_for_access_image=length(face_indexes_in_the_image);
        data_term_faces_in_frames(hitted_faces_2(ui),index)=sum(image_gradients(face_indexes_in_the_image));
        %         consistency_term_faces_in_frames(hitted_faces_2(ui),index)=trimmean(image(face_indexes_in_the_image),30);
        consistency_term_faces_in_frames(hitted_faces_2(ui),index)=mean(image(face_indexes_in_the_image));
        size_faces_in_frames(hitted_faces_2(ui),index)=length_required_indexes_for_access_image;
    end
    %     vertex_exist(:,:,index)=current_vertices_frame;
end
average_face_color_trackR(average_face_color_trackR(:,2)~=0,1)=average_face_color_trackR(average_face_color_trackR(:,2)~=0,1)./average_face_color_trackR(average_face_color_trackR(:,2)~=0,2);
average_face_color_trackG(average_face_color_trackG(:,2)~=0,1)=average_face_color_trackG(average_face_color_trackG(:,2)~=0,1)./average_face_color_trackG(average_face_color_trackG(:,2)~=0,2);
average_face_color_trackB(average_face_color_trackB(:,2)~=0,1)=average_face_color_trackB(average_face_color_trackB(:,2)~=0,1)./average_face_color_trackB(average_face_color_trackB(:,2)~=0,2);

final_average_colors=([average_face_color_trackR(:,1),average_face_color_trackG(:,1),average_face_color_trackB(:,1)]);
figure,plot_CAD(mesh.f, mesh.v, '',uint8(final_average_colors))
delete(findall(gcf,'Type','light'));
save([mesh.data_path ,'/',mesh.scene_name,'_average_colors_per_face.mat'],'final_average_colors');
d=[];