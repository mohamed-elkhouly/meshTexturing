function  [num_faces_in_frames, groups,faces_textures,faces_vertices_indices_in_textures]=get_faces_colors_for_each_group_from_each_frame_separately_4(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh,region_number)
if(using_different_mesh)
    region_frames=region_frames(:);
end
% visible_pixels_for_faces=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% visible_pixels_for_faces_a=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% visible_pixels_for_faces_b=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% distance_visible_pixels_for_faces_from_camera=zeros(size(all_used_groups_faces,1),150);
% groups_struct=[];
frames_groups_tracker=zeros(max(region_frames(:,1))+1,length(region_faces)+1);
for group_index=1:length(region_faces)
    groups(group_index).frames_index=[];
    groups(group_index).should_be_estimated=[];
end
% num_faces_in_frames=[];
faces_textures=cell(size(mesh.f,1),1);
faces_vertices_indices_in_textures=cell(size(mesh.f,1),7);
face_text_at_which_image=zeros(size(mesh.f,1),1);
stored_hitted_faces=cell(size(region_frames,1),1);
faces_vertices_indices_in_textures(:,4)={0};
% faces_texture_color_index=cell(size(mesh.f,1),1);

% faces_texture_color_l=cell(size(mesh.f,1),1);
% faces_texture_color_a=cell(size(mesh.f,1),1);
% faces_texture_color_b=cell(size(mesh.f,1),1);
face_text_indices_in_img=cell(size(mesh.f,1),1);
faces_texture_information=zeros(size(mesh.f,1),2);% we store in it the frame of texture of each face, and the length of pixels in texture.
tic
width=1280;
height=1024;
texture_exist=uint8(zeros(height,width,size(region_frames,1)));
faces_coord_in_orig_img=zeros(size(mesh.f,1),6);
all_images=uint8(zeros(size(region_frames,1),height,width,3));
intrinsics=mesh.intrinsics;
zero_border_val=50;
for index=1:size(region_frames,1)
    if(index==15)
        d=[]
    end
    current_texture_frame=texture_exist(:,:,index);
    i=region_frames(index);
    image_name=sprintf('frame-%06d.color.jpg',i);
    image_name2=sprintf('frame-%06d.color.png',i);
    image_path=[folder_path,'/frame/',image_name];
    image_path2=[folder_path,'/frame/',image_name2];
    try
        image=imread(image_path);
        try
        image(2,342:916,:)=image(3,342:916,:);image(1,221:1038,:)=image(2,221:1038,:); % fix zeros_which is in top of each image in matterport.
        image(1023,419:836,:)=image(1022,419:836,:);image(1024,267:992,:)=image(1023,267:992,:); % fix zeros_which is in bottom of each image in matterport.
        image(335:670,1,:)=image(335:670,2,:); % fix zeros_which is in left of each image in matterport.
        catch
        end
        
    catch
        image=imread(image_path2);
    end
    all_images(index,:,:,:)=image;
    [height,width,~]=size(image);
    M_max=max(image,[],3);
    M1=M_max;
    %     lab_img=rgb2hsv(image);
    %     lab_img=rgb2lab(image);
    lab_img=image;
    L_channel=lab_img(:,:,1);
    a_channel=lab_img(:,:,2);
    b_channel=lab_img(:,:,3);
    %
    %     L_channel=M1;
    %     a_channel=M1;
    %     b_channel=M1;

    if(~using_different_mesh)
        file_path=[folder_path,'/frames_faces_mapping/','frame-',sprintf('%06d',i),'.color.png'];
        [faces_image,~,trans]=imread(file_path);
        r=faces_image(:,:,1);
        g=faces_image(:,:,2);
        b=faces_image(:,:,3);
%         r=zeroing_borders(r,zero_border_val);g=zeroing_borders(g,zero_border_val);b=zeroing_borders(b,zero_border_val);trans=zeroing_borders(trans,zero_border_val);
        A=double([trans(:),r(:),g(:),b(:)]);
        faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
        idxx=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
    else
        idxx=mesh.frame_face_mapping(i+1,:,:);
        idxx=reshape(idxx,height,width);
%         idxx=zeroing_borders(idxx);
        idxx=idxx(:);
    end



    idxx=idxx-start_of_faces_indexing;
    back_idxx=[idxx,(1:length(idxx))'];
    back_back_idxx=[idxx,(1:length(idxx))'];
    back_idxx(idxx>end_of_faces_indexing,:)=[];
    idxx(idxx>end_of_faces_indexing)=[];

    back_idxx(idxx<=0,:)=[];
    idxx(idxx<=0)=[];
    [hitted_faces,~,indexes_of_faces_in_originals]=unique(idxx);
    [sorted_f,index_f]=sort(indexes_of_faces_in_originals);

    [~,faces_places_in_image,~]=unique(sorted_f);
    faces_places_in_image(length(hitted_faces)+1)=length(sorted_f)+1;

    [~,index_in_all_used_group_faces_1,index_in_hitted_faces_1]=intersect(all_used_groups_faces(:,1),hitted_faces);
    if(isempty(index_in_all_used_group_faces_1))
        continue;
    end
    groups_faces=all_used_groups_faces(index_in_all_used_group_faces_1,:);


    hitted_faces_2=groups_faces(:,1);
    ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces_2, :), mesh.normals(hitted_faces_2, :));
    if(sum(ind22)>1)
        d=[];
    end
    hitted_faces_2(ind22)=[];
    index_in_hitted_faces_1(ind22)=[];
    %     groups_faces(ind22,:)=[];
    index_in_all_used_group_faces_1(ind22)=[];
    %     visible_faces_centroids=mesh.centroids(hitted_faces_2,:);
    %     points_on_frame=int32(project_points_on_frame(mesh.pose(i+1).pose_matrix,mesh.intrinsics,visible_faces_centroids));
    %     distance_from_cam=vecnorm(   (visible_faces_centroids-mesh.campos(i+1))');
    if(isempty(index_in_all_used_group_faces_1))
        continue;
    end
    %     indexes_for_visible_pixels_for_faces=sub2ind(size(visible_pixels_for_faces),index_in_all_used_group_faces_1,visible_pixels_for_faces(index_in_all_used_group_faces_1,1)+2);

    %     distance_visible_pixels_for_faces_from_camera(indexes_for_visible_pixels_for_faces)=distance_from_cam;

    all_indexes_in_idxx=back_idxx(:,2);
    % tic
    values_from_face_pixels_L=zeros(size(hitted_faces_2));
    values_from_face_pixels_a=zeros(size(hitted_faces_2));
    values_from_face_pixels_b=zeros(size(hitted_faces_2));
    stored_hitted_faces(index)={hitted_faces_2};
    for ui=1:length(hitted_faces_2)
%         if ui==399
%             d=[];
%         end
        m=index_in_hitted_faces_1(ui);
        if ui==length(hitted_faces_2)
            required_indexes_for_access_image=index_f(faces_places_in_image(m):end);
        else
            required_indexes_for_access_image=index_f(faces_places_in_image(m):faces_places_in_image(m+1)-1);
        end
        %         [indh,indw]=ind2sub([height,width],all_indexes_in_idxx(required_indexes_for_access_image));
        % store the frame number in the first column and the texture indexes in the
        % second column.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        if(length(all_indexes_in_idxx(required_indexes_for_access_image))>faces_texture_information(hitted_faces_2(ui),2))
%            if(hitted_faces_2(ui)==139155)
%                d=[];
%            end
            faces_texture_information(hitted_faces_2(ui),1)=index;
            faces_texture_information(hitted_faces_2(ui),2)=length(all_indexes_in_idxx(required_indexes_for_access_image));

            current_face_vertices=[mesh.v(mesh.f(hitted_faces_2(ui),:),:),[1;1;1]];

            pose_matrix=mesh.pose(i+1).pose_matrix;
            rotation_matrix=pose_matrix(1:3,1:3)';
            camera_position_in_world=pose_matrix(1:3,4);
            translation=-1*rotation_matrix*camera_position_in_world;
            RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
            point_2d=projection_matrix*current_face_vertices';
            point_2d=point_2d(1:2,:)./point_2d(3,:);
            indw=round(point_2d(1,:));
            indh=round(point_2d(2,:));
            indw(indw>width)=width;
            indh(indh>height)=height;
            indw(indw<1)=1;
            indh(indh<1)=1;
            [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
            height_inds=height_inds+min(indh)-1;width_inds=width_inds+min(indw)-1;
            img_indices=sub2ind([height width],height_inds,width_inds);
            face_text_indices_in_img(hitted_faces_2(ui))={img_indices};
            current_texture_frame(img_indices)=current_texture_frame(img_indices)+1;
%             faces_textures(hitted_faces_2(ui))={lab_img(min(indh):max(indh),min(indw):max(indw),:)};

%             faces_vertices_indices_in_textures(hitted_faces_2(ui),1)={[(indh-min(indh)+1);(indw-min(indw)+1)]};
%             [x_ind,~]=meshgrid(min(indh):max(indh),min(indw):max(indw));
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),2)={size(x_ind,2)};%height
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),3)={size(x_ind,1)};%width
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),4)={length(x_ind(:))};
            % adding margin
%             margin=5;
%             [~,mnh]=min(indh);[~,mxh]=max(indh);indh(mnh)=indh(mnh)-margin;indh(mxh)=indh(mxh)+margin;
%             [~,mnw]=min(indw);[~,mxw]=max(indw);indw(mnw)=indw(mnw)-margin;indw(mxw)=indw(mxw)+margin;
%             indw(indw>width)=width;
%             indh(indh>height)=height;
%             mnh=min(indh);
%             mnw=min(indw);
%             if(mnh<=0);margin_h=margin-(abs(mnh)+1);else;margin_h=margin;end
%                 if(mnw<=0);margin_w=margin-(abs(mnw)+1);else;margin_w=margin;end
%
%                 indw(indw<1)=1;
%             indh(indh<1)=1;
%             faces_textures(hitted_faces_2(ui))={lab_img(min(indh):max(indh),min(indw):max(indw),:)};
%
%             [x_ind,~]=meshgrid(min(indh):max(indh),min(indw):max(indw));
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),5)={[margin_h,margin_w ]};
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),6)={size(x_ind,2)};%height
%             faces_vertices_indices_in_textures(hitted_faces_2(ui),7)={size(x_ind,1)};%width
            if ~isempty(img_indices)
                faces_coord_in_orig_img(hitted_faces_2(ui),:)=[indh,indw];
             if (face_text_at_which_image(hitted_faces_2(ui))==0)
                face_text_at_which_image(hitted_faces_2(ui))=index;
            else
                other_texture_frame=texture_exist(:,:,face_text_at_which_image(hitted_faces_2(ui)));
                curr_face_indices=cell2mat(face_text_indices_in_img(hitted_faces_2(ui)));
                other_texture_frame(curr_face_indices)=other_texture_frame(curr_face_indices)-1;
                texture_exist(:,:,face_text_at_which_image(hitted_faces_2(ui)))=other_texture_frame;
                face_text_at_which_image(hitted_faces_2(ui))=index;
             end
            else
                d=[];
            end

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        values_from_face_pixels_L(ui)=trimmean(L_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
        values_from_face_pixels_a(ui)=trimmean(a_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
        values_from_face_pixels_b(ui)=trimmean(b_channel(all_indexes_in_idxx(required_indexes_for_access_image)),30);
    end
    %     toc
    %     visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=values_from_face_pixels_L;
    %     visible_pixels_for_faces_a(indexes_for_visible_pixels_for_faces)=values_from_face_pixels_a;
    %     visible_pixels_for_faces_b(indexes_for_visible_pixels_for_faces)=values_from_face_pixels_b;

    %      visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=M1(centers_indexes);
    %     visible_pixels_for_faces(index_in_all_used_group_faces_1,1)=visible_pixels_for_faces(index_in_all_used_group_faces_1,1)+1;

    % here I have to search for the groups of these faces and set the group
    % index for each set.
    for group_index=1:length(region_faces)
        current_group_faces=cell2mat(region_faces(group_index));
        [~,intersect_inds]=intersect(hitted_faces_2,current_group_faces);
        if(~isempty(intersect_inds))
            groups(group_index).frame(i+1).faces=hitted_faces_2(intersect_inds);
            groups(group_index).frame(i+1).values=values_from_face_pixels_L(intersect_inds);
            groups(group_index).frame(i+1).values_a=values_from_face_pixels_a(intersect_inds);
            groups(group_index).frame(i+1).values_b=values_from_face_pixels_b(intersect_inds);
            groups(group_index).frames_index=[groups(group_index).frames_index;(i+1)];
            %             num_faces_in_frames=[num_faces_in_frames;[(i+1), group_index, length(intersect_inds)]];
            frames_groups_tracker(i+1,frames_groups_tracker(i+1,1)+2)=group_index;
            frames_groups_tracker(i+1,1)=frames_groups_tracker(i+1,1)+1;
        end
    end
    texture_exist(:,:,index)=current_texture_frame;
end
% I commented its line as no need for it now
num_faces_in_frames=[];
time_to_get_faces_colors=toc
% stored_hitted_faces
 se = strel('disk',50);
 textures_images_and_faces=cell(size(region_frames,1),4);
 to_be_removed=[];
% load('up_to_this_point.mat');
seems_coord=cell(size(region_frames,1),1);
for index=1:size(region_frames,1)
    
    faces_in_current_frame=find(face_text_at_which_image==index);
    BW=texture_exist(:,:,index)>0;
    BW_back=BW;
    BW = (imdilate(BW,se));
    [r,c]=find(BW);
    if(isempty(r))
        to_be_removed=[to_be_removed;index];
        continue;
    end
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
combine_textures_in_one_2(mesh,textures_images_and_faces,faces_coord_in_orig_img,tex_path,seems_coord);
% [height_texture_coord_in_img,width_texture_coord_in_img,tex_im_height,tex_im_width]=combine_textures_in_one(mesh,sorted_faces_textures,sorted_array,tex_path,original_faces_indexes);
% f_o_height_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=1-height_texture_coord_in_img/tex_im_height;
% f_o_width_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=width_texture_coord_in_img/tex_im_width;
% face_have_texture(original_faces_indexes(1:size(height_texture_coord_in_img,1)))=1;
%
% write_into_obj_file(mesh,f_o_height_texture_coord_in_img,f_o_width_texture_coord_in_img,face_have_texture,tex_path)

% TODO: save to mtl file.
time_to_finish_whole_function=toc
d=[];
