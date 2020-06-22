function new_faces_luminance=balance_Groups_Luminance3(faces_colors,mesh)
luminance=max(faces_colors,[],2);
[fSets,faces_on_border]=find_separated_groups(luminance,mesh);

fSets(faces_on_border)=0;

[mesh,region_faces,~,regions_edge_faces,num_faces_in_region]=find_border_faces_of_mesh(mesh,fSets);
[~,inda]=sort(num_faces_in_region,'descend');
region_faces=region_faces(inda);
figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);



[faces_correspondences,~]=find_nearest_faces_from_other_groups2(mesh,regions_edge_faces,region_faces,[],mesh.f,[],1);
final_regions_connections=organize_regions_to_be_balanced(faces_correspondences,regions_edge_faces,size(mesh.f,1),region_faces);

luminance=max(faces_colors,[],2);
luminance(faces_on_border)=0;
faces_correspondences1=[];
for i=1:length(faces_correspondences)
    faces_correspondences1=[faces_correspondences1;cell2mat(faces_correspondences(i))];
end
for i=1:length(final_regions_connections)
    current_connected_groups=cell2mat(final_regions_connections(i));
%     current_connected_groups2=order_groups_based_on_correspondings(current_connected_groups,faces_correspondences1,region_faces);
%     current_connected_groups=current_connected_groups2;
    current_connected_groups=current_connected_groups';
    current_connected_groups=current_connected_groups(:);
    current_connected_groups(current_connected_groups==0)=[];
    % remove repeated elements in the next for
    for j=1:length(current_connected_groups)
        flag=current_connected_groups==current_connected_groups(j);
        flag(j)=0;% forbidden it from counting our current case;
        current_connected_groups(flag)=0;
    end
    current_connected_groups(current_connected_groups==0)=[];
    luminance=perform_balance_on_groups(current_connected_groups,region_faces,faces_correspondences1,mesh,faces_colors,luminance);
end
figure,plot_CAD(mesh.f, mesh.v, '',luminance);
delete(findall(gcf,'Type','light'));

[F,luminance]=create_F_vector_for_luminance(faces_correspondences1,faces_colors);

all_faces_in_correspondences=sort(unique([faces_correspondences1(:,1);faces_correspondences1(:,2)]));
A=create_A_matrix_for_luminance(faces_correspondences1,size(mesh.f,1));
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