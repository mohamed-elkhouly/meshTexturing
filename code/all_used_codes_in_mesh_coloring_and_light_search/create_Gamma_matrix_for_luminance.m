function Gamma=create_Gamma_matrix_for_luminance(region_faces_backup,mesh,all_appeared_faces,gamma_factor,distance_between_neighbor_faces)
face_appeared_flag=false(size(mesh.f,1),1);
face_appeared_flag(all_appeared_faces)=1;
gamma_mat_index=1;
row_gamma=1;
max_nearest=0;
for i=1:length(region_faces_backup)
    current_group_faces=cell2mat(region_faces_backup(i));
    faces_appeared=current_group_faces(face_appeared_flag(current_group_faces));
    current_faces_coordinates=mesh.centroids(faces_appeared,:);
    nearest_flag=false(size(current_faces_coordinates,1),1);
    
    for j=1:size(current_faces_coordinates,1)
        if(nearest_flag(j))
            continue;
        end
        subtraction=abs(sum(abs(current_faces_coordinates-current_faces_coordinates(j,:)),2));
        subtraction(j)=inf;
        subtraction(nearest_flag)=inf;
        [~,nearest]=min(subtraction);
        nearest_flag(nearest)=1;
        %         col1=g_indexes_correspondences(faces_appeared(j));
        %         col2=g_indexes_correspondences(faces_appeared(nearest));
        
        col1=(faces_appeared(j));
        col2=(faces_appeared(nearest));
        if(col1==0||col2==0)
            continue;
        end
        if(subtraction(nearest)>max_nearest)
            max_nearest=subtraction(nearest);
        end
        if(subtraction(nearest)>distance_between_neighbor_faces)
            continue;
        end
        
        gamma_mat(gamma_mat_index,:)=[row_gamma,col1,1*gamma_factor];
        gamma_mat_index=gamma_mat_index+1;
        gamma_mat(gamma_mat_index,:)=[row_gamma,col2,-1*gamma_factor];
        gamma_mat_index=gamma_mat_index+1;
        row_gamma=row_gamma+1;
    end
end
if(row_gamma~=1)
    Gamma=sparse(gamma_mat(:,1),gamma_mat(:,2),gamma_mat(:,3),max(gamma_mat(:,1)),max(all_appeared_faces));
else
    Gamma=sparse(1,max(all_appeared_faces));
end

