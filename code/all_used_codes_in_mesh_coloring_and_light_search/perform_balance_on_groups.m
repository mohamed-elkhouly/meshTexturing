function luminance=perform_balance_on_groups(current_connected_groups,region_faces,faces_correspondences1,mesh,faces_colors,luminance)
first_group_index=current_connected_groups(1);
merged_groups=[current_connected_groups(1)];
first_group_faces=cell2mat(region_faces(first_group_index));
new_region_faces(1)=region_faces(first_group_index);
face_exist_flag=false(size(mesh.f,1),1);
% other_face_exist_flag=false(size(mesh.f,1),1);
face_exist_flag(first_group_faces)=1;
faces_correspondences1(:,3)=[];
gamma_factor=0.1;
distance_between_neighbor_faces=0.07;
for i=2:length(current_connected_groups)
    for j=1:length(current_connected_groups)
        if(sum(merged_groups==current_connected_groups(j))>0)
            num_correspondences(j)=0;
        else
            temp_flag=face_exist_flag;
            second_group_index=current_connected_groups(j);
            second_group_faces=cell2mat(region_faces(second_group_index));
            temp_flag(second_group_faces)=1;
            num_correspondences(j)=sum(sum(temp_flag(faces_correspondences1(:,1:2)),2)==2);
        end
    end
    [~,max_ind]=max(num_correspondences);
    if(num_correspondences(max_ind)<10)
        break;
    end
    merged_groups=[merged_groups;current_connected_groups(max_ind)];
    second_group_index=current_connected_groups(max_ind);
    second_group_faces=cell2mat(region_faces(second_group_index));
    new_region_faces(2)=region_faces(second_group_index);
    %     other_face_exist_flag(:)=0;
    face_exist_flag(second_group_faces)=1;
    available_matches=sum(face_exist_flag(faces_correspondences1(:,1:2)),2)==2;
    current_correspondences=faces_correspondences1(available_matches,:);
    faces_correspondences1(available_matches,:)=[];
    
    all_faces_in_correspondences=sort(unique([current_correspondences(:,1);current_correspondences(:,2)]));
    current_correspondences=sort(current_correspondences,2);
    current_correspondences=unique(current_correspondences,'rows');
    [F,~]=create_F_vector_for_luminance(current_correspondences,faces_colors);
    A=create_A_matrix_for_luminance(current_correspondences,size(mesh.f,1));
%     if(size(A,1)>10)
    Gamma=create_Gamma_matrix_for_luminance(new_region_faces,mesh,all_faces_in_correspondences,gamma_factor,distance_between_neighbor_faces);
    F=double(F);
    LHS=A'*A+Gamma'*Gamma;
    RHS=A'*F;
    tic;estimated_g =-1*lsqminnorm(LHS,RHS);toc
    estimated_g=estimated_g-mean(estimated_g);
    luminance=do_balance_operation(mesh,all_faces_in_correspondences,estimated_g,luminance,new_region_faces);
    new_region_faces(1)={[cell2mat(new_region_faces(1));second_group_faces(:)]};
    
    for_view_luminance=luminance;
    flag_for_view=true(size(luminance,1),1);
    flag_for_view([cell2mat(new_region_faces(1));second_group_faces(:)])=0;
    for_view_luminance(flag_for_view)=0;
    figure,plot_CAD(mesh.f, mesh.v, '',for_view_luminance);
    delete(findall(gcf,'Type','light'));
%     end
end