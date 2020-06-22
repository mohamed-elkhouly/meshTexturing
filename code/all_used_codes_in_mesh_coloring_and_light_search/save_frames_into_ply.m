function save_frames_into_ply(mesh,region_frames,region_faces,groups)


% Note: create ply only for viewing purpose vertices are duplicated

for index=1:size(region_frames,1)
    frame_num=region_frames(index)+1;
% frame_num=32;%32,469,648,664,665
all_faces_numbers=[];
all_faces_values=[];
all_faces_values_a=[];
all_faces_values_b=[];
new_colors=[];
for group_index=1:length(region_faces)
    all_faces_numbers=[all_faces_numbers;groups(group_index).frame(frame_num).faces];
    all_faces_values=[all_faces_values;groups(group_index).frame(frame_num).values];
    all_faces_values_a=[all_faces_values_a;groups(group_index).frame(frame_num).values_a];
    all_faces_values_b=[all_faces_values_b;groups(group_index).frame(frame_num).values_b];
    
end
new_colors(:,:,1)=all_faces_values;
new_colors(:,:,2)=all_faces_values_a;
new_colors(:,:,3)=all_faces_values_b;
% final_colors=(hsv2rgb(new_colors));
final_colors=uint8(new_colors);
aaa=zeros(length(mesh.f),3);
aaa(all_faces_numbers,1)=final_colors(:,:,1);
aaa(all_faces_numbers,2)=final_colors(:,:,2);
aaa(all_faces_numbers,3)=final_colors(:,:,3);
% figure,plot_CAD(mesh.f, mesh.v, '',uint8(aaa));
% delete(findall(gcf,'Type','light'));
% dublicate vertices_to_have per face color in ply file
tic
aaa=uint8(aaa);
new_vertices=zeros(size(mesh.f,1)*3,3);
new_faces=zeros(size(mesh.f));
new_colors=zeros(size(mesh.f,1)*3,3);
ind=1;
for i=1:size(mesh.f,1)
    new_faces(i,:)=[ind,ind+1,ind+2];
    current_face_verts=mesh.f(i,:);
    current_vertices=mesh.v(current_face_verts(:),:);
    current_colores=aaa(i,:);
    current_colores=[current_colores;current_colores;current_colores];
    new_vertices(ind:ind+2,:)=current_vertices;
    new_colors(ind:ind+2,:)=current_colores;
    ind=ind+3;
end
toc
% plywrite(['initializations/frame',num2str(frame_num-1),'initialization.ply'],new_faces,new_vertices,new_colors);
% plywrite(['infillings/frame',num2str(frame_num-1),'initialization.ply'],new_faces,new_vertices,new_colors);
end