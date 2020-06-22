function new_faces_luminance=balance_Groups_Luminance(faces_colors,mesh)
luminance=max(faces_colors,[],2);
[fSets,faces_on_border]=find_separated_groups(luminance,mesh);

fSets(faces_on_border)=0;

[mesh,region_faces,all_used_groups_faces,regions_edge_faces]=find_border_faces_of_mesh(mesh,fSets);
figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
[faces_correspondences,all_used_edge_faces]=find_nearest_faces_from_other_groups2(mesh,regions_edge_faces,region_faces,[],mesh.f,[],1);

faces_correspondences1=[];
for i=1:length(faces_correspondences)
    faces_correspondences1=[faces_correspondences1;cell2mat(faces_correspondences(i))];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55%%%%%%%%%%%%%%
% save('up_to_here.mat');
% load('up_to_here.mat');
% faces_correspondences1=[];
% i=20;
% faces_correspondences1=[faces_correspondences1;cell2mat(faces_correspondences(i))];
% aaa=uint64(faces_correspondences1(:,1:2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
[F,luminance]=create_F_vector_for_luminance(faces_correspondences1,faces_colors);
luminance(faces_on_border)=0;
all_faces_in_correspondences=sort(unique([faces_correspondences1(:,1);faces_correspondences1(:,2)]));
% g_indexes=(1:length(all_faces_in_correspondences))';
% g_indexes_correspondences(all_faces_in_correspondences)=g_indexes;
% A=create_A_matrix_for_luminance(faces_correspondences1,size(mesh.f,1),g_indexes_correspondences);
A=create_A_matrix_for_luminance(faces_correspondences1,size(mesh.f,1));

% Gamma=create_Gamma_matrix_for_luminance(region_faces_backup,mesh,all_faces_in_correspondences,g_indexes_correspondences);
gamma_factor=0.1;
distance_between_neighbor_faces=0.07;
Gamma=create_Gamma_matrix_for_luminance(region_faces,mesh,all_faces_in_correspondences,gamma_factor,distance_between_neighbor_faces);

F=double(F);
LHS=A'*A+Gamma'*Gamma;
RHS=A'*F;
tic;estimated_g =-1*lsqminnorm(LHS,RHS);toc
estimated_g=estimated_g-mean(estimated_g);
new_faces_luminance=do_balance_operation(mesh,all_faces_in_correspondences,estimated_g,luminance,region_faces);
figure,plot_CAD(mesh.f, mesh.v, '',(new_faces_luminance-luminance));
delete(findall(gcf,'Type','light'));
d=[];