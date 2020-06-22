function [mesh_vertices,mesh_faces]=smooth_mesh_v_0_2(region_number,mesh_vertices, mesh_faces,mesh_normals,mesh_centroids)
% mesh_vertices=mesh_vertices;
% mesh_faces=mesh_faces;
mesh_normals=mesh_normals;
mesh_centroids=mesh_centroids;
new_vertices=mesh_vertices;
region_name=['region',num2str(region_number),'.mat'];
try
    delete(['prepared',region_name]);
    load(['prepared',region_name]);
catch
%     load(region_name)
%     mesh_vertices=double(dahy{1});
%     mesh_faces=cell2mat(dahy{4})+1;
%     fv.normals = meshFaceNormals(mesh_vertices, mesh_faces);
%     fv.centroids = meshFaceCentroids(mesh_vertices, mesh_faces);
    index=1:size(mesh_faces,1);
    v1=mesh_vertices(mesh_faces(index,1),:);
    v2=mesh_vertices(mesh_faces(index,2),:);
    v3=mesh_vertices(mesh_faces(index,3),:);
    unique_faces=unique(mesh_faces);
    vertex_index_in_faces=zeros([size(mesh_vertices,1) 20]);
    vertex_faces=zeros([size(mesh_vertices,1) 20]);
    for i=1:size(mesh_vertices,1)
        [temp_faces,temp_ver_index]=find(mesh_faces==unique_faces(i));
        vertex_index_in_faces(i,1:length(temp_ver_index))=temp_ver_index;
        vertex_faces(i,1:length(temp_faces))=temp_faces;
    end
    save(['prepared',region_name]);
    load(['prepared',region_name]);
end

% figure, plot_CAD(mesh_faces, mesh_vertices, '');

num_iterations=3;
 level=1;
for iteration=1:num_iterations
    tic
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    parfor i=1:size(mesh_vertices,1)
        faces_attached_to_current_vertex=vertex_faces(i,:);
        faces_attached_to_current_vertex(faces_attached_to_current_vertex==0)=[];
%         if(length(faces_attached_to_current_vertex)<2)
%             continue;
%         end
% %         for j=1:length(faces_attached_to_current_vertex)
%              result=vrrotvec_multiple(mesh_normals(faces_attached_to_current_vertex(1),:), mesh_normals(faces_attached_to_current_vertex(2:end),:));
%              result=result(:,4);
%              if sum(result>0.785&result<2.355)>0
%                 continue;
%              end
% %         end
        vertices_of_neighborhood_faces=mesh_faces(faces_attached_to_current_vertex,:);
        vertices_of_neighborhood_faces=unique(vertices_of_neighborhood_faces(:));
        final_faces_of_current_vertex=zeros([length(vertices_of_neighborhood_faces) 50]);
        for ind=1:length(vertices_of_neighborhood_faces)
             [faces_of_current_vertex,~]=get_neighborhood_faces_up_to_level(mesh_faces,vertex_faces,vertex_index_in_faces,vertices_of_neighborhood_faces(ind),level);
             final_faces_of_current_vertex(ind,1:length(faces_of_current_vertex))=faces_of_current_vertex;
        end

        faces_of_vertices=unique(final_faces_of_current_vertex(:));
        faces_of_vertices(faces_of_vertices==0)=[];
        
        
        if(length(faces_of_vertices)<2)
            continue;
        end
             result=vrrotvec_multiple(mesh_normals(faces_of_vertices(1),:), mesh_normals(faces_of_vertices(2:end),:));
             result=result(:,4);
             if sum(result>0.785&result<2.355)>0
                continue;
             end

        
        vertices_of_neighborhood_faces=mesh_faces(faces_of_vertices,:);
        vertices_of_neighborhood_faces=unique(vertices_of_neighborhood_faces(:));
        coords_of_vertices_of_neighborhood_faces=mesh_vertices(vertices_of_neighborhood_faces,:);
        [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
        current_vertex_coords=mesh_vertices(i,:);
        new_vertices(i,:) =projection_of_points_on_a_plane(current_vertex_coords,plane_center,normal);
    end
    mesh_vertices=new_vertices;
     figure, plot_CAD(mesh_faces, mesh_vertices, '');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     for i=1:length(mesh_faces)
%         current_face_vertices=mesh_faces(i,:);
%         [faces_of_current_vertex1,~]=get_neighborhood_faces_up_to_level(mesh_faces,vertex_faces,vertex_index_in_faces,current_face_vertices(1),level);
%         [faces_of_current_vertex2,~]=get_neighborhood_faces_up_to_level(mesh_faces,vertex_faces,vertex_index_in_faces,current_face_vertices(2),level);
%         [faces_of_current_vertex3,~]=get_neighborhood_faces_up_to_level(mesh_faces,vertex_faces,vertex_index_in_faces,current_face_vertices(3),level);
%         %     faces_of_vertices=vertex_faces(current_face_vertices,:);
%         %     faces_of_vertices=unique(faces_of_vertices(faces_of_vertices~=0));
%         faces_of_vertices=unique([faces_of_current_vertex1;faces_of_current_vertex2;faces_of_current_vertex3]);
%         vertices_of_neighborhood_faces=mesh_faces(faces_of_vertices,:);
%         vertices_of_neighborhood_faces=unique(vertices_of_neighborhood_faces(:));
%         coords_of_vertices_of_neighborhood_faces=mesh_vertices(vertices_of_neighborhood_faces,:);
%         [~,normal,plane_center]=fit_3d_plane_to_points(coords_of_vertices_of_neighborhood_faces,0);
%         current_face_vertices_coords=[mesh_vertices(current_face_vertices(1),:);mesh_vertices(current_face_vertices(2),:);mesh_vertices(current_face_vertices(3),:)];
%         projected_points =projection_of_points_on_a_plane(current_face_vertices_coords,plane_center,normal);
%         v1(i,:)=projected_points(1,:);
%         v2(i,:)=projected_points(2,:);
%         v3(i,:)=projected_points(3,:);
%     end
%     toc
%     level=1;
%     tic
%     for i=1:size(mesh_vertices,1)
%         [faces_of_current_vertex,which_vertex_in_face]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,i,level);
%         vertex_sum=[];
%         for j=1:length(faces_of_current_vertex)
%             if which_vertex_in_face(j)==1
%                 current_vertex_coord=v1(faces_of_current_vertex(j),:);
%             elseif which_vertex_in_face(j)==2
%                 current_vertex_coord=v2(faces_of_current_vertex(j),:);
%             elseif which_vertex_in_face(j)==3
%                 current_vertex_coord=v3(faces_of_current_vertex(j),:);
%             end
%             vertex_sum=sum([vertex_sum;current_vertex_coord],1);
%         end
%         vertex_sum=vertex_sum/length(faces_of_current_vertex);
%         mesh_vertices(i,:)=vertex_sum;
%     end
%     toc
%     
%     faces=mesh_faces;
%     vertices=mesh_vertices;
%     figure, plot_CAD(mesh_faces, mesh_vertices, '');
end
d=[];