function show_annotated_light_sources(show_annotated_light_sources_flag,size_n,cadModel,centroids,normals,scene_name,region_number,faces,vertices)
% show_annotated_light_sources_flag=1;
show_auto_detected_light_sources_from_my_method_flag=0;
% show_as_a_heat_map=1;
if (show_annotated_light_sources_flag || show_auto_detected_light_sources_from_my_method_flag)
%% these next few lines is just for viewing the annotated light sources on the 3d mesh. to use it you have to uncomment the line which is : specular_pixels=[sunlight_pixels;artificial_pixels;skylight_pixels]; 
% in the get_specular_faces file. then you should comment it again directly
% because it will mess the work totally.
hit_light_faces_count_array=zeros([size_n,1]);
hit_light_faces_count_array2=zeros([size_n,1]);
region_specular_frames=cadModel.region_specular_frames+1;
for index=1:size(region_specular_frames)
    frame=region_specular_frames(index);
    current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
    current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
    current_pose_cam_pos=cadModel.campos(frame-1,:);
    current_pose_cam_dir=cadModel.camdir(frame-1,:);
    if ~isempty(current_pose_spec_faces)
        % extract only indices of faces with parallel normals
%         ind22 = ~isFacing(current_pose_cam_pos, current_pose_cam_dir, centroids(current_pose_spec_faces, :), normals(current_pose_spec_faces, :));        
%         % and remove them since they do not face each other
%         current_pose_spec_faces(ind22) = [];
    end
%     if(show_as_a_heat_map)
    hit_light_faces_count_array(current_pose_spec_faces)=hit_light_faces_count_array(current_pose_spec_faces)+1;
%     else
    hit_light_faces_count_array2(current_pose_spec_faces)=200;
%     end
end
% in this line I am removing these faces which appeared only for one time.
current_date=datestr(datetime('now'));
figure, plot_CAD(faces(1:length(cadModel.f_c),:), vertices, '', hit_light_faces_count_array(1:length(cadModel.f_c),:));
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_plus_mono_viewHM.fig']);
figure, plot_CAD(faces, vertices, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_plus_mono_view_plus_sphere.fig']);
hit_light_faces_count_array(hit_light_faces_count_array==1)=0;
figure, plot_CAD(faces, vertices, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'_HM_GT_light_',scene_name,'_REG_',num2str(region_number),'_minus_mono_view_plus_sphere.fig']);
figure, plot_CAD(faces(1:length(cadModel.f_c),:), vertices, '', hit_light_faces_count_array2(1:length(cadModel.f_c),:));
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'GT_light_',scene_name,'_REG_',num2str(region_number),'.fig']);
figure, plot_CAD(faces, vertices, '', hit_light_faces_count_array2);
delete(findall(gcf,'Type','light'));savefig([current_date(1:11),'GT_light_',scene_name,'_REG_',num2str(region_number),'plus_sphere.fig']);
d=[]; 
end