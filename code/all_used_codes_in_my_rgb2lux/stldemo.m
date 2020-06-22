%% 3D Model Demo
% This is short demo that loads and renders a 3D model of a human femur. It
% showcases some of MATLAB's advanced graphics features, including lighting and
% specular reflectance.

% Copyright 2011 The MathWorks, Inc.

clear all;
%% Load STL mesh
% Stereolithography (STL) files are a common format for storing mesh data. STL
% meshes are simply a collection of triangular faces. This type of model is very
% suitable for use with MATLAB's PATCH graphics object.

% Import an STL mesh, returning a PATCH-compatible face-vertex structure
% fv = stlread('femur.stl');
% vert=[];
% looping_vector=1:size(fv.vertices,1);
% new_indexing=[];
% % length_looping_vector=size(fv.vertices,1);
% tic
% for i=1:size(fv.vertices,1)
%     non_zero_looping_index=looping_vector(looping_vector~=0);
%     if (i<=length(non_zero_looping_index))
%     cur_ind=non_zero_looping_index(i);
%     temp1=find(fv.vertices(:,1)==fv.vertices(cur_ind,1));
% %     vert(i,1,1:length(temp))=temp;
%     
%     temp2=find(fv.vertices(:,2)==fv.vertices(cur_ind,2));
% %     vert(i,2,1:length(temp))=temp;
%     
%     temp3=find(fv.vertices(:,3)==fv.vertices(cur_ind,3));
% %     vert(i,3,1:length(temp))=temp;
% vals=intersect(intersect(temp1,temp2),temp3);
%      new_vertices(i,:)=fv.vertices(cur_ind,:);
%      new_indexing(vals)=i;
%      temp_indexes=find(sum(looping_vector==vals(:)));
%      temp_indexes(temp_indexes==cur_ind)=[];
%      looping_vector(temp_indexes)=0;
% %      length_looping_vector=length(looping_vector);
%     else
%             break;
%     end
% end
% toc
% fv.faces(:,1:3)=new_indexing(fv.faces(:,1:3));
% fv.vertices=new_vertices;
% save('fv.mat');
% load('fv.mat');
load('region15.mat')
fv.vertices=double(dahy{1});
fv.faces=cell2mat(dahy{4})+1;
figure, plot_CAD(fv.faces, fv.vertices, '');
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
tic
level=7;
for i=1:length(fv.faces)
    current_face_normal=fv.normals(i,:);
    current_face_vertices=fv.faces(i,:);
    [faces_of_current_vertex1,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(1),level);
    [faces_of_current_vertex2,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(2),level);
    [faces_of_current_vertex3,~]=get_neighborhood_faces_up_to_level(fv,vertex_faces,vertex_index_in_faces,current_face_vertices(3),level);
%     faces_of_vertices=vertex_faces(current_face_vertices,:);
%     faces_of_vertices=unique(faces_of_vertices(faces_of_vertices~=0));
faces_of_vertices=unique([faces_of_current_vertex1;faces_of_current_vertex2;faces_of_current_vertex3]);
    new_faces_normals=fv.normals(faces_of_vertices,:);
    rot=[];
%     for k=1:size(new_faces_normals,1)
%         rot(k,:)=vrrotvec_multiple(current_face_normal,new_faces_normals(k,:));
        rot=vrrotvec_multiple(current_face_normal,new_faces_normals);
        
%     end
    rot=rot(:,4);
    new_faces_normals(rot>0.7,:)=[];
    if(~isempty(new_faces_normals))
    new_normal_for_face=sum(new_faces_normals,1);
    new_normal_for_face=new_normal_for_face./vecnorm(new_normal_for_face);
    rot=[];
    rot=vrrotvec(current_face_normal,new_normal_for_face);
    if(isreal(rot))
    M = vrrotvec2mat(rot);
    current_face_vertices_coordinates=fv.vertices(current_face_vertices,:);
    current_face_vertices_coordinates_shifted=current_face_vertices_coordinates-fv.centroids(i,:);
    current_face_vertices_coordinates_shifted_rotated=current_face_vertices_coordinates_shifted*M;
    current_face_vertices_coordinates_shifted_back=current_face_vertices_coordinates_shifted_rotated+fv.centroids(i,:);
    fv.v1(i,:)=current_face_vertices_coordinates_shifted_back(1,:);
    fv.v2(i,:)=current_face_vertices_coordinates_shifted_back(2,:);
    fv.v3(i,:)=current_face_vertices_coordinates_shifted_back(3,:);
    end
    
    end
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
figure, plot_CAD(fv.faces, fv.vertices, '');
%% Render
% The model is rendered with a PATCH graphics object. We also add some dynamic
% lighting, and adjust the material properties to change the specular
% highlighting.

patch(fv,'FaceColor',       [0.8 0.8 1.0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);

% Add a camera light, and tone down the specular highlighting
camlight('headlight');
material('dull');

% Fix the axes scaling, and set a nice view angle
axis('image');
view([-135 35]);
d=[]