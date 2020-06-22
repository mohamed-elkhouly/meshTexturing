function  [num_faces_in_frames, groups, original_faces_tracking, final_faces, final_vertices, final_faces_colors]=get_faces_colors_for_each_group_from_each_frame_separately_3(mesh, all_used_groups_faces, region_frames, region_faces,scene_name,folder_path, start_of_faces_indexing, end_of_faces_indexing,using_different_mesh)
if(using_different_mesh)
    region_frames=region_frames(:);
end
% visible_pixels_for_faces=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% visible_pixels_for_faces_a=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% visible_pixels_for_faces_b=zeros(size(all_used_groups_faces,1),size(region_frames,1)/2);
% distance_visible_pixels_for_faces_from_camera=zeros(size(all_used_groups_faces,1),150);
groups_struct=[];
frames_groups_tracker=zeros(max(region_frames(:,1))+1,length(region_faces)+1);
for group_index=1:length(region_faces)
    groups(group_index).frames_index=[];
    groups(group_index).should_be_estimated=[];
end
num_faces_in_frames=[];
faces_texture=cell(size(mesh.f,1),1);
faces_texture_color_index=cell(size(mesh.f,1),1);
faces_texture_color_l=cell(size(mesh.f,1),1);
faces_texture_color_a=cell(size(mesh.f,1),1);
faces_texture_color_b=cell(size(mesh.f,1),1);
faces_texture_information=zeros(size(mesh.f,1),2);% we store in it the frame of texture of each face, and the length of pixels in texture.
tic
for index=1:size(region_frames,1)
    i=region_frames(index);
    image_name=sprintf('frame-%06d.color.jpg',i);
    image_name2=sprintf('frame-%06d.color.png',i);
    image_path=[folder_path,'/frame/',image_name];
    image_path2=[folder_path,'/frame/',image_name2];
    try
        image=imread(image_path);
        image(2,342:916,:)=image(3,342:916,:);image(1,221:1038,:)=image(2,221:1038,:); % fix zeros_which is in top of each image in matterport.
        image(1023,419:836,:)=image(1022,419:836,:);image(1024,267:992,:)=image(1023,267:992,:); % fix zeros_which is in bottom of each image in matterport.
        image(335:670,1,:)=image(335:670,2,:); % fix zeros_which is in left of each image in matterport.
    catch
        image=imread(image_path2);
    end
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
        groups1=faces_image(:,:,3);
        A=double([trans(:),r(:),g(:),groups1(:)]);
        faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
        idxx=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
    else
        idxx=mesh.frame_face_mapping(i+1,:,:);
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
    for ui=1:length(hitted_faces_2)
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
            faces_texture_information(hitted_faces_2(ui),1)=index;
            faces_texture_information(hitted_faces_2(ui),2)=length(all_indexes_in_idxx(required_indexes_for_access_image));
            faces_texture(hitted_faces_2(ui))={all_indexes_in_idxx(required_indexes_for_access_image)};
            current_face_vertices=[mesh.v(mesh.f(hitted_faces_2(ui),:),:),[1;1;1]];
            
            intrinsics=mesh.intrinsics;
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
            %             [indh,indw]=ind2sub([height,width],all_indexes_in_idxx(required_indexes_for_access_image));
            [x_ind,y_ind]=meshgrid(min(indh):max(indh),min(indw):max(indw));
%             faces_textures(hitted_faces_2(ui))={lab_img(min(indh):max(indh),min(indw):max(indw),:)};
            temp_index=sub2ind([height,width],x_ind(:),y_ind(:));
            faces_texture_color_index(hitted_faces_2(ui))={temp_index};
            faces_texture_color_l(hitted_faces_2(ui))={L_channel(temp_index)};
            faces_texture_color_a(hitted_faces_2(ui))={a_channel(temp_index)};
            faces_texture_color_b(hitted_faces_2(ui))={b_channel(temp_index)};
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
end
% I commented its line as no need for it now
num_faces_in_frames=[];
time_to_get_faces_colors=toc




original_faces_tracking=cell(size(mesh.f,1),1);
final_faces=zeros(size(mesh.f,1)*300,3);
final_vertices=zeros(size(mesh.v,1)*300,3);
final_faces_colors=zeros(size(mesh.f,1)*300,3);
final_faces_index=1;
final_color_index=1;
final_vertices_index=1;

for face_iter=1:size(mesh.f,1)
    current_face=mesh.f(face_iter,:);
    current_face_vertices=mesh.v(current_face(:),:);
    required_divisions=faces_texture_information(face_iter,2);
    if(required_divisions>2)
        [cur_new_faces,cur_new_vertices]=refine_face([1 2 3],current_face_vertices,required_divisions);
        if(final_faces_index+size(cur_new_faces,1))>size(final_faces,1)
            final_faces=[final_faces;zeros(size(mesh.f,1)*300,3)];
            final_faces_colors=[final_faces_colors;zeros(size(mesh.f,1)*100,3)];
        end
        if(final_vertices_index+size(cur_new_vertices,1))>size(final_vertices,1)
            final_vertices=[final_vertices;zeros(size(mesh.v,1)*100,3)];
        end
        final_faces(final_faces_index:(size(cur_new_faces,1)+final_faces_index-1),:)=(cur_new_faces+final_vertices_index-1);
        original_faces_tracking(face_iter)={final_faces_index:(size(cur_new_faces,1)+final_faces_index-1)};
        final_vertices(final_vertices_index:(size(cur_new_vertices,1)+final_vertices_index-1),:)=cur_new_vertices;
        
        
        
        centers_3d=get_faces_centers(cur_new_faces,cur_new_vertices);
        
        current_frame=region_frames(faces_texture_information(face_iter,1))+1;
        intrinsics=mesh.intrinsics;
        pose_matrix=mesh.pose(current_frame).pose_matrix;
        rotation_matrix=pose_matrix(1:3,1:3)';
        camera_position_in_world=pose_matrix(1:3,4);
        translation=-1*rotation_matrix*camera_position_in_world;
        RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
        point_2d=projection_matrix*centers_3d';
        point_2d=point_2d(1:2,:)./point_2d(3,:);
        point_2d(point_2d<1)=1;
        ww=point_2d(1,:);hh=point_2d(2,:);
        ww(ww>width)=width;hh(hh>height)=height;
        
        %     indices=sub2ind([height, width],round(hh),round(ww));
        used_indices=cell2mat(faces_texture_color_index(face_iter));
        [used_ind_h,used_ind_w]=ind2sub([height, width],used_indices);
        [~,min_h_ind]=min(abs(used_ind_h-hh));
        [~,min_w_ind]=min(abs(used_ind_w-ww));
        indices=sub2ind([height, width],used_ind_h(min_h_ind),used_ind_w(min_w_ind));
        stored_l=cell2mat(faces_texture_color_l(face_iter));
        stored_a=cell2mat(faces_texture_color_a(face_iter));
        stored_b=cell2mat(faces_texture_color_b(face_iter));
        
        [ind_new_faces,ind_stored_pixels]=ismember(indices,used_indices);
        %     ind_stored_pixels(ind_stored_pixels==0)=[];
        cur_new_faces_colors=cur_new_faces;
        cur_new_faces_colors(:)=0;
        cur_new_faces_colors=uint8(cur_new_faces_colors);
        cur_new_faces_colors(ind_new_faces,1)=stored_l(ind_stored_pixels);
        cur_new_faces_colors(ind_new_faces,2)=stored_a(ind_stored_pixels);
        cur_new_faces_colors(ind_new_faces,3)=stored_b(ind_stored_pixels);
        final_faces_colors(final_faces_index:(size(cur_new_faces_colors,1)+final_faces_index-1),:)=cur_new_faces_colors;
        final_faces_index=final_faces_index+size(cur_new_faces,1);
        final_vertices_index=final_vertices_index+size(cur_new_vertices,1);
        d=[];
        
    else
        final_faces(final_faces_index:(1+final_faces_index-1),:)=[final_vertices_index,final_vertices_index+1,final_vertices_index+2];
        original_faces_tracking(face_iter)={final_faces_index};
        final_vertices(final_vertices_index:(size(current_face_vertices,1)+final_vertices_index-1),:)=current_face_vertices;
        stored_l=cell2mat(faces_texture_color_l(face_iter));
        stored_a=cell2mat(faces_texture_color_a(face_iter));
        stored_b=cell2mat(faces_texture_color_b(face_iter));
        final_faces_colors(final_faces_index:(1+final_faces_index-1),:)=[mean(stored_l) mean(stored_a) mean(stored_b)];
        final_faces_index=final_faces_index+1;
        final_vertices_index=final_vertices_index+size(current_face_vertices,1);
    end
    
end
final_faces(final_faces_index:end,:)=[];
final_faces_colors(final_faces_index:end,:)=[];
final_vertices(final_vertices_index:end,:)=[];
[final_vertices, ~,ic] = unique(final_vertices, 'rows');
% temp=final_faces;
final_faces(:,1)=ic(final_faces(:,1));
final_faces(:,2)=ic(final_faces(:,2));
final_faces(:,3)=ic(final_faces(:,3));
final_faces_colors=uint8(final_faces_colors);
% figure,plot_CAD(final_faces, final_vertices, '',final_faces_colors);
% delete(findall(gcf,'Type','light'));

% img(:,:,1)=final_faces_colors(:,1);img(:,:,2)=final_faces_colors(:,2);img(:,:,3)=final_faces_colors(:,3);
% img_y=rgb2ycbcr(img);
% img_y(1,1,1)
% img_y(:,:,1)=128;
% img_y(:,:,2)=128;
% r_img=ycbcr2rgb(img_y);
% final_faces_colors(:,1)=r_img(:,:,1);final_faces_colors(:,2)=r_img(:,:,2);final_faces_colors(:,3)=r_img(:,:,3);
% figure,plot_CAD(final_faces, new_final_vertices, '',final_faces_colors);
% delete(findall(gcf,'Type','light'));
time_to_finish_whole_function=toc
d=[];
