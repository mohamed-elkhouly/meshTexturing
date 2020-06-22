function project_annotated_faces_to_image(mesh,project_annotated_faces_to_image_again,global_hitted_faces,required_pixels,folder_path,temp_faces_array,image_width,image_height)
%%  this function is to work after finding all hitted faces.
% its function is : for all images that contain any of hitted faces, color
% the hitted face as white. then we will save these images, then we will
% compare it with the annotated images, and save the differences(the  
% differences should be like a face annotated in one image and not in the 
%other and so on). then we will find the faces corresponding to these
%differences and create images with these faces only and remove it by
%subtracting from annotations or similar operation.
if(project_annotated_faces_to_image_again)
    all_annotated_faces_numbers=find(global_hitted_faces);
        frames_with_specularities=required_pixels(:,1);
        for i=1:size(frames_with_specularities,1)
            frame_number= sprintf( '%06d', frames_with_specularities(i,1)) ;
                projected_ann_path=[folder_path,'/projected_annotations/','frame-',frame_number,'.color.png'];
                try
                    aa=imread(projected_ann_path);
                catch
                      faces_numbers=temp_faces_array(:,i);
                      %% here I want to remove the faces which is not facing to the camera.
                      current_pose_cam_pos=mesh.campos(frames_with_specularities(i,1)+1,:);
                      current_pose_cam_dir=mesh.camdir(frames_with_specularities(i,1)+1,:);
                      positive_faces=faces_numbers>0;
                      faces_numbers(~positive_faces)=1;
%                       ind22 = ~isFacing(current_pose_cam_pos, current_pose_cam_dir, mesh.centroids(faces_numbers, :), mesh.normals(faces_numbers, :));
%                       ind22(~positive_faces)=true;
                      %%
                    like_faces_array=logical(zeros([1 length(faces_numbers)]));
                    [elements_vals,idx] = intersect(faces_numbers,all_annotated_faces_numbers,'stable');
                    required_indexes=get_elements_indexes_from_array(faces_numbers',elements_vals);
                    like_faces_array(required_indexes)=true;
%                     for j=1:length(all_annotated_faces_numbers)
%                         current_face=all_annotated_faces_numbers(j);
%                         like_faces_array(faces_numbers==current_face)=true;
%                     end
                    like_faces_array(~positive_faces)=false;
%                     like_faces_array(ind22)=false;
                    generated_mask=reshape(like_faces_array,[image_height, image_width]);
                    imwrite(generated_mask,projected_ann_path);
                end
            
        end

end