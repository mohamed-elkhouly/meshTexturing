function  [num_faces_in_frames, groups,faces_textures,faces_vertices_indices_in_textures]=get_faces_colors_for_texturing_mesh_waetcher(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number)
% if(using_different_mesh)
%     region_frames=region_frames(:);
% end
% 
% frames_groups_tracker=zeros(max(region_frames(:,1))+1,length(region_faces)+1);
% 
% groups(length(region_faces)).frames_index=[];
% groups(length(region_faces)).should_be_estimated=[];
% 
% faces_textures=cell(size(mesh.f,1),1);
% faces_vertices_indices_in_textures=cell(size(mesh.f,1),7);
% face_text_at_which_image=zeros(size(mesh.f,1),1);
% stored_hitted_faces=cell(size(region_frames,1),1);
% faces_vertices_indices_in_textures(:,4)={0};
% 
% face_text_indices_in_img=cell(size(mesh.f,1),1);
% faces_texture_information=zeros(size(mesh.f,1),2);% we store in it the frame of texture of each face, and the length of pixels in texture.
% tic
% width=1280;
% height=1024;
% texture_exist=uint8(zeros(height,width,size(region_frames,1)));
% vertex_exist=(zeros(height,width,size(region_frames,1)));
% faces_coord_in_orig_img=zeros(size(mesh.f,1),6);
% all_images=uint8(zeros(size(region_frames,1),height,width,3));
% intrinsics=mesh.intrinsics;
% for index=1:size(region_frames,1)
%     %     if(index==15)
%     %         d=[]
%     %     end
%     current_texture_frame=texture_exist(:,:,index);
%     current_vertices_frame=vertex_exist(:,:,index);
%     i=region_frames(index);
%     
%     [height,width,L_channel,a_channel,b_channel,all_images]=prepare_our_image(i,folder_path,index,all_images) ;
%     
%     [hitted_faces_2,faces_places_in_image,back_idxx,index_f,index_in_hitted_faces_1,index_in_all_used_group_faces_1]=get_hitted_faces_in_mesh(i,using_different_mesh,folder_path,mesh,start_of_faces_indexing,end_of_faces_indexing,all_used_groups_faces);
%     
%     if(isempty(hitted_faces_2))
%         continue;
%     end
%     
%     ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces_2, :), mesh.normals(hitted_faces_2, :));
%     if(sum(ind22)>1)
%         d=[];
%     end
%     hitted_faces_2(ind22)=[];
%     index_in_hitted_faces_1(ind22)=[];
%     index_in_all_used_group_faces_1(ind22)=[];
%     if(isempty(index_in_all_used_group_faces_1))
%         continue;
%     end
%     all_indexes_in_idxx=back_idxx(:,2);
%     % tic
%     values_from_face_pixels_L=zeros(size(hitted_faces_2));values_from_face_pixels_a=zeros(size(hitted_faces_2));values_from_face_pixels_b=zeros(size(hitted_faces_2));
%     stored_hitted_faces(index)={hitted_faces_2};
%     for ui=1:length(hitted_faces_2)
%         %         if ui==399
%         %             d=[];
%         %         end
%         m=index_in_hitted_faces_1(ui);
%         if ui==length(hitted_faces_2)
%             required_indexes_for_access_image=index_f(faces_places_in_image(m):end);
%         else
%             required_indexes_for_access_image=index_f(faces_places_in_image(m):faces_places_in_image(m+1)-1);
%         end
%         
%         % store the frame number in the first column and the texture indexes in the
%         % second column.
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         
%         if(length(all_indexes_in_idxx(required_indexes_for_access_image))>faces_texture_information(hitted_faces_2(ui),2))
%             %            if(hitted_faces_2(ui)==139155)
%             %                d=[];
%             %            end
%             faces_texture_information(hitted_faces_2(ui),1)=index;
%             faces_texture_information(hitted_faces_2(ui),2)=length(all_indexes_in_idxx(required_indexes_for_access_image));
%             vertices_indexes_of_current_face=mesh.f(hitted_faces_2(ui),:);
%             current_face_vertices=[mesh.v(vertices_indexes_of_current_face,:),[1;1;1]];
%             
%             pose_matrix=mesh.pose(i+1).pose_matrix;
%             rotation_matrix=pose_matrix(1:3,1:3)';
%             camera_position_in_world=pose_matrix(1:3,4);
%             translation=-1*rotation_matrix*camera_position_in_world;
%             RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
%             point_2d=projection_matrix*current_face_vertices';
%             point_2d=point_2d(1:2,:)./point_2d(3,:);
%             indw=round(point_2d(1,:));
%             indh=round(point_2d(2,:));
%             indw(indw>width)=width;
%             indh(indh>height)=height;
%             indw(indw<1)=1;
%             indh(indh<1)=1;
%             vertices_indices=sub2ind([height width],indh,indw);
%             current_vertices_frame(vertices_indices)=vertices_indexes_of_current_face;
%             [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
%             height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
%             img_indices=sub2ind([height width],height_inds,width_inds);
%             face_text_indices_in_img(hitted_faces_2(ui))={img_indices};
%             current_texture_frame(img_indices)=current_texture_frame(img_indices)+1;
%             %             faces_textures(hitted_faces_2(ui))={lab_img(min(indh):max(indh),min(indw):max(indw),:)};
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),1)={[(indh-min(indh)+1);(indw-min(indw)+1)]};
%             %             [x_ind,~]=meshgrid(min(indh):max(indh),min(indw):max(indw));
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),2)={size(x_ind,2)};%height
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),3)={size(x_ind,1)};%width
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),4)={length(x_ind(:))};
%             % adding margin
%             %             margin=5;
%             %             [~,mnh]=min(indh);[~,mxh]=max(indh);indh(mnh)=indh(mnh)-margin;indh(mxh)=indh(mxh)+margin;
%             %             [~,mnw]=min(indw);[~,mxw]=max(indw);indw(mnw)=indw(mnw)-margin;indw(mxw)=indw(mxw)+margin;
%             %             indw(indw>width)=width;
%             %             indh(indh>height)=height;
%             %             mnh=min(indh);
%             %             mnw=min(indw);
%             %             if(mnh<=0);margin_h=margin-(abs(mnh)+1);else;margin_h=margin;end
%             %                 if(mnw<=0);margin_w=margin-(abs(mnw)+1);else;margin_w=margin;end
%             %
%             %                 indw(indw<1)=1;
%             %             indh(indh<1)=1;
%             %             faces_textures(hitted_faces_2(ui))={lab_img(min(indh):max(indh),min(indw):max(indw),:)};
%             %
%             %             [x_ind,~]=meshgrid(min(indh):max(indh),min(indw):max(indw));
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),5)={[margin_h,margin_w ]};
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),6)={size(x_ind,2)};%height
%             %             faces_vertices_indices_in_textures(hitted_faces_2(ui),7)={size(x_ind,1)};%width
%             if ~isempty(img_indices)
%                 faces_coord_in_orig_img(hitted_faces_2(ui),:)=[indh,indw];
%                 if (face_text_at_which_image(hitted_faces_2(ui))==0)
%                     face_text_at_which_image(hitted_faces_2(ui))=index;
%                 else
%                     other_texture_frame=texture_exist(:,:,face_text_at_which_image(hitted_faces_2(ui)));
%                     curr_face_indices=cell2mat(face_text_indices_in_img(hitted_faces_2(ui)));
%                     other_texture_frame(curr_face_indices)=other_texture_frame(curr_face_indices)-1;
%                     texture_exist(:,:,face_text_at_which_image(hitted_faces_2(ui)))=other_texture_frame;
%                     face_text_at_which_image(hitted_faces_2(ui))=index;
%                 end
%             else
%                 d=[];
%             end
%             
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         values_from_face_pixels_L(ui)=trimmean(L_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
%         values_from_face_pixels_a(ui)=trimmean(a_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
%         values_from_face_pixels_b(ui)=trimmean(b_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
%     end
%     %     toc
%     
%     
%     % here I have to search for the groups of these faces and set the group
%     % index for each set.
%     for group_index=1:length(region_faces)
%         current_group_faces=cell2mat(region_faces(group_index));
%         [~,intersect_inds]=intersect(hitted_faces_2,current_group_faces);
%         if(~isempty(intersect_inds))
%             groups(group_index).frame(i+1).faces=hitted_faces_2(intersect_inds);
%             groups(group_index).frame(i+1).values=values_from_face_pixels_L(intersect_inds);
%             groups(group_index).frame(i+1).values_a=values_from_face_pixels_a(intersect_inds);
%             groups(group_index).frame(i+1).values_b=values_from_face_pixels_b(intersect_inds);
%             groups(group_index).frames_index=[groups(group_index).frames_index;(i+1)];
%             %             num_faces_in_frames=[num_faces_in_frames;[(i+1), group_index, length(intersect_inds)]];
%             frames_groups_tracker(i+1,frames_groups_tracker(i+1,1)+2)=group_index;
%             frames_groups_tracker(i+1,1)=frames_groups_tracker(i+1,1)+1;
%         end
%     end
%     texture_exist(:,:,index)=current_texture_frame;
%     vertex_exist(:,:,index)=current_vertices_frame;
% end
% % I commented its line as no need for it now
% num_faces_in_frames=[];
% time_to_get_faces_colors=toc
% % stored_hitted_faces
% save('get_faces_colors_21.mat')










load('get_faces_colors_21.mat');
se50 = strel('disk',50);
se1 = strel('disk',3);
textures_images_and_faces=cell(size(region_frames,1),4);
vertices_on_border_info=cell(size(region_frames,1),3);
G_vertices=cell(size(region_frames,1),3);
border_vertices_coord=cell(size(region_frames,1),1);
to_be_removed=[];
for_sorting_purpose=zeros(size(region_frames,1),1);
% load('up_to_this_point.mat');
seems_coord=cell(size(region_frames,1),1);
for index=1:size(region_frames,1)
    
    faces_in_current_frame=find(face_text_at_which_image==index);
    vertices_frame=vertex_exist(:,:,index);
    BW=texture_exist(:,:,index)>0;
    BW_back=BW;
    BW=padarray(BW,[1 1 ],0,'both');
    border_line_of_texture=BW-imerode(imclose(BW,se1),se1);
    border_line_of_texture(:,[1,end])=[];
    border_line_of_texture([1,end],:)=[];
   
    current_frame=reshape(all_images(index,:,:,:),height,width,3);
    [vertices_on_border_new, vertices_colors_new,groups_of_vertices,vertices_coordinates_on_border]=get_border_contour_vertices_and_colors_v2(border_line_of_texture,current_frame,vertices_frame);
%     current_red=current_frame(:,:,1);current_green=current_frame(:,:,2);current_blue=current_frame(:,:,3);
%     current_red=current_red(border_line_of_texture>0);current_green=current_green(border_line_of_texture>0);current_blue=current_blue(border_line_of_texture>0);
%     vertices_on_border=vertices_frame(border_line_of_texture>0);
    

%     current_red(vertices_on_border==0)=[];current_green(vertices_on_border==0)=[];current_blue(vertices_on_border==0)=[];
%     vr(vertices_on_border==0)=[];vc(vertices_on_border==0)=[];
%     vertices_on_border(vertices_on_border==0)=[];
%     vertices_colors=[current_red,current_green,current_blue];
   
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
    vertices_on_border_info(index,3)={groups_of_vertices};
    faces_coord_in_orig_img(faces_in_current_frame,1:3)=faces_coord_in_orig_img(faces_in_current_frame,1:3)-min(r)+1;
    faces_coord_in_orig_img(faces_in_current_frame,4:6)=faces_coord_in_orig_img(faces_in_current_frame,4:6)-min(c)+1;
    a=all_images(index,min(r):max(r),min(c):max(c),:);
    a=reshape(a,[size(a,2) size(a,3) size(a,4)]);
    textures_images_and_faces(index,1)={a};
    textures_images_and_faces(index,2)={faces_in_current_frame};
    textures_images_and_faces(index,3)={max(r)-min(r)+1};
    textures_images_and_faces(index,4)={max(c)-min(c)+1};
    
    i=region_frames(index);
    BW_diff=logical(BW-BW_back);
    hitted_faces_2=cell2mat(stored_hitted_faces(index));
    
    
    pose_matrix=mesh.pose(i+1).pose_matrix;
    rotation_matrix=pose_matrix(1:3,1:3)';
    camera_position_in_world=pose_matrix(1:3,4);
    translation=-1*rotation_matrix*camera_position_in_world;
    RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
    %             hitted_faces_coor=mesh.f(hitted_faces_2,:);
    temp_faces_coord_in_orig_img=zeros(length(hitted_faces_2),7);
    temp_faces_coord_in_orig_img(:,7)=hitted_faces_2;
    existed_indices=find(BW_diff);
    for ui=1:length(hitted_faces_2)
        current_face_vertices=[mesh.v(mesh.f(hitted_faces_2(ui),:),:),[1;1;1]];
        point_2d=projection_matrix*current_face_vertices';
        point_2d=point_2d(1:2,:)./point_2d(3,:);
        indw=round(point_2d(1,:));
        indh=round(point_2d(2,:));
        indw(indw>width)=width;
        indh(indh>height)=height;
        indw(indw<1)=1;
        indh(indh<1)=1;
        %         [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
        %         height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
        img_indices=sub2ind([height width],indh,indw);
        [vals]=intersect(img_indices,existed_indices);
        if(length(vals)==3)
            [indh,indw]= ind2sub([height width],vals);
            indh=indh-min(r)+1;
            indw=indw-min(c)+1;
            %             face_text_indices_in_img(hitted_faces_2(ui))={img_indices};
            temp_faces_coord_in_orig_img(ui,1:6)=[indh',indw'];
        end
    end
    temp_faces_coord_in_orig_img(temp_faces_coord_in_orig_img(:,6)==0,:)=[];
    seems_coord(index)={temp_faces_coord_in_orig_img};
end
textures_images_and_faces(to_be_removed,:)=[];
seems_coord(to_be_removed)=[];
G_vertices(to_be_removed,:)=[];
vertices_on_border_info(to_be_removed,:)=[];
for_sorting_purpose(to_be_removed)=[];
border_vertices_coord(to_be_removed)=[];
%% start correcting texture calculations
[~,I]=sort(for_sorting_purpose,'descend');
textures_images_and_faces=textures_images_and_faces(I,:);
seems_coord=seems_coord(I);
G_vertices=G_vertices(I,:);
vertices_on_border_info=vertices_on_border_info(I,:);
border_vertices_coord=border_vertices_coord(I);
overlapping_mat=get_overlapping_between_border_vertices(vertices_on_border_info);
save('after_sorting.mat');
load('after_sorting.mat');
textures_images_and_faces=create_A_omega_F_matrices(vertices_on_border_info,mesh,border_vertices_coord,G_vertices,textures_images_and_faces);
no_overlapping=find(overlapping_mat==0); overlapping_mat(no_overlapping)=[]; no_overlapping(1)=[];
to_be_modified_textures=1:size(vertices_on_border_info,1);
to_be_modified_textures(no_overlapping)=[];
to_be_modified_textures(1)=[];
[sorted_overlapping_mat,sorted_to_be_modified_textures]=sort_based_on_dependency(overlapping_mat,to_be_modified_textures);
first_texture=textures_images_and_faces(1,:);
first_texture_vertices=cell2mat(vertices_on_border_info(1,1));
first_texture_colores=cell2mat(vertices_on_border_info(1,2));
% sort_other_textures_based_on_overlapping_with_current
for tex_ind=1:length(sorted_to_be_modified_textures)
    cur_ind=sorted_to_be_modified_textures(tex_ind);
    current_vertices=cell2mat(vertices_on_border_info(cur_ind,1));
    current_colores=cell2mat(vertices_on_border_info(cur_ind,2));
    current_coordinates=cell2mat(border_vertices_coord(cur_ind));
    required_coordinates=cell2mat(G_vertices(cur_ind));
    [common_vertices,indices_in_current,indices_in_first]=intersect(current_vertices,first_texture_vertices);
    g_diff=first_texture_colores(indices_in_first,:)-current_colores(indices_in_current,:);
%     current_coordinates=current_coordinates(indices_in_current,:);
    X=current_coordinates(indices_in_current,1);
    Y=current_coordinates(indices_in_current,2);
    V=double(g_diff(:,1));
    Xq=required_coordinates(:,1);
    Yq=required_coordinates(:,2);
    F = scatteredInterpolant(X,Y,V,'natural');
    Vq = F(Xq,Yq);
%     Vq = interp2(X,Y,V,Xq,Yq);
%     for coord=1:length(indices_in_current)
%     red_mat(current_coordinates(coord,1),current_coordinates(coord,2))=g_diff(coord);
%     end
    
end 



 % [sorted_array,original_faces_indexes]=sortrows(faces_vertices_indices_in_textures,4,'descend');

% sorted_faces_textures=faces_textures(original_faces_indexes);
% f_o_height_texture_coord_in_img=zeros(size(mesh.f,1),3);
% f_o_width_texture_coord_in_img=zeros(size(mesh.f,1),3);
% face_have_texture=false(size(mesh.f,1),1);
mkdir(['mesh_texturing']);
mkdir(['mesh_texturing/',scene_name]);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number)]);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number),'/before']);
mkdir(['mesh_texturing/',scene_name,'/',num2str(region_number),'/after']);


tex_path=['mesh_texturing/',scene_name,'/',num2str(region_number),'/before'];
% combine_textures_in_one(mesh,faces_textures,faces_vertices_indices_in_textures,tex_path);
combine_textures_in_one_for_consistent_texture(mesh,textures_images_and_faces,faces_coord_in_orig_img,tex_path,seems_coord);
% [height_texture_coord_in_img,width_texture_coord_in_img,tex_im_height,tex_im_width]=combine_textures_in_one(mesh,sorted_faces_textures,sorted_array,tex_path,original_faces_indexes);
% f_o_height_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=1-height_texture_coord_in_img/tex_im_height;
% f_o_width_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=width_texture_coord_in_img/tex_im_width;
% face_have_texture(original_faces_indexes(1:size(height_texture_coord_in_img,1)))=1;
%
% write_into_obj_file(mesh,f_o_height_texture_coord_in_img,f_o_width_texture_coord_in_img,face_have_texture,tex_path)

% TODO: save to mtl file.
time_to_finish_whole_function=toc
d=[];
