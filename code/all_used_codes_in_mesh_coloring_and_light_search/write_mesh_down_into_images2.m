function write_mesh_down_into_images2(mesh,region_frames,final_faces,final_vertices,final_faces_colors,scene_name,region_number,flag)
% poolobj = gcp('nocreate');
% delete(poolobj)
flag=0;
image_height=1024;
image_width=1280;
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number)]);
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number),'/original']);
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number),'/ours']);
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number),'/textured']);
centers_3d=get_faces_centers(final_faces,final_vertices);

% t = opcodemesh((final_vertices)',(final_faces)');
for kk=1:size(region_frames,1)
    faces_image_indexes=zeros(image_height*image_width,1);% this is to store for each pixel the nearest face to it and its distance.
    fame_num=region_frames(kk,1);
    distance_to_camera=vecnorm(centers_3d(:,1:3)-mesh.campos(fame_num),1,2);
    intrinsics=mesh.intrinsics;
    pose_matrix=mesh.pose(fame_num).pose_matrix;
    rotation_matrix=pose_matrix(1:3,1:3)';
    camera_position_in_world=pose_matrix(1:3,4);
    translation=-1*rotation_matrix*camera_position_in_world;
    RT_matrix=[rotation_matrix,translation];RT_matrix=[RT_matrix;0 0 0 1];projection_matrix=intrinsics*RT_matrix;
    point_2d=projection_matrix*centers_3d';
    faces_in_range=true(size(point_2d',1),1);
    faces_in_range(point_2d(3,:)<0)=0;
    point_2d=point_2d(1:2,:)./point_2d(3,:);% remove the behind points
    point_2d=round(point_2d');

    faces_in_range(point_2d(:,1)<1)=0;
    faces_in_range(point_2d(:,2)<1)=0;
    faces_in_range(point_2d(:,2)>image_height)=0;
    faces_in_range(point_2d(:,1)>image_width)=0;
    point_2d(~faces_in_range,:)=1;
    image_indexes=sub2ind([image_height,image_width],point_2d(:,2),point_2d(:,1)); 
    used_from_image_indexes=false(image_height*image_width,1);
    
%  indexes_of_faces_to_project contain the real indexes of faces in the faces array   
    indexes_of_faces_to_project=find(faces_in_range);
%     colors_of_faces_to_project=final_faces(faces_in_range,:);
    distance_of_faces_to_project=distance_to_camera(faces_in_range);
    %% projected_coordinates represent the indexes in the final projected image its length will be the same like all of faces could be projected in this frame even if it is not visible
    projected_coordinates=image_indexes(faces_in_range);
    [sorted_distances,ia]=sort(distance_of_faces_to_project);
    sorted_indexes_of_faces=indexes_of_faces_to_project(ia);
    sorted_projected_coordinates=projected_coordinates(ia);
    for i=1:length(sorted_distances)
        if(used_from_image_indexes(sorted_projected_coordinates(i)))
            continue;
        end
        faces_image_indexes(sorted_projected_coordinates(i))=sorted_indexes_of_faces(i);
    end
    
    required_faces_from_image=false(size(faces_image_indexes,1),1);
     required_faces_from_image(faces_image_indexes>0)=1;
     existed_faces=faces_image_indexes;
    new_image=zeros(image_height*image_width,3);
         red=final_faces_colors(:,1);
     green=final_faces_colors(:,2);
     blue=final_faces_colors(:,3);
    new_image(required_faces_from_image,1)=red(existed_faces(required_faces_from_image));
     new_image(required_faces_from_image,2)=green(existed_faces(required_faces_from_image));
     new_image(required_faces_from_image,3)=blue(existed_faces(required_faces_from_image));
     new_image=reshape(new_image,[image_height,image_width,3]);
     new_image=uint8(new_image);
%      figure;imshow(new_image);
      imwrite(new_image,['mesh_coloring/',scene_name,'/',num2str(region_number),'/textured/frame-',sprintf('%06d',fame_num-1),'.color.png']);
    d=[];
    
    
    
    
    
    
    
    
    
    
    
    
    
%     [unique_coordinates,ia,ib]=unique(projected_coordinates);
%     unique_coordinates_faces_indexes=indexes_of_faces_to_project(ia,:);
%     unique_coordinates_faces_distances=distance_to_camera(unique_coordinates_faces_indexes);
%     [~,min_index]=min(([faces_image_indexes(unique_coordinates,1),unique_coordinates_faces_distances])');
%     faces_image_indexes(unique_coordinates(min_index==2),1)=unique_coordinates_faces_distances(min_index==2);
%     faces_image_indexes(unique_coordinates(min_index==2),2)=unique_coordinates_faces_indexes(min_index==2);
%     projected_coordinates(ia)=[];
%     indexes_of_faces_to_project(ia,:)=[];
% index_for_valid_projected_coordinates=true(size(projected_coordinates,1),1);
% a=sort(projected_coordinates);b=diff(a);index_a=[([0;find(b)]+1),[find(b);(length(b)+1)]];
% 
%     while(~isempty(projected_coordinates(index_for_valid_projected_coordinates)))
%         [unique_coordinates,ia,~]=unique(projected_coordinates(index_for_valid_projected_coordinates));
%         valid_indexes=find(index_for_valid_projected_coordinates);
%         valid_indexes=valid_indexes(ia);
%         
%     unique_coordinates_faces_indexes=indexes_of_faces_to_project(valid_indexes,:);
%     unique_coordinates_faces_distances=distance_to_camera(unique_coordinates_faces_indexes);
%     [~,min_index]=min(([faces_image_indexes(unique_coordinates,1),unique_coordinates_faces_distances])');
%     faces_image_indexes(unique_coordinates(min_index==2),1)=unique_coordinates_faces_distances(min_index==2);
%     faces_image_indexes(unique_coordinates(min_index==2),2)=unique_coordinates_faces_indexes(min_index==2);
%     index_for_valid_projected_coordinates(valid_indexes)=0;
% %     projected_coordinates(ia)=[];
% %     indexes_of_faces_to_project(ia,:)=[];
%     end
%     
%     required_faces_from_image=false(size(faces_image_indexes,1),1);
%      required_faces_from_image(faces_image_indexes(:,2)>0)=1;
%      existed_faces=faces_image_indexes(:,2);
%     new_image=zeros(size(idxx,1),3);
%          red=final_faces_colors(:,1);
%      green=final_faces_colors(:,2);
%      blue=final_faces_colors(:,3);
%     new_image(required_faces_from_image,1)=red(existed_faces(required_faces_from_image));
%      new_image(required_faces_from_image,2)=green(existed_faces(required_faces_from_image));
%      new_image(required_faces_from_image,3)=blue(existed_faces(required_faces_from_image));
%      new_image=reshape(new_image,[image_height,image_width,3]);
%      new_image=uint8(new_image);
    
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     hitted_mesh_pixels=[];
%             [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
%         [rays_directions,~]=get_ray_direction(mesh.pose(fame_num).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
%         temp_index=ones([size(rays_directions,2),1])*fame_num;
%         [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
%         new_image=zeros(size(idxx,1),3);
%         
%         
%     required_faces_from_image=false(size(idxx));
%    
%      required_faces_from_image(idxx>0)=1;
%      red=final_faces_colors(:,1);
%      green=final_faces_colors(:,2);
%      blue=final_faces_colors(:,3);
%      new_image(required_faces_from_image,1)=red(idxx(required_faces_from_image));
%      new_image(required_faces_from_image,2)=green(idxx(required_faces_from_image));
%      new_image(required_faces_from_image,3)=blue(idxx(required_faces_from_image));
%      new_image=reshape(new_image,[image_height,image_width,3]);
%      new_image=uint8(new_image);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      ycbcr=rgb2ycbcr(new_image);
% windowSize = 17;
% kernel = ones(windowSize) / windowSize^2;
% heat_map = conv(double(ycbcr(:,:,1)), kernel, 'same');
% imshow(ycbcr(:,:,1));
% colormap(gcf, hsv(256));
%      figure;imshow();

% if(flag)
% imwrite(new_image,['mesh_coloring/',scene_name,'/',num2str(region_number),'/original/frame-',sprintf('%06d',fame_num-1),'.color.png']);
% saveas(gcf,['mesh_coloring/',scene_name,'/',num2str(region_number),'/original/frame-',sprintf('%06d',fame_num-1),'.colorhm.png']);
% else
%     imwrite(new_image,['mesh_coloring/',scene_name,'/',num2str(region_number),'/textured/frame-',sprintf('%06d',fame_num-1),'.color.png']);
% %     saveas(gcf,['mesh_coloring/',scene_name,'/',num2str(region_number),'/textured/frame-',sprintf('%06d',fame_num-1),'.colorhm.png']);
% end
end

d=[];