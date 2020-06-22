function shoot_rays_to_specularities(cadModel,size_n,drays,normals,centroids,scene_name,region_number,faces,vertices,t)
global smooth;
number_of_rays=5000;
 [~,Xr,Yr,~,~]=isocell_distribution(number_of_rays, 3, 0);
    
    % define rays in the 3D space, on the unit sphere
    drays = [Xr; Yr; sqrt(1-Xr.^2-Yr.^2)];
    if size(drays,1)<size(drays,2)
        drays = drays';
    end
region_specular_frames=cadModel.region_specular_frames+1;
hit_light_faces_count_array=zeros([size_n,1]);
angled_rays=drays(1:5000,:);

for index=1:size(region_specular_frames)

    frame=region_specular_frames(index);
    current_pose_spec_faces=cadModel.specularities_in_frame(frame-1);
    current_pose_spec_faces=current_pose_spec_faces.faces_numbers;
    current_pose_direction=cadModel.camdir(frame,:);
    current_pose_position=cadModel.campos(frame,:);
    rays_from_spec_faces_to_cam(index).frame=frame;
    rays_from_spec_faces_to_cam(index).rays=current_pose_position-centroids(current_pose_spec_faces,:);
    
    faces_vertices=faces(current_pose_spec_faces,:);
    vertices_normals=normals(current_pose_spec_faces,:);
    vertices_normals=[vertices_normals,vertices_normals,vertices_normals];
    faces_vertices=vertices((faces_vertices(:)),:);
    faces_vertices_normal=[vertices_normals(:,1:3);vertices_normals(:,4:6);vertices_normals(:,7:9)];
    
    
    
    required_normals=normals(current_pose_spec_faces,:);
    required_centroids=centroids(current_pose_spec_faces,:);
    % the next three lines to add the faces vertices alongside with center, if you commented them
    % it will use only center
    %     rays_from_spec_faces_to_cam(index).rays=[rays_from_spec_faces_to_cam(index).rays;current_pose_position-faces_vertices];
    %     required_normals=[required_normals;faces_vertices_normal];
    %     required_centroids=[required_centroids;faces_vertices];
    
    for ray_index=1:size(rays_from_spec_faces_to_cam(index).rays,1)
        %         ray_index
        current_ray=rays_from_spec_faces_to_cam(index).rays(ray_index,:);
        current_spec_face_normal=required_normals(ray_index,:);
        r = vrrotvec(current_spec_face_normal,current_ray); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
        r(4)=2*r(4);% here we want to increase the angle twice to give the effect of mirror on the normal
        M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
        mirrored_ray = current_ray*M; % coincident rays to the normal vector of the origin point (centroid) of face
        r = vrrotvec(mirrored_ray,[0 0 1]); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
        M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
        angled_rays_rotated = angled_rays*M;
        
        
        temp_index=ones([size(angled_rays_rotated,1),1])*ray_index;
        [hit,tt,idxx,bary,xnodee] = t.intersect(required_centroids(temp_index,:)',angled_rays_rotated');
        intersections=idxx;
        %         intersections = unique(idxx); % find which faces are hit from the rays
        %         mirrored_ray(intersections==0,:)=[]
        intersections(intersections==0)=[];
        
        %         mirrored_ray(isnan(intersections) | isinf(intersections),:) = [];
        intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
        if ~isempty(intersections)
            hit_light_faces_count_array(intersections)=hit_light_faces_count_array(intersections)+1;
            %             % HERE we can hit a the second pass from the second hitted face
            %             % toward the third
            %             current_ray=-1*mirrored_ray;
            %             current_spec_face_normal=normals(intersections,:);
            %             r = vrrotvec(current_spec_face_normal,current_ray); % Calculate rotation between two vectors, first vector is the normal of the facet and second vector is normal of the isocel which is always [0 0 1] by default
            %             r(4)=2*r(4);% here we want to increase the angle twice to give the effect of mirror on the normal
            %             M = vrrotvec2mat(r); % Convert rotation from axis-angle to matrix representation
            %             mirrored_ray = current_ray*M; % coincident rays to the normal vector of the origin point (centroid) of face
            %             [hit,tt,idxx,bary,xnodee] = t.intersect(required_centroids',mirrored_ray');
            %             intersections=idxx;
            %             intersections(intersections==0)=[];
            %
            % %         mirrored_ray(isnan(intersections) | isinf(intersections),:) = [];
            %             intersections(isnan(intersections) | isinf(intersections)) = []; % remove indices of non intersected rays
            %             if ~isempty(intersections)
            % %              hit_light_faces_count_array(intersections)=hit_light_faces_count_array(intersections)+1;
            %             end
        end
    end
end
figure, plot_CAD(faces, vertices, '', hit_light_faces_count_array);
delete(findall(gcf,'Type','light'));
if (smooth)
    savefig(['region',num2str(region_number),'scene',scene_name,'smoothed.fig']);
else
    savefig(['region',num2str(region_number),'scene',scene_name,'.fig']);
end
d=[];
