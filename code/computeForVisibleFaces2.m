function [face_text_at_which_image,vertex_exist,face_text_indices_in_img,all_images,faces_coord_in_orig_img]=computeForVisibleFaces2(mesh)
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

final_average_colors=uint8([average_face_color_trackR(:,1),average_face_color_trackG(:,1),average_face_color_trackB(:,1)]);
figure,plot_CAD(mesh.f, mesh.v, '',final_average_colors)
delete(findall(gcf,'Type','light'));
d=[];
% remove faces with low number of pixels(#pix<max(#)/lmpda)&&(#pix<omega)
% lampda=3, omega=7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% chosing face based on data and consistency term
% lampda=15; omega=15;
% [max_val]=max(size_faces_in_frames,[],2);
% max_val=max_val/lampda;
% flag_lampda=(size_faces_in_frames-max_val)<0;
% flag_omega=(size_faces_in_frames-omega)<0;
% indices_to_be_excluded=flag_lampda&flag_omega;
% size_faces_in_frames(indices_to_be_excluded)=0;
% data_term_faces_in_frames(indices_to_be_excluded)=0;
% consistency_term_faces_in_frames(indices_to_be_excluded)=0;
%
% % weight the consistency colors by the number of pixels which they have
% % been captured from.  and remove the low compatible views with ours (which could have bad projection)
% consistency_term_faces_in_frames_mean=sum(consistency_term_faces_in_frames.*size_faces_in_frames,2)./sum(size_faces_in_frames,2);
% consistency_term_faces_in_frames_mean(isnan(consistency_term_faces_in_frames_mean))=0;
% consistency_term_faces_in_frames_var=abs(consistency_term_faces_in_frames-consistency_term_faces_in_frames_mean);%var=X-Xmean
% consistency_term_faces_in_frames_var(consistency_term_faces_in_frames==0)=0;
% consistency_term_faces_in_frames_var(consistency_term_faces_in_frames_var==0)=inf;
% min_var=min(consistency_term_faces_in_frames_var,[],2);
% consistency_term_faces_in_frames_var(consistency_term_faces_in_frames_var>(min_var*4))=0;% var>min(var)*4=0
% consistency_term_faces_in_frames_var(isinf(consistency_term_faces_in_frames_var))=0;
%
% % remove the inconsistent views from other matrices
% size_faces_in_frames(consistency_term_faces_in_frames_var==0)=0;
% data_term_faces_in_frames(consistency_term_faces_in_frames_var==0)=0;
% [max_val,selected_view]=max(data_term_faces_in_frames,[],2);% here we will select the best view for each face.
% toc
%
% faces_indexes=(1:length(selected_view))';
% selected_view(max_val==0)=[];
% faces_indexes(max_val==0)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% chosing the biggest face
frame_num_of_max_faces=size_faces_in_frames;
frame_num_of_max_faces(:,:)=0;
for index=1:size(region_frames,1)
    [max_val,maxind]=max(size_faces_in_frames,[],2);%find current max value
    size_faces_in_frames(sub2ind(size(size_faces_in_frames),(1:size(size_faces_in_frames,1))',maxind))=0;% remove current max value from original array
    maxind(max_val==0)=0;
    frame_num_of_max_faces(:,index)=maxind;
end
%%%%%%%%%%%%%
% filling the empty faces in lower scale versions from higher scale
% versions
for i=2:size(frame_num_of_max_faces,2)
    frame_num_of_max_faces(frame_num_of_max_faces(:,i)==0,i)=frame_num_of_max_faces(frame_num_of_max_faces(:,i)==0,i-1);
end
%%%%%%%%%%%%%
selected_view=frame_num_of_max_faces(:,1);
faces_indexes=(1:length(selected_view))';
faces_indexes(selected_view==0)=[];
selected_view(selected_view==0)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vertex_exist_replacement=cell(length(faces_indexes),1);
vertex_exist_replacement2=cell(length(faces_indexes),1);

faces_coord_in_orig_img_replacement=cell(length(faces_indexes),1);
face_text_at_which_image_replacement=cell(length(faces_indexes),1);
face_text_indices_in_img_replacement=cell(length(faces_indexes),1);
parfor ui =1:length(faces_indexes)
    curr_f=faces_indexes(ui);
    index=selected_view(ui);
    
    
    %     faces_texture_information(curr_f,1)=index;
    %     faces_texture_information(curr_f,2)=length_required_indexes_for_access_image;
    vertices_indexes_of_current_face=mesh.f(curr_f,:);
    current_face_vertices=[mesh.v(vertices_indexes_of_current_face,:),[1;1;1]];
    
    projection_matrix=cell2mat(all_proj_mat(index));
    point_2d=projection_matrix*current_face_vertices';
    point_2d=point_2d(1:2,:)./point_2d(3,:);
    indw=round(point_2d(1,:));
    indh=round(point_2d(2,:));
    vertices_flag=indw>width;% to know which vertices out of frame.
    %     back_indw=indw;
    %     indw(indw>width)=width;% this step should be done after  get_face_indexes as it waste some of face indexes
    vertices_flag=vertices_flag|indh>height;
    vertices_flag=vertices_flag|indw<1;
    vertices_flag=vertices_flag|indh<1;
    %     back_indh=indh;
    %     indh(indh>height)=height;% this step should be done after  get_face_indexes as it waste some of face indexes
    min_indw=min(indw);if(min_indw<1);indw=indw-(min_indw)+1;end
    min_indh=min(indh);if(min_indh<1);indh=indh-(min_indh)+1;end
    %        indw(indw<1)=1;% this step should be done after  get_face_indexes
    %     indh(indh<1)=1;% this step should be done after  get_face_indexes
    
    third_dimen=index*ones(1,length(indw));
    vertices_indices=sub2ind([height width index],indh(~vertices_flag),indw(~vertices_flag),third_dimen(~vertices_flag));
    vertex_exist_replacement(ui,1)={vertices_indices};
    vertex_exist_replacement2(ui,1)={vertices_indexes_of_current_face(~vertices_flag)};
    %     vertex_exist(vertices_indices)=vertices_indexes_of_current_face(~vertices_flag);% store vertices numbers in its corresponding position in frame& in the same time exclude out of frame vertices;
    [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
    height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
    if(min_indw<1);width_inds=width_inds+(min_indw)-1;end
    if(min_indh<1);height_inds=height_inds+(min_indh)-1;end
    
    
    width_inds(width_inds>width)=width;% this step moved to here
    height_inds(height_inds>height)=height;% this step moved to here
    width_inds(width_inds<1)=1;% this step moved to here
    height_inds(height_inds<1)=1;% this step moved to here
    
    img_indices=sub2ind([height width],height_inds,width_inds);
    
    faces_coord_in_orig_img_replacement(ui)={[indh,indw,min_indh,min_indw]};
    face_text_at_which_image_replacement(ui)={[curr_f,index]};
    face_text_indices_in_img_replacement(ui)={img_indices(:)};
    %     faces_coord_in_orig_img(curr_f,:)=[indh,indw];
    %     face_text_at_which_image(curr_f)=index;
    %     face_text_indices_in_img(curr_f)={img_indices(:)};
    
    
end

for ui =1:length(faces_indexes)
    vertices_indices=cell2mat(vertex_exist_replacement(ui,1));
    vertices_indexes_of_current_face=cell2mat(vertex_exist_replacement2(ui,1));
    vertex_exist(vertices_indices)=vertices_indexes_of_current_face;% store vertices numbers in its corresponding position in frame& in the same time exclude out of frame vertices;
    curr_f_and_index=cell2mat(face_text_at_which_image_replacement(ui));%={[curr_f,index]};
    curr_f=curr_f_and_index(1);index=curr_f_and_index(2);
    faces_coord_in_orig_img(curr_f,:)=cell2mat(faces_coord_in_orig_img_replacement(ui));
    face_text_at_which_image(curr_f)=index;
    face_text_indices_in_img(curr_f)=face_text_indices_in_img_replacement(ui);
end





num_faces_in_frames=[];
time_to_get_faces_colors=toc
d=[];