function mesh=fill_holes_from_frame()
region_name='region15.mat';
try
    load(['prepared',region_name]);
catch
    load(region_name)
    fv.vertices=double(dahy{1});
    fv.faces=cell2mat(dahy{4})+1;
    fv.normals = meshFaceNormals(fv.vertices, fv.faces);
    fv.centroids = meshFaceCentroids(fv.vertices, fv.faces);
    index=1:size(fv.faces,1);
    fv.v1=fv.vertices(fv.faces(index,1),:);
    fv.v2=fv.vertices(fv.faces(index,2),:);
    fv.v3=fv.vertices(fv.faces(index,3),:);
    % fv.fv1=
    sum_val=[];
    unique_faces=unique(fv.faces);
    for i=1:size(fv.vertices,1)
        [temp_faces,temp_ver_index]=find(fv.faces==unique_faces(i));
        vertex_index_in_faces(i,1:length(temp_ver_index))=temp_ver_index;
        vertex_faces(i,1:length(temp_faces))=temp_faces;
        
    end
    save(['prepared',region_name]);
    load(['prepared',region_name]);
end

% figure, plot_CAD(fv.faces, fv.vertices, '');

%% this is the end part for test


[faces_image,~,trans]=imread('../dataset/1LXtFkjw3qL_1/frames_faces_mapping/frame-000143.color.png');
r=faces_image(:,:,1);
g=faces_image(:,:,2);
b=faces_image(:,:,3);
A=double([trans(:),r(:),g(:),b(:)]);
faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
empty_mask=zeros([length(faces_numbers),1]);
empty_mask(faces_numbers>4294967294)=255;
empty_mask=reshape(empty_mask,[1024 1280])>0;
faces_numbers=faces_numbers+1;
faces_numbers(faces_numbers>(4092326-1))=-1;
faces_numbers=faces_numbers-3826755;

se = strel('disk',3);
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
    color_view=zeros([length(fv.faces),1]);
    color_view(boundary_faces)=100;
    figure, plot_CAD(fv.faces, fv.vertices, '',color_view);
    delete(findall(gcf,'Type','light'));
    boundary_vertices=fv.faces(boundary_faces(:),:);
    boundary_vertices=boundary_vertices(:);
    coords_of_vertices_of_neighborhood_faces=fv.vertices(boundary_vertices,:);
    [circle_on_plane_points,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
    projected_points =projection_of_points_on_a_plane(fv.vertices(boundary_vertices,:),plane_center,normal);
    convex_hull_faces =convhull(projected_points(:,1),projected_points(:,2),projected_points(:,3));
% figure;subplot(1,2,1);
% hold on
% trisurf(convex_hull_faces,projected_points(:,1),projected_points(:,2),projected_points(:,3),'Facecolor','cyan');
%     [refined_faces,mesh.v]=refine_mesh(convex_hull_faces,[mesh.v;required_cam_pos],max_face_area);
end

mesh=[];