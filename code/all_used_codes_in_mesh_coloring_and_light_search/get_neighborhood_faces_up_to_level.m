function [faces_of_current_vertex,which_vertex_in_face]=get_neighborhood_faces_up_to_level(faces,vertex_faces,vertex_index_in_faces,vertex_index,level)

faces_of_current_vertex=vertex_faces(vertex_index,:);
    which_vertex_in_face=vertex_index_in_faces(vertex_index,:);
    faces_of_current_vertex=faces_of_current_vertex(faces_of_current_vertex~=0);
    which_vertex_in_face=which_vertex_in_face(which_vertex_in_face~=0);
    faces_for_loop=faces_of_current_vertex;
        for i=2:level
        required_vertex_index=faces(faces_for_loop(:),:);
        required_vertex_index=unique(required_vertex_index(:));
        faces_of_current_vertex=vertex_faces(required_vertex_index,:);
        faces_for_loop=unique(faces_of_current_vertex(faces_of_current_vertex~=0));
        which_vertex_in_face=vertex_index_in_faces(required_vertex_index,:);
        end
faces_of_current_vertex=faces_of_current_vertex';
faces_of_current_vertex=faces_of_current_vertex(:);

which_vertex_in_face=which_vertex_in_face';
which_vertex_in_face=which_vertex_in_face(:);
which_vertex_in_face(faces_of_current_vertex==0)=[];
faces_of_current_vertex(faces_of_current_vertex==0)=[];
[faces_of_current_vertex,b]=unique(faces_of_current_vertex,'stable');
which_vertex_in_face=which_vertex_in_face(b);
d=[];