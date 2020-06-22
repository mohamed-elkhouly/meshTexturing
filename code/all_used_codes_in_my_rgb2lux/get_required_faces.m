function [mesh,global_hitted_faces,region_specular_frames,max_num_specular_faces,temp_faces_array]=get_required_faces(mesh,required_pixels,folder_path,write_flag,region_number,end_of_faces_indexing,start_of_faces_indexing,image_width,image_height,project_annotated_faces_to_image_again)
global_hitted_faces=[];
max_num_specular_faces=0;
region_specular_frames=[];
frames_with_specularities=required_pixels(:,1);
t = opcodemesh(mesh.v',mesh.f');
    for i=1:size(frames_with_specularities,1)
        frame_number= sprintf( '%06d', frames_with_specularities(i,1)) ;
        file_path=[folder_path,'/frame/','frame-',frame_number,'.color.jpg'];
        
        if(write_flag==1)
            image=imread(file_path);
            imwrite(image,[folder_path,'/regions/region',num2str(region_number),'/frame-',frame_number,'.color.jpg']);
        else
            file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
            [faces_image,~,trans]=imread(file_path);
            r=faces_image(:,:,1);
            g=faces_image(:,:,2);
            b=faces_image(:,:,3);
            A=double([trans(:),r(:),g(:),b(:)]);
            faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
            faces_numbers=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
            missing_mesh_pixels=[];
            missing_mesh_indexes=find(faces_numbers>4294967294);
            
            
            if(~isempty(missing_mesh_indexes))
            [missing_mesh_pixels(2,:), missing_mesh_pixels(1,:)]=ind2sub([image_height image_width],missing_mesh_indexes);
            [rays_directions,~]=get_ray_direction(mesh.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh.intrinsics,missing_mesh_pixels);
            %% to be removed after this test
%             t = opcodemesh(mesh.v',mesh.f');
%             req_vertices=mesh.f(faces_numbers([1 1024 ])-start_of_faces_indexing,:)';
%             req_vertices=req_vertices(:);
%             req_vertices=mesh.v(req_vertices,:);
%             [rays_directions,~]=get_ray_direction2(mesh.pose(frames_with_specularities(i,1)+1).pose_matrix,mesh.intrinsics,[1 1 1024 1024;1 1280 1 1280],faces_numbers([1,1309697,1024,1310720]),t,start_of_faces_indexing,req_vertices);
            
            %%
            temp_index=ones([size(rays_directions,2),1])*frames_with_specularities(i,1)+1;
            
            [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
            faces_numbers(missing_mesh_indexes)=idxx;
%             to_be_removed_faces(missing_mesh_indexes)=0;
            end
            temp_index_to_subtract_lower_limit=1:length(faces_numbers);
            [elements_vals,idx] = intersect(temp_index_to_subtract_lower_limit,missing_mesh_indexes,'stable');% we remove the missing mesh indexes from all indexes.
%             required_indexes=get_elements_indexes_from_array(temp_index_to_subtract_lower_limit,elements_vals);%
%             no use for the last line as the search array has unique
%             values;
            temp_index_to_subtract_lower_limit(idx)=[];
            
            upper_limit_faces_flag=faces_numbers>end_of_faces_indexing;
             temp_index_to_remove_upper_limit=1:length(faces_numbers);
            temp_index_to_remove_upper_limit=temp_index_to_remove_upper_limit(upper_limit_faces_flag);
            [elements_vals,idx] = intersect(temp_index_to_remove_upper_limit,missing_mesh_indexes,'stable');
%             required_indexes=get_elements_indexes_from_array(temp_index_to_remove_upper_limit,elements_vals);
%             no use for the last line as the search array has unique
%             values;
            temp_index_to_remove_upper_limit(idx)=[];

            non_zero_required_pixels=required_pixels(i,2:end);% get the required pixels in this frame (which the frame number is required_pixels(i,1)+1)
            non_zero_required_pixels(non_zero_required_pixels==0)=[];
            hitted_faces=faces_numbers(non_zero_required_pixels);
            hitted_faces=unique(hitted_faces);
            hitted_faces=hitted_faces(hitted_faces>0);
            if(project_annotated_faces_to_image_again)
                global_hitted_faces(hitted_faces)=1;
            end
            temp_faces_array(:,i)=faces_numbers;
            faces_numbers(temp_index_to_subtract_lower_limit)=faces_numbers(temp_index_to_subtract_lower_limit)-start_of_faces_indexing;% here we but all faces down from this region to <=0;
            faces_numbers(temp_index_to_remove_upper_limit)=-1;% we are putting the faces which is from the higher regions to -1 to be removed later also.
            
            
            non_zero_required_pixels=required_pixels(i,2:end);% get the required pixels in this frame (which the frame number is required_pixels(i,1)+1)
            non_zero_required_pixels(non_zero_required_pixels==0)=[];
            hitted_faces=faces_numbers(non_zero_required_pixels);
            hitted_faces=unique(hitted_faces);
            hitted_faces=hitted_faces(hitted_faces>0);
 
            if (~isempty(hitted_faces))
                region_specular_frames=[region_specular_frames;frames_with_specularities(i,1)+1];
                mesh.specularities_in_frame(frames_with_specularities(i,1)+1).faces_numbers=hitted_faces;
                if (length(hitted_faces)>max_num_specular_faces)
                    max_num_specular_faces=length(hitted_faces);
                end
            end
        end
    end