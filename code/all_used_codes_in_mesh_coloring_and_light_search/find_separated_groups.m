function [fSets2,faces_on_border]=find_separated_groups(luminance,mesh)

faces_indexes=(1:size(mesh.f,1))';
v1v2=[sort(mesh.f(:,1:2),2),faces_indexes];
v1v3=[sort(mesh.f(:,[1,3]),2),faces_indexes];
v2v3=[sort(mesh.f(:,[2,3]),2),faces_indexes];
all_edges=[v1v2;v1v3;v2v3];
% all_edges contain each edge in the mesh and its corresponding face
% attached to it, this mean that each edge may have either one or two
% faces. but we sorted the order of the v=edge vertices to make the edge
% which share e.g. vertex a and vertex b and will appear as (ab and ba) we
% sorted it to be sure that it will be only on one form (ab and ab) then we
% will get the uniques values of these edges, then we will fill the array
% faces_on_the_same_edge by the faces connected to each edge in a separate
% rows.
[unique_edges,~,indb]=unique(all_edges(:,1:2),'rows');
faces_on_the_same_edge=zeros(size(unique_edges,1),3);
faces_indexes_of_all_edges=all_edges(:,3);
for i=1:length(indb)
    faces_on_the_same_edge(indb(i), faces_on_the_same_edge(indb(i),1)+2)=faces_indexes_of_all_edges(i);
    faces_on_the_same_edge(indb(i),1)=faces_on_the_same_edge(indb(i),1)+1;
end
faces_on_the_same_edge(:,1)=[];
% here in the next line we if for edge ab two faces were connected to it (1,2),
% so we will have the the values (1,2) assigned to it in
% faces_on_the_same_edge variable, we want to have [12] and also [21]; I
% mean all possible cases.
faces_on_the_same_edge=[faces_on_the_same_edge;[faces_on_the_same_edge(:,2),faces_on_the_same_edge(:,1)]];
faces_on_face_edges=zeros(size(mesh.f,1),4);% in this array we will store all of faces attached to each face
for i=1:size(faces_on_the_same_edge,1)
    if(sum(faces_on_the_same_edge(i,:)==0)==0)% if (there are two faces in this row)
     faces_on_face_edges(faces_on_the_same_edge(i,1), faces_on_face_edges(faces_on_the_same_edge(i,1),1)+2)=faces_on_the_same_edge(i,2);% store the second face in the row of the first face
    faces_on_face_edges(faces_on_the_same_edge(i,1),1)=faces_on_face_edges(faces_on_the_same_edge(i,1),1)+1;
    end
end
% in the faces_on_face_edges each face has its own row, stored on it the
% faces connected to its edges.
faces_on_face_edges(:,1)=[];
faces_on_edge_luminance=faces_on_face_edges; % this line is to create a new array for luminance with the same size of  faces_on_face_edges.
faces_on_edge_luminance(faces_on_face_edges(:)~=0)=luminance(faces_on_face_edges(faces_on_face_edges(:)~=0)); % copy the luminance of each face to the array
faces_on_edge_luminance=abs(faces_on_edge_luminance-double(luminance));% subtract the luminance of the face corresponding to each row.
faces_on_edge_luminance(faces_on_face_edges(:)==0)=0;% put the value of the difference for those faces which was 0 by 0 value, mean these are not originally faces, so remove them.
max_faces=max(faces_on_edge_luminance,[],2);% get the maximum difference attached to that face.
faces_on_border=zeros(size(mesh.f,1),1);
lambda=6;% this value will be used to control the difference between faces luminance, if the luminance difference exceed this value, ...
%it will be considered as edge.(because we will consider it as a not smooth transition)
faces_on_border(max_faces>mean(max_faces(max_faces>0))/lambda)=255;% this flag contain the faces which will be considered as on border.
% figure,plot_CAD(mesh.f, mesh.v, '',faces_on_border);
% delete(findall(gcf,'Type','light'));
faces_on_edge2=faces_on_face_edges;
faces_on_edge2(faces_on_border>0,:)=0; % remove the border faces from faces_on_edge2 variable to find the regions between them.
faces_on_edge2(luminance==0,:)=0; % remove the faces which has not seen from any view, in this special case, their values are zero, but in other cases it should be changed to non visible faces.


fSets={};
length_of_cells_in_fSets=[];
flag_faces_used=false(size(mesh.f,1),1);
ind=1;
while(1)
    if(sum(faces_on_edge2(:))==0)
        break;
    end
    current_index=find(sum(faces_on_edge2,2)>0,1);
    new_indexes=(faces_on_edge2(current_index,:))';
    faces_on_edge2(current_index,:)=0;
    new_indexes=new_indexes(:);
    new_indexes(new_indexes==0)=[];
    current_set=[current_index;new_indexes];
    while(1)
        if(isempty(new_indexes))
            break;
        end
        new_indexes(flag_faces_used(new_indexes))=[];
        flag_faces_used(new_indexes)=1;
        temp_indexes=new_indexes;
         new_indexes=(faces_on_edge2(new_indexes,:))';
         faces_on_edge2(temp_indexes,:)=0;
         new_indexes=unique(new_indexes(:));
         new_indexes(new_indexes==0)=[];
        current_set=unique([current_set;new_indexes]);
    end
    fSets(ind,1)={current_set};
    length_of_cells_in_fSets(ind,1)=length(current_set);
    ind=ind+1;
end
[length_of_cells_in_fSets,Sind]=sort(length_of_cells_in_fSets,'descend');
threshold_to_reject_groups=70;% to reject groups have less than this number of faces;
Sind(length_of_cells_in_fSets<threshold_to_reject_groups)=[];
fSets=fSets(Sind);
fSets2=zeros(size(mesh.f,1),1);
for i=1:length(fSets)
    current_set=cell2mat(fSets(i));
    fSets2(current_set)=i;
end
% current_set=cell2mat(fSets(1));
% a=zeros(size(mesh.f,1),1);
% a(current_set)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',a);
% delete(findall(gcf,'Type','light'));
faces_on_border=faces_on_border>0;
d=[];
