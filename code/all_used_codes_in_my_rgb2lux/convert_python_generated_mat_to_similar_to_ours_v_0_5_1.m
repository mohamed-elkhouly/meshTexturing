function  mesh=convert_python_generated_mat_to_similar_to_ours_v_0_5(in_var,original_path,simplified,folder_path,region_number,scene_name)
image_height=1024;
image_width=1280;
mesh.v=double(in_var{1});
mesh.v_c=double(in_var{2})/255;
mesh.v_n=double(in_var{3});
mesh.f=cell2mat(in_var{4})+1;
mesh.f_c=meshFaceColors(mesh.v_c, mesh.f);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
%% read camera poses and intrinsics
mesh=read_poses_and_intrinsics(mesh,folder_path);
%% get region frames by projecting mesh
% current_cam_pos=1;
%  [all_image_pixels(2,:), all_image_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
%  [rays_directions,~]=get_ray_direction(mesh.pose(current_cam_pos).pose_matrix,mesh.intrinsics,all_image_pixels);
%  t = opcodemesh(mesh.v',mesh.f');
%  temp_index=ones([size(rays_directions,2),1])*current_cam_pos;
%             [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);

%%
% figure;
% plot_CAD(mesh.f, mesh.v, '');
% delete(findall(gcf,'Type','light'));
max_face_area=0.0001;
acceptable_error=0.0003;
regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end
if region_number==length(faces_count_per_regions)
    end_of_faces_indexing=faces_count_per_regions(region_number)+size(mesh.f,1);
else
end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;
end
se = strel('disk',3);
for k=1:length(mesh.campos)
    frame_number= sprintf( '%06d', k-1) ;
    file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
    [faces_image,~,trans]=imread(file_path);
    r=faces_image(:,:,1);
    g=faces_image(:,:,2);
    b=faces_image(:,:,3);
    A=double([trans(:),r(:),g(:),b(:)]);
    faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
    empty_mask=zeros([length(faces_numbers),1]);
    empty_mask(faces_numbers>4294967294)=255;
    faces_numbers=faces_numbers+1;
    faces_numbers(faces_numbers>(end_of_faces_indexing-1))=-1;
    faces_numbers=faces_numbers-start_of_faces_indexing;
    empty_mask=reshape(empty_mask,[1024 1280])>0;
    
    [Labels,Num_holes]=bwlabel(empty_mask);
    
    for i=1:Num_holes
        new_empty_mask=empty_mask;
        new_empty_mask(:,:)=0;
        new_empty_mask(Labels==i)=1;
        dilated_mask=imdilate(new_empty_mask,se);
        diff=dilated_mask-new_empty_mask;
        %             figure;imshow((diff));
        diff=diff(:);
        boundary_faces = unique(faces_numbers(diff>0));
        boundary_faces=boundary_faces(boundary_faces>0);
        if(~isempty(boundary_faces))
            color_view=zeros([length(mesh.f),1]);
            color_view(boundary_faces)=100;
            %     figure,
            % plot_CAD(mesh.f, mesh.v, '',color_view);
            %     delete(findall(gcf,'Type','light'));
            boundary_vertices=mesh.f(boundary_faces(:),:);
            boundary_vertices=boundary_vertices(:);
            coords_of_vertices_of_neighborhood_faces=mesh.v(boundary_vertices,:);
            [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
            projected_points =projection_of_points_on_a_plane(mesh.v(boundary_vertices,:),plane_center,normal);
            distance_between_projections=mesh.v(boundary_vertices,:)-projected_points;
            error=norm(distance_between_projections)/length(distance_between_projections);
            if error<acceptable_error
                try
                    convex_hull_faces =convhull(projected_points(:,1),projected_points(:,2),projected_points(:,3));
                    [refined_faces,temp_final_vertices]=refine_mesh(convex_hull_faces,[projected_points],max_face_area);
                    mesh.f=[mesh.f;(refined_faces+length(mesh.v))];
                    mesh.v=[mesh.v;temp_final_vertices];

                catch
                end
            else
                error
                used_bv=boundary_vertices;
                temp_used_bv=used_bv;
                excluded_bv=[];
                temp_excluded_bv=[];
                current_error=error;
                stored_error=[];
                for bv_index=1:length(boundary_vertices)
                    temp_excluded_bv=[excluded_bv;bv_index];
                    temp_used_bv(temp_excluded_bv)=[];
                    if size(temp_used_bv,1)>3 % to be sure that we can have convex hull
                        coords_of_vertices_of_neighborhood_faces=mesh.v(temp_used_bv,:);
                        [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
                        projected_points =projection_of_points_on_a_plane(mesh.v(temp_used_bv,:),plane_center,normal);
                        distance_between_projections=mesh.v(temp_used_bv,:)-projected_points;
                        bv_error=norm(distance_between_projections)/length(distance_between_projections);
                        stored_error=[stored_error;(current_error-bv_error)];
                    else
                        break;
                    end
                    temp_used_bv=used_bv;
                end
                max_error_diff=max(stored_error);
                our_desired_thresh=max_error_diff-max_error_diff/1.01;
                temp_used_bv=used_bv;
                temp_used_bv (stored_error>our_desired_thresh)=[];
                if size(temp_used_bv,1)>3
                coords_of_vertices_of_neighborhood_faces=mesh.v(temp_used_bv,:);
                [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
                projected_points =projection_of_points_on_a_plane(mesh.v(used_bv,:),plane_center,normal);
                projected_points_back=projected_points;
                projected_points(stored_error>our_desired_thresh,:)=[];
                distance_between_projections=mesh.v(temp_used_bv,:)-projected_points;
                final_bv_error=norm(distance_between_projections)/length(distance_between_projections)
                if final_bv_error<acceptable_error
                    try
                        convex_hull_faces =convhull(projected_points_back(:,1),projected_points_back(:,2),projected_points_back(:,3));
                        [refined_faces,temp_final_vertices]=refine_mesh(convex_hull_faces,[projected_points],max_face_area);
                    mesh.f=[mesh.f;(refined_faces+length(mesh.v))];
                    mesh.v=[mesh.v;temp_final_vertices];
%                         mesh.f=[mesh.f;(convex_hull_faces+length(mesh.v))];
%                         mesh.v=[mesh.v;projected_points_back];
                    catch
                    end
                else
                end
            end
            end
            
            % figure;subplot(1,2,1);
            % hold on
            % trisurf(convex_hull_faces,projected_points(:,1),projected_points(:,2),projected_points(:,3),'Facecolor','cyan');
            %     [refined_faces,mesh.v]=refine_mesh(convex_hull_faces,[mesh.v;required_cam_pos],max_face_area);
        end
    end
end

figure;
plot_CAD(mesh.f, mesh.v, '',[zeros([size(mesh.f_c,1) 1]); 200*ones([(size(mesh.f,1)-size(mesh.f_c,1)),1])]);
savefig(['region',num2str(region_number) ,'_hole_filled_0.0003_1.01_1st_iteration.fig'])
added_faces=mesh.f(size(mesh.f_c,1)+1:end,:);
%% 
% current_cam_pos=100;
 [all_image_pixels(2,:), all_image_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
  t = opcodemesh(mesh.v',mesh.f');
 for k=1:length(mesh.campos)
     current_cam_pos=k;
    frame_number= sprintf( '%06d', k-1) ;
    file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
    [faces_image,~,trans]=imread(file_path);
    r=faces_image(:,:,1);
    g=faces_image(:,:,2);
    b=faces_image(:,:,3);
    A=double([trans(:),r(:),g(:),b(:)]);
    faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
    empty_mask=zeros([length(faces_numbers),1]);
    empty_mask(faces_numbers>4294967294)=255;
    faces_numbers=faces_numbers+1;
    faces_numbers(faces_numbers>(end_of_faces_indexing-1))=-1;
    faces_numbers=faces_numbers-start_of_faces_indexing;
    empty_mask=reshape(empty_mask,[1024 1280])>0;
   
    
    
 [rays_directions,~]=get_ray_direction(mesh.pose(current_cam_pos).pose_matrix,mesh.intrinsics,all_image_pixels);

 temp_index=ones([size(rays_directions,2),1])*current_cam_pos;
            [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
reprojected_faces=reshape(idxx,[1024 1280 ]);
empty_reprojected=~(reprojected_faces>0);
empty_reprojected(~empty_mask)=0;
empty_mask=empty_reprojected;
[Labels,Num_holes]=bwlabel(empty_mask);
faces_numbers=reprojected_faces;

for i=1:Num_holes
        new_empty_mask=empty_mask;
        new_empty_mask(:,:)=0;
        new_empty_mask(Labels==i)=1;
        dilated_mask=imdilate(new_empty_mask,se);
        diff=dilated_mask-new_empty_mask;
        %             figure;imshow((diff));
        diff=diff(:);
        boundary_faces = unique(faces_numbers(diff>0));
        boundary_faces=boundary_faces(boundary_faces>0);
        if(~isempty(boundary_faces))
            color_view=zeros([length(mesh.f),1]);
            color_view(boundary_faces)=100;
            %     figure,
            % plot_CAD(mesh.f, mesh.v, '',color_view);
            %     delete(findall(gcf,'Type','light'));
            boundary_vertices=mesh.f(boundary_faces(:),:);
            boundary_vertices=boundary_vertices(:);
            coords_of_vertices_of_neighborhood_faces=mesh.v(boundary_vertices,:);
            [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
            projected_points =projection_of_points_on_a_plane(mesh.v(boundary_vertices,:),plane_center,normal);
            distance_between_projections=mesh.v(boundary_vertices,:)-projected_points;
            error=norm(distance_between_projections)/length(distance_between_projections);
            if error<acceptable_error
                try
                    convex_hull_faces =convhull(projected_points(:,1),projected_points(:,2),projected_points(:,3));
                    [refined_faces,temp_final_vertices]=refine_mesh(convex_hull_faces,[projected_points],max_face_area);
                    mesh.f=[mesh.f;(refined_faces+length(mesh.v))];
                    mesh.v=[mesh.v;temp_final_vertices];
%                     mesh.f=[mesh.f;(convex_hull_faces+length(mesh.v))];
%                     mesh.v=[mesh.v;projected_points];
                catch
                end
            else
                error
                used_bv=boundary_vertices;
                temp_used_bv=used_bv;
                excluded_bv=[];
                temp_excluded_bv=[];
                current_error=error;
                stored_error=[];
                for bv_index=1:length(boundary_vertices)
                    temp_excluded_bv=[excluded_bv;bv_index];
                    temp_used_bv(temp_excluded_bv)=[];
                    if size(temp_used_bv,1)>3 % to be sure that we can have convex hull
                        coords_of_vertices_of_neighborhood_faces=mesh.v(temp_used_bv,:);
                        [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
                        projected_points =projection_of_points_on_a_plane(mesh.v(temp_used_bv,:),plane_center,normal);
                        distance_between_projections=mesh.v(temp_used_bv,:)-projected_points;
                        bv_error=norm(distance_between_projections)/length(distance_between_projections);
                        stored_error=[stored_error;(current_error-bv_error)];
                    else
                        break;
                    end
                    temp_used_bv=used_bv;
                end
                max_error_diff=max(stored_error);
                our_desired_thresh=max_error_diff-max_error_diff/1.01;
                temp_used_bv=used_bv;
                temp_used_bv (stored_error>our_desired_thresh)=[];
                if size(temp_used_bv,1)>3
                coords_of_vertices_of_neighborhood_faces=mesh.v(temp_used_bv,:);
                [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
                projected_points =projection_of_points_on_a_plane(mesh.v(used_bv,:),plane_center,normal);
                projected_points_back=projected_points;
                projected_points(stored_error>our_desired_thresh,:)=[];
                distance_between_projections=mesh.v(temp_used_bv,:)-projected_points;
                final_bv_error=norm(distance_between_projections)/length(distance_between_projections)
                if final_bv_error<acceptable_error
                    try
                        convex_hull_faces =convhull(projected_points_back(:,1),projected_points_back(:,2),projected_points_back(:,3));
                        [refined_faces,temp_final_vertices]=refine_mesh(convex_hull_faces,[projected_points],max_face_area);
                    mesh.f=[mesh.f;(refined_faces+length(mesh.v))];
                    mesh.v=[mesh.v;temp_final_vertices];
%                         mesh.f=[mesh.f;(convex_hull_faces+length(mesh.v))];
%                         mesh.v=[mesh.v;projected_points_back];
                    catch
                    end
                else
                end
            end
            end
            
            % figure;subplot(1,2,1);
            % hold on
            % trisurf(convex_hull_faces,projected_points(:,1),projected_points(:,2),projected_points(:,3),'Facecolor','cyan');
            %     [refined_faces,mesh.v]=refine_mesh(convex_hull_faces,[mesh.v;required_cam_pos],max_face_area);
        end
    end
 end

%%
figure;
plot_CAD(mesh.f, mesh.v, '',[zeros([size(mesh.f_c,1) 1]); 200*ones([(size(mesh.f,1)-size(mesh.f_c,1)),1])]);
savefig(['region',num2str(region_number) ,'_hole_filled_0.0003_1.01_2nd_iteration.fig'])
[mesh,region_frames]=calculate_region_frames(mesh,folder_path,[],region_number);
required_cam_pos=mesh.campos(region_frames(:,1)+1,:);
d=[];
%%  enclosing our mesh inside a convex hull mesh
max_face_area=0.01;
convex_hull_faces = convhull([mesh.v(:,1);required_cam_pos(:,1)],[mesh.v(:,2);required_cam_pos(:,2)],[mesh.v(:,3);required_cam_pos(:,3)]);
figure;subplot(1,2,1);trisurf(convex_hull_faces,[mesh.v(:,1);required_cam_pos(:,1)],[mesh.v(:,2);required_cam_pos(:,2)],[mesh.v(:,3);required_cam_pos(:,3)],'Facecolor','cyan');
[refined_faces,mesh.v]=refine_mesh(convex_hull_faces,[mesh.v;required_cam_pos],max_face_area);
subplot(1,2,2);trisurf(refined_faces,mesh.v(:,1),mesh.v(:,2),mesh.v(:,3),'Facecolor','cyan');
mesh.f=[mesh.f;refined_faces];
d=[];
%% enclosing our mesh inside a sphere (which can enclose whole scene). comment it to remove the sphere
% [x,y,z]=sphere(400);
% wide_range=30;
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% fvc=surf2patch(x,y,z,'triangles');
%
% mesh.f=[mesh.f;(fvc.faces+length(mesh.v))];
% mesh.v=[mesh.v;fvc.vertices];
%% enclosing our mesh inside a sphere (only specific for this region). comment it to remove the sphere
% min_val=min(mesh.v);
% max_val=max(mesh.v);
% % wide_range=max(abs(min_val+max_val)/4);
% wide_range=max(abs(max_val-min_val)*1.4142);
% circle_center_point=(min_val+max_val)/2;
% [x,y,z]=sphere(150);
% % wide_range=30;
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
%
% mesh.f=[mesh.f;(fvc.faces+length(mesh.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% min_circle_val=min(fvc.vertices);
% max_circle_val=max(fvc.vertices);
% mesh.v=[mesh.v;fvc.vertices];
% % figure, plot_CAD(mesh.f, mesh.v, '');
% % delete(findall(gcf,'Type','light'));

%% putting sphere in the camera position which is the center of the sphere to check our values.
% min_val=min(mesh.v);
% max_val=max(mesh.v);
% wide_range=1/2;
% % wide_range=max(abs(max_val-min_val)*1.4142);
% circle_center_point=[-2.99738,3.05701,-1.11385];
% [x,y,z]=sphere(150);
% % wide_range=30;
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
%
% mesh.f=[mesh.f;(fvc.faces+length(mesh.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% min_circle_val=min(fvc.vertices);
% max_circle_val=max(fvc.vertices);
% mesh.v=[mesh.v;fvc.vertices];
% figure, plot_CAD(mesh.f, mesh.v, '');
% delete(findall(gcf,'Type','light'));

%% putting sphere in adirection of a vector(rays_directions) from camera position which is the center of the sphere to check our values.
%
% mesh1=mesh;
% wide_range=1/6;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% circle_center_point=mesh1.campos(frames_with_specularities(i,1)+1,:);
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% wide_range=1/4;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% [rays_directions,~]=get_ray_direction(mesh1.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh1.intrinsics,[1 ;1]);
% circle_center_point=mesh1.campos(frames_with_specularities(i,1)+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% [rays_directions,~]=get_ray_direction(mesh1.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh1.intrinsics,[1 ;1280]);
% circle_center_point=mesh1.campos(frames_with_specularities(i,1)+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% [rays_directions,~]=get_ray_direction(mesh1.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh1.intrinsics,[1024 ;1280]);
% circle_center_point=mesh1.campos(frames_with_specularities(i,1)+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% [rays_directions,~]=get_ray_direction(mesh1.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh1.intrinsics,[1024 ;1]);
% circle_center_point=mesh1.campos(frames_with_specularities(i,1)+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
%
% hit_light_faces_count_array=zeros([length(mesh1.f),1]);
% hit_light_faces_count_array(length(mesh1.f_c):end)=[1:(length(hit_light_faces_count_array)-length(mesh1.f_c)+1)]*5;
% figure, plot_CAD(mesh1.f, mesh1.v, '',hit_light_faces_count_array);
% delete(findall(gcf,'Type','light'));
%%
mesh.rho=double(in_var{6});
mesh.areas = meshArea(mesh.f,mesh.v);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.luxmeter.patches=[];
if simplified
    try  % this try and catch to skip this part in case that I didn't annotate this region for lights
        load(original_path);
        centroids = meshFaceCentroids(dahy{1},cell2mat(dahy{4})+1);% of the original
        light1=double(dahy{5})+1;% of the original
        light1_faces_centers=centroids(light1(:),:);% of the original
        for i=1:length(light1_faces_centers)
            [~,ind(i)]=min(abs(sum(abs(mesh.centroids-light1_faces_centers(i,:)),2))); %find the minimum distance between new centroids and old light faces centroids
        end
        mesh.lightPatches.light1=unique(ind);
        mesh.lightPatches.allLights=mesh.lightPatches.light1;
    catch
        mesh.lightPatches.light1=double(in_var{5})+1;
        mesh.lightPatches.allLights=double(in_var{5})+1;
    end
else
    mesh.lightPatches.light1=double(in_var{5})+1;
    mesh.lightPatches.allLights=double(in_var{5})+1;
end

mesh=get_specular_faces_v_0_3(mesh,folder_path,region_number,scene_name);