function mesh=load_mesh_data(ply_name, folder_path, image_height, image_width)
[mesh.v,mesh.f]=read_ply(ply_name);
mesh=read_cam_poses_and_intrinsics(mesh,folder_path);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
t = opcodemesh((mesh.v)',(mesh.f)');
step=1;
mesh.frame_face_mapping(length(mesh.original_frame_number)/step,image_height,image_width)=0;
size_of_image=(image_height*image_width);
[hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],1:size_of_image);
temp_ones=ones([size_of_image,1]);
appeared_faces=false(size(mesh.f,1),1);
for i=1:step:length(mesh.pose)
    [rays_directions,~]=get_ray_direction(mesh.pose(i).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_ones*i,:)',rays_directions);
    temp_var=idxx(idxx~=0);
    ind22 = ~isFacing(mesh.campos(i,:),mesh.camdir(i,:), mesh.centroids(temp_var, :), mesh.normals(temp_var, :));
    temp_var(ind22)=0;
    idxx(idxx~=0)=temp_var;
    temp_var(temp_var==0)=[];
    appeared_faces(temp_var)=1;
    mesh.frame_face_mapping(i,:,:)=reshape(idxx,[image_height image_width]);
end
mesh.appeared_faces=appeared_faces;