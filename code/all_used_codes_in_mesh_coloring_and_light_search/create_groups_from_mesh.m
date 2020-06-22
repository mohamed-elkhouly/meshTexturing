function fSets=create_groups_from_mesh(mesh,tempmesh_faces,detected_edge_faces_using_images2)
tic
fullpatch.vertices=mesh.v;
fullpatch.faces=mesh.f;
[~,fSets] = splitFV(fullpatch);

% I want to use the original mesh structure to add the removed edge faces
% to the groups by finding the nearest vertices to them from the current
% groups . note that not all removed faces were directly connected, some of
% them are directly connected, and the others are connected to edge faces
% like them which was removed also.
% at first I will index the faces vertices for speed, the 20 refer to the
% max number of faces could be connect to the same vertex (I assumed)
% I will also exclude the last vertex in the vertices as I added it earlier
% to remove face, and it is a dummy vertex (its index will be num_of_vertices).


% while(1)
% verts_to_faces=zeros(size(mesh.v,1),200);
% num_of_vertices=size(mesh.v,1);
% size_of_verts_to_faces=size(verts_to_faces);
% for i=1:size(mesh.f,1)
%     current_face_vertices_indexes=mesh.f(i,:);
%     current_face_vertices_indexes(current_face_vertices_indexes==num_of_vertices)=[];
%     columns_to_put_in=verts_to_faces(current_face_vertices_indexes(:),1)+2;
%     indexes_to_put_in=sub2ind(size_of_verts_to_faces,current_face_vertices_indexes(:),columns_to_put_in(:));
%     verts_to_faces(indexes_to_put_in)=i;
%     verts_to_faces(current_face_vertices_indexes(:),1)=verts_to_faces(current_face_vertices_indexes(:),1)+1;
% end
% % remove the counter column
% verts_to_faces(:,1)=[];
%     edges_faces_indices=find(detected_edge_faces_using_images2);
%     old_num_of_not_assigned_faces=length(edges_faces_indices);
%     detected_edge_faces_using_images2(:)=0;
%     assigned_groups_for_edge_faces=zeros(size(edges_faces_indices));
%     for i =1:length(edges_faces_indices)
%         current_face_vertices=tempmesh_faces(edges_faces_indices(i),:);
%         founded_indices_for_faces_with_connected_borders=verts_to_faces(current_face_vertices(:),:);
%         founded_indices_for_faces_with_connected_borders=founded_indices_for_faces_with_connected_borders(:);
%         founded_indices_for_faces_with_connected_borders(founded_indices_for_faces_with_connected_borders==0)=[];
%         assigned_groups_for_edge_faces(i)=mode(fSets(founded_indices_for_faces_with_connected_borders));
%     end
%     detected_edge_faces_using_images2(edges_faces_indices(assigned_groups_for_edge_faces==0))=1;
%     % remove the indices of the edge faces which we couldn't assign yet
%     edges_faces_indices(assigned_groups_for_edge_faces==0)=[];
%     assigned_groups_for_edge_faces(assigned_groups_for_edge_faces==0)=[];
%     fSets(edges_faces_indices)=assigned_groups_for_edge_faces;
%     mesh.f(edges_faces_indices,:)=tempmesh_faces(edges_faces_indices,:);
%     if(sum(detected_edge_faces_using_images2)==old_num_of_not_assigned_faces)
%         break;
%     end
% end
% time_to_create_groups=toc
% end
