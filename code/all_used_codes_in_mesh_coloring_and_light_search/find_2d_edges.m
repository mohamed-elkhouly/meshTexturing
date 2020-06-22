function mesh=find_2d_edges(mesh,region_frames,scene_name,image_height,image_width,t)

mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.appeared_faces_in_all_projections=false([size(mesh.f,1) 1]);
tic
for fff=1:length(region_frames)
    i=region_frames(fff);
%     if(mesh_different_from_matterport)
        image_name2=sprintf('frame-%06d.color.png',i);
%     else
        image_name=sprintf('frame-%06d.color.jpg',i);
%     end
    
    image_path=[scene_name,'/frame/',image_name];
    image_path2=[scene_name,'/frame/',image_name2];
    %%
    try
    image=imread(image_path);
    catch
        image=imread(image_path2);
    end
    M_max=max(image,[],3);
    %         figure;subplot(1,2,1),imshow(M_max);
    M1 = imbilatfilt(M_max);
    %         subplot(1,2,2),imshow(M1);
    
    [GmagY, ~] = imgradient(M1,'roberts');
    %         imwrite([M_max,M1,uint8(255*(uint8(GmagY)>10))],['filtering_results/',image_name]);
    merged_borders=uint8(GmagY)>5;
    merged_borders(:,[1:5,end-4:end])=0;
    merged_borders([1:5,end-4:end],:)=0;
    %         imwrite([merged_borders],['output_figures/',image_name]);
    
    hitted_mesh_pixels=[];
    [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(merged_borders));
    [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
    temp_index=ones([size(rays_directions,2),1])*i+1;
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
    hitted_faces=unique(idxx);
    hitted_faces(hitted_faces==0)=[];
    ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces, :), mesh.normals(hitted_faces, :));
    hitted_faces(ind22)=[];
    distance_to_camera=vecnorm((mesh.centroids(hitted_faces, :)-mesh.campos(i+1, :))',1);
    hitted_faces(distance_to_camera>8)=[];
    mesh.f_lum(hitted_faces)=255;
    
    if(1)% keep track of all projected faces to remove the non visible faces
        hitted_mesh_pixels=[];
        [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
        [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
        temp_index=ones([size(rays_directions,2),1])*i+1;
        [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
        appeared_faces=unique(idxx);
        appeared_faces(appeared_faces==0)=[];
        mesh.appeared_faces_in_all_projections(appeared_faces)=1;
    end
    
end
time_to_find_2d_edges=toc
%     save('meshplus_lum_smoothed.mat');
% end
