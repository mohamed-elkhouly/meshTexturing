function [faces,vertices,num_new_faces,required_edges_vertices,max_face_area]=refine_mesh(faces,vertices,max_face_area,to_be_modified_faces,dividing_factor,required_edges_vertices)


if nargin<5
    dividing_factor=1/2;
end
areas = meshArea(faces,vertices);
if max_face_area==-1
    max_face_area=mean(areas(to_be_modified_faces))*dividing_factor;
end
areas_great_than_max=areas>max_face_area;
kept_faces=faces(~areas_great_than_max,:);
if nargin<4 || ~exist ('to_be_modified_faces')
    total_faces=[];
    to_be_modified_faces=faces(areas_great_than_max,:);
else
    kept_faces=[];
    temp_faces_indexes=zeros([size(faces,1) 1]);
    temp_faces_indexes(to_be_modified_faces)=1;
    total_faces=faces(temp_faces_indexes<1,:);
    faces=faces(to_be_modified_faces,:);
    to_be_modified_faces=faces;
end
if ~exist("required_edges_vertices")
required_edges_vertices=[];
end
    
    required_edges_vertices=required_edges_vertices(:);
%     temp_indexer=zeros([num_faces 1]);
    while(sum(areas_great_than_max)>0)
        temp_logic_faces=to_be_modified_faces>0;
        temp_logic_faces(:,:)=0;
        %     each face will be divided to four faces by getting the middle points
        %     of its edges. then create faces using it.
        [~,E_verts]=intersect(to_be_modified_faces,required_edges_vertices);
        temp_logic_faces(E_verts)=1;
       E_verts_v1v2= (sum(temp_logic_faces(:,[1,2]),2)>1);
       E_verts_v1v3= (sum(temp_logic_faces(:,[1,3]),2)>1);
       E_verts_v2v3= (sum(temp_logic_faces(:,[2,3]),2)>1);

        v1=to_be_modified_faces(:,1);
        v2=to_be_modified_faces(:,2);
        v3=to_be_modified_faces(:,3);
        v1v2_p=(vertices(v1,:)+ vertices(v2,:))/2;
        v1v2_p_indexes=(size(vertices,1)+1):(size(vertices,1))+size(v1v2_p,1);
        v1v3_p=(vertices(v1,:)+ vertices(v3,:))/2;
        v1v3_p_indexes=((size(vertices,1))+size(v1v2_p,1)+1):(size(vertices,1))+2*size(v1v2_p,1);
        v2v3_p=(vertices(v2,:)+ vertices(v3,:))/2;
        v2v3_p_indexes=(((size(vertices,1))+2*size(v1v2_p,1))+1):(size(vertices,1))+3*size(v1v2_p,1);
        % update vertices and faces
        required_edges_vertices=[required_edges_vertices;(size(vertices,1)+find(E_verts_v1v2))...
            ;(size(vertices,1)+size(v1v2_p,1)+find(E_verts_v1v3))...
            ;(size(vertices,1)+size(v1v2_p,1)+size(v1v3_p,1)+find(E_verts_v2v3))...
            ];
        
        vertices=[vertices;v1v2_p;v1v3_p;v2v3_p];
        
        faces=[kept_faces;
            [v1,v1v2_p_indexes',v1v3_p_indexes'];
            [v2,v2v3_p_indexes',v1v2_p_indexes'];
            [v3,v1v3_p_indexes',v2v3_p_indexes'];
            [v1v2_p_indexes',v2v3_p_indexes',v1v3_p_indexes']];
        
        areas = meshArea(faces,vertices);
        areas_great_than_max=areas>max_face_area;
        kept_faces=faces(~areas_great_than_max,:);
        to_be_modified_faces=faces(areas_great_than_max,:);
    end
    num_new_faces=size(faces,1);
    faces=[total_faces;faces];

d=[];

