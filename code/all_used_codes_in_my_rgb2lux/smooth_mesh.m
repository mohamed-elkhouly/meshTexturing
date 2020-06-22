function [vertices,faces]=smooth_mesh(region_number,v, f,n,c)
fv.vertices=v;
fv.faces=f;
fv.normals=n;
fv.centroids=c;
region_name=['region',num2str(region_number),'.mat'];
try
    load(['prepared',region_name]);
catch
%     load(region_name)
%     fv.vertices=double(dahy{1});
%     fv.faces=cell2mat(dahy{4})+1;
%     fv.normals = meshFaceNormals(fv.vertices, fv.faces);
%     fv.centroids = meshFaceCentroids(fv.vertices, fv.faces);
    index=1:size(fv.faces,1);
    fv.v1=fv.vertices(fv.faces(index,1),:);
    fv.v2=fv.vertices(fv.faces(index,2),:);
    fv.v3=fv.vertices(fv.faces(index,3),:);
    unique_faces=unique(fv.faces);
    vertex_index_in_faces=zeros([size(fv.vertices,1) 20]);
    vertex_faces=zeros([size(fv.vertices,1) 20]);
    for i=1:size(fv.vertices,1)
        [temp_faces,temp_ver_index]=find(fv.faces==unique_faces(i));
        vertex_index_in_faces(i,1:length(temp_ver_index))=temp_ver_index;
        vertex_faces(i,1:length(temp_faces))=temp_faces;
    end
    save(['prepared',region_name]);
    load(['prepared',region_name]);
end

% figure, plot_CAD(fv.faces, fv.vertices, '');

num_iterations=3;
for iteration=1:num_iterations
    tic
    level=3;
    for i=1:length(fv.faces)
        current_face_vertices=fv.faces(i,:);
        [faces_of_current_vertex1,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(1),level);
        [faces_of_current_vertex2,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(2),level);
        [faces_of_current_vertex3,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(3),level);
        %     faces_of_vertices=vertex_faces(current_face_vertices,:);
        %     faces_of_vertices=unique(faces_of_vertices(faces_of_vertices~=0));
        faces_of_vertices=unique([faces_of_current_vertex1;faces_of_current_vertex2;faces_of_current_vertex3]);
        vertices_of_neighborhood_faces=fv.faces(faces_of_vertices,:);
        vertices_of_neighborhood_faces=unique(vertices_of_neighborhood_faces(:));
        coords_of_vertices_of_neighborhood_faces=fv.vertices(vertices_of_neighborhood_faces,:);
        [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
        current_face_vertices_coords=[fv.vertices(current_face_vertices(1),:);fv.vertices(current_face_vertices(2),:);fv.vertices(current_face_vertices(3),:)];
        projected_points =projection_of_points_on_a_plane(current_face_vertices_coords,plane_center,normal);
        fv.v1(i,:)=projected_points(1,:);
        fv.v2(i,:)=projected_points(2,:);
        fv.v3(i,:)=projected_points(3,:);
    end
    toc
    level=1;
    tic
    for i=1:size(fv.vertices,1)
        [faces_of_current_vertex,which_vertex_in_face]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,i,level);
        vertex_sum=[];
        for j=1:length(faces_of_current_vertex)
            if which_vertex_in_face(j)==1
                current_vertex_coord=fv.v1(faces_of_current_vertex(j),:);
            elseif which_vertex_in_face(j)==2
                current_vertex_coord=fv.v2(faces_of_current_vertex(j),:);
            elseif which_vertex_in_face(j)==3
                current_vertex_coord=fv.v3(faces_of_current_vertex(j),:);
            end
            vertex_sum=sum([vertex_sum;current_vertex_coord],1);
        end
        vertex_sum=vertex_sum/length(faces_of_current_vertex);
        fv.vertices(i,:)=vertex_sum;
    end
    toc
    
    faces=fv.faces;
    vertices=fv.vertices;
%     figure, plot_CAD(fv.faces, fv.vertices, '');
end
d=[];