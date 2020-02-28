function mesh=loadSceneData(mesh)
scene_name=mesh.scene_name;
ply_name=[scene_name,'.ply'];
data_path=['data/',scene_name,'/'];
mesh.data_path=data_path;
[mesh.v,mesh.f]=read_ply([data_path,ply_name]);
mesh.centroids = getFacesCenters(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
mesh=readPoses_Intrinsics_FrameNumbers(mesh,data_path);
t = opcodemesh((mesh.v)',(mesh.f)');
step=1;
mesh.frame_face_mapping(length(mesh.frame_number),mesh.frame_height,mesh.frame_width)=0;
size_of_image=(mesh.frame_height*mesh.frame_width);
[hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([mesh.frame_height mesh.frame_width],1:size_of_image);
temp_ones=ones([size_of_image,1]);
all_visible_faces=false(size(mesh.f,1),1);
for i=1:step:length(mesh.pose)
    [rays_directions,~]=get_ray_direction(mesh.pose(i).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_ones*i,:)',rays_directions);
    all_visible_faces(idxx(idxx~=0))=1;
    mesh.frame_face_mapping(i,:,:)=reshape(idxx,[mesh.frame_height mesh.frame_width]);
end
mesh.all_visible_faces=all_visible_faces;
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(mesh.all_visible_faces));title('VisibleFaces');delete(findall(gcf,'Type','light'));