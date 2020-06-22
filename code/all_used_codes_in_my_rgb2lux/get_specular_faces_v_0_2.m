function mesh=get_specular_faces_v_0_2(mesh,folder_path,region_number,scene_name) 
% this version got some error at its end it is not giving the right
% projections I will try to clean it and fix it in the next version.
calculate_region_frames=0;
image_width=1280;
image_height=1024;
write_flag=0;
show_annotated_light_sources_flag=1;
show_auto_detected_light_sources_from_my_method_flag=0;
project_annotated_faces_to_image_again=1;

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0)
    start_of_faces_indexing=0;
else
    start_of_faces_indexing=faces_count_per_regions(region_number);
end
end_of_faces_indexing=faces_count_per_regions(region_number+1)-1;
region_frames=[];

% we can comment the next for loop as in this version it only provide us
% with the mesh.region_frames
if(calculate_region_frames)
    for i=1:size(mesh.campos,1)
        frame_number= sprintf( '%06d', i-1 ) ;
        file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
        [faces_image,~,trans]=imread(file_path);
        r=faces_image(:,:,1);
        g=faces_image(:,:,2);
        b=faces_image(:,:,3);
        A=double([trans(:),r(:),g(:),b(:)]);
        faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
        faces_numbers(faces_numbers>4294967294)=[];
        faces_numbers=unique(faces_numbers);
        faces_numbers(faces_numbers>end_of_faces_indexing)=[];% remove faces of the higher regions
        faces_numbers=faces_numbers-start_of_faces_indexing;
        faces_numbers(faces_numbers<0)=[];% remove faces of the lower regions
        mesh.specularities_in_frame(i).faces_numbers=faces_numbers;
        if(~isempty(faces_numbers))
            region_frames=[region_frames;[i-1, length(faces_numbers)]];
        end
    end
    mesh.specularities_in_frame(:)=[];
end
mesh.region_frames=region_frames;

mkdir([folder_path,'/regions'])
mkdir([folder_path,'/regions/region',num2str(region_number)])
region_specular_frames=[];
max_num_specular_faces=0;
scene_from_json=read_annotated_json(scene_name);
global_hitted_faces=[];
[sunlight_pixels, artificial_pixels, specular_pixels, skylight_pixels, auto_detected_light]=show_region(scene_from_json,region_number,[],scene_name);

%% this part is just for viewing
if (show_annotated_light_sources_flag)
    max_second_dimention=max(max(size(sunlight_pixels,2),size(artificial_pixels,2)),size(skylight_pixels,2));
    required_for_sunlight=max_second_dimention-size(sunlight_pixels,2);
    required_for_artificial=max_second_dimention-size(artificial_pixels,2);
    required_for_skylight=max_second_dimention-size(skylight_pixels,2);
    sunlight_pixels=[sunlight_pixels,zeros([size(sunlight_pixels,1),required_for_sunlight])];
    artificial_pixels=[artificial_pixels,zeros([size(artificial_pixels,1),required_for_artificial])];
    skylight_pixels=[skylight_pixels,zeros([size(skylight_pixels,1),required_for_skylight])];
    % the next line if you want to show all annotated light sources.
    specular_pixels=[sunlight_pixels;artificial_pixels;skylight_pixels];
end
if(show_auto_detected_light_sources_from_my_method_flag)
    % the next line for my auto detected_light source.
    specular_pixels=auto_detected_light;
end
%% end of viewing part
%%
try
    frames_with_specularities=specular_pixels(:,1);
    
    for i=1:size(frames_with_specularities,1)
        %         if(region_frames(i,2)>1000)
        frame_number= sprintf( '%06d', frames_with_specularities(i,1)) ;
        file_path=[folder_path,'/frame/','frame-',frame_number,'.color.jpg'];
        
        if(write_flag==1)
            image=imread(file_path);
            imwrite(image,[folder_path,'/regions/region',num2str(region_number),'/frame-',frame_number,'.color.jpg']);
        else
            %                 specular_image=imread([folder_path,'/regions/region',num2str(region_number),'/masks/frame-',frame_number,'.color_m.jpg']);
            %                 if(sum(sum(specular_image))==0)
            %                     continue
            %                 else
            
            file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
            [faces_image,~,trans]=imread(file_path);
            r=faces_image(:,:,1);
            g=faces_image(:,:,2);
            b=faces_image(:,:,3);
            A=double([trans(:),r(:),g(:),b(:)]);
            faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
            to_be_removed_faces=faces_numbers>end_of_faces_indexing;
            temp_var_1=faces_numbers-start_of_faces_indexing;
            to_be_removed_faces(temp_var_1<0)=1;
            clear temp_var_1;
%             image_positinos=reshape(faces_numbers,[image_width image_height]);
            % here we can replace the (specular_image(:)>0) by the
            % (specularpixels).
            missing_mesh_pixels=[];
            missing_mesh_indexes=find(faces_numbers>4294967294);
            upper_limit_faces=faces_numbers>end_of_faces_indexing;
            if(~isempty(missing_mesh_indexes))
            [missing_mesh_pixels(1,:) missing_mesh_pixels(2,:)]=ind2sub([image_width image_height],missing_mesh_indexes);
            [rays_directions,~]=get_ray_direction(mesh.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh.intrinsics,missing_mesh_pixels);
            temp_index=ones([size(rays_directions,2),1])*frames_with_specularities(i,1)+1;
            t = opcodemesh(mesh.v',mesh.f');
            [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
            faces_numbers(missing_mesh_indexes)=idxx;
            to_be_removed_faces(missing_mesh_indexes)=0;
            end
            temp_index_to_subtract_lower_limit=1:length(faces_numbers);
            temp_index_to_remove_upper_limit=1:length(faces_numbers);
            temp_index_to_remove_upper_limit=temp_index_to_remove_upper_limit(upper_limit_faces);
            [~,idx] = intersect(temp_index_to_subtract_lower_limit,missing_mesh_indexes,'stable');
            temp_index_to_subtract_lower_limit(idx)=[];
            [~,idx] = intersect(temp_index_to_remove_upper_limit,missing_mesh_indexes,'stable');
            temp_index_to_remove_upper_limit(idx)=[];
%             for pp=1:length(missing_mesh_indexes)
%             temp_index_to_subtract_lower_limit(temp_index_to_subtract_lower_limit==missing_mesh_indexes(pp))=[];
%             temp_index_to_remove_upper_limit(temp_index_to_remove_upper_limit==missing_mesh_indexes(pp))=[];
%             end
            faces_numbers(temp_index_to_subtract_lower_limit)=faces_numbers(temp_index_to_subtract_lower_limit)-start_of_faces_indexing;
            faces_numbers(temp_index_to_remove_upper_limit)=-1;
            temp_faces_array(:,i)=faces_numbers;
            % after creating annotations in json file i replaced the
            % next commented line with the line after it.
            %                 faces_numbers=faces_numbers(specular_image(:)>0);
            non_zero_specular_pixels=specular_pixels(i,2:end);
            non_zero_specular_pixels(non_zero_specular_pixels==0)=[];
            if(project_annotated_faces_to_image_again)
                hitted_faces=faces_numbers(non_zero_specular_pixels);
%                 missing_mesh_faces=hitted_faces(hitted_faces>4294967294);
%                 if ~isempty(missing_mesh_faces)
%                 hitted_faces(hitted_faces>4294967294)=[];
%                 end
                hitted_faces=unique(hitted_faces);
                hitted_faces=hitted_faces(hitted_faces>=0)+1;
                global_hitted_faces(hitted_faces)=1;
                %                         like_faces_array=logical(zeros([length(faces_numbers) 1]));
                %                         for oo=1:length(hitted_faces)
                %                            generated_mask( faces_numbers==hitted_faces(oo))=true;
                %                         end
                %                         generated_mask=reshape(like_faces_array,[size(faces_image,1) size(faces_image,2)]);
                % %                         generated_mask(non_zero_specular_pixels)=true;
                %                         imwrite(generated_mask,[folder_path,'/projected_annotations/','frame-',frame_number,'.color.png']);
            end
            to_be_kept_faces=~to_be_removed_faces;
            non_zero_specular_pixels=non_zero_specular_pixels(to_be_kept_faces(non_zero_specular_pixels));
            faces_numbers=faces_numbers(non_zero_specular_pixels);
            
%             faces_numbers(faces_numbers>4294967294)=[];
            
            faces_numbers=unique(faces_numbers);
%             faces_numbers(faces_numbers>end_of_faces_indexing)=[];% remove faces of the higher regions
%             faces_numbers=faces_numbers-start_of_faces_indexing;
%             faces_numbers(faces_numbers<0)=[];% remove faces of the lower regions
            if (~isempty(faces_numbers))
                region_specular_frames=[region_specular_frames;frames_with_specularities(i,1)];
                mesh.specularities_in_frame(frames_with_specularities(i,1)).faces_numbers=faces_numbers+1;
                if (length(faces_numbers)>max_num_specular_faces)
                    max_num_specular_faces=length(faces_numbers);
                end
            end
            %                 end
        end
        %         end
    end
    
catch
end
%%  the next condition is to work after finding all hitted faces.
% its function is : for all images that contain any of hitted faces, color
% the hitted face as white. then we will save these images, then we will
% compare it with the annotated images, and save the differences(the  
% differences should be like a face annotated in one image and not in the 
%other and so on). then we will find the faces corresponding to these
%differences and create images with these faces only and remove it by
%subtracting from annotations or similar operation.
if(project_annotated_faces_to_image_again)
    all_annotated_faces_numbers=find(global_hitted_faces);
    try
        frames_with_specularities=specular_pixels(:,1);
        for i=1:size(frames_with_specularities,1)
            frame_number= sprintf( '%06d', frames_with_specularities(i,1)) ;
            file_path=[folder_path,'/frame/','frame-',frame_number,'.color.jpg'];
            
            if(write_flag==1)
                image=imread(file_path);
                imwrite(image,[folder_path,'/regions/region',num2str(region_number),'/frame-',frame_number,'.color.jpg']);
            else
                %                 specular_image=imread([folder_path,'/regions/region',num2str(region_number),'/masks/frame-',frame_number,'.color_m.jpg']);
                %                 if(sum(sum(specular_image))==0)
                %                     continue
                %                 else
                
                file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
                projected_ann_path=[folder_path,'/projected_annotations/','frame-',frame_number,'.color.png'];
                try
                    aa=imread(projected_ann_path);
                catch
%                     [faces_image,~,trans]=imread(file_path);
%                     r=faces_image(:,:,1);
%                     g=faces_image(:,:,2);
%                     b=faces_image(:,:,3);
%                     A=double([trans(:),r(:),g(:),b(:)]);
%                     faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
                      faces_numbers=temp_faces_array(:,i);
                      %% here I want to remove the faces which is not facing to the camera.
                      current_pose_cam_pos=mesh.campos(frames_with_specularities(i,1)+1,:);
                      current_pose_cam_dir=mesh.camdir(frames_with_specularities(i,1)+1,:);
                      positive_faces=faces_numbers>=0;
                      faces_numbers(~positive_faces)=0;
                      faces_numbers=faces_numbers+1;
                      ind22 = ~isFacing(current_pose_cam_pos, current_pose_cam_dir, mesh.centroids(faces_numbers, :), mesh.normals(faces_numbers, :));
                      ind22(~positive_faces)=true;
                      % and remove them since they do not face each other
%         faces_numbers(ind22) = [];
                      
                      %%
                    like_faces_array=logical(zeros([length(faces_numbers) 1]));
                    for j=1:length(all_annotated_faces_numbers)
                        current_face=all_annotated_faces_numbers(j);
                        like_faces_array(faces_numbers==current_face)=true;
                        
                    end
                    like_faces_array(~positive_faces)=false;
                    like_faces_array(ind22)=false;
                    generated_mask=reshape(like_faces_array,[size(faces_image,1) size(faces_image,2)]);
                    imwrite(generated_mask,projected_ann_path);
                    %                 end
                end
            end
            %         end
        end
        
    catch
    end
end
mesh.region_specular_frames=region_specular_frames;
mesh.max_num_specular_faces=max_num_specular_faces;
d=[];