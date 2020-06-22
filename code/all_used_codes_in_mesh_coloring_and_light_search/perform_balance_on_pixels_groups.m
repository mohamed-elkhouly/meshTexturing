function luminance=perform_balance_on_pixels_groups(current_connected_groups,region_faces,faces_correspondences1,number_of_all_pixels,luminance,connected_regions_numbers,connected_regions_count)
luminance=double(luminance);
first_group_index=current_connected_groups(1);
merged_groups=[current_connected_groups(1)];
first_group_faces=cell2mat(region_faces(first_group_index));
new_region_faces(1)=region_faces(first_group_index);
face_exist_flag=false(number_of_all_pixels,1);
% other_face_exist_flag=false(size(mesh.f,1),1);
face_exist_flag(first_group_faces)=1;
% faces_correspondences1(:,3)=[];
gamma_factor=0.1;
distance_between_neighbor_faces=0.07;
for i=2:length(current_connected_groups)
    if(i==13)
        d=[];
    end
    other_g_nums=connected_regions_numbers(merged_groups(:),:);
    other_g_counts=connected_regions_count(merged_groups(:),:);
    other_g_counts(other_g_nums(:)==0)=[];
    other_g_nums(other_g_nums(:)==0)=[];
    other_g_counts(sum(other_g_nums==merged_groups,1)>0)=[];
    other_g_nums(sum(other_g_nums==merged_groups,1)>0)=[];
    num_correspondences=zeros(length(region_faces),1);
    for j=1:length(other_g_nums)
        num_correspondences(other_g_nums(j))=num_correspondences(other_g_nums(j))+other_g_counts(j);
    end
    
%     for j=1:length(current_connected_groups)
%         if(sum(merged_groups==current_connected_groups(j))>0)
%             num_correspondences(j)=0;
%         else
%             temp_flag=face_exist_flag;
%             second_group_index=current_connected_groups(j);
%             second_group_faces=cell2mat(region_faces(second_group_index));
%             temp_flag(second_group_faces)=1;
%             num_correspondences(j)=sum(sum(temp_flag(faces_correspondences1(:,1:2)),2)==2);
%         end
%     end
    
    [~,second_group_index]=max(num_correspondences);
    if(num_correspondences(second_group_index)<5)
        break;
    end
    merged_groups=[merged_groups;second_group_index];
%     max_ind=find(current_connected_groups==second_group_index);
    
%     merged_groups=[merged_groups;current_connected_groups(max_ind)];
%     second_group_index=current_connected_groups(max_ind);
    second_group_faces=cell2mat(region_faces(second_group_index));
    new_region_faces(2)=region_faces(second_group_index);
    %     other_face_exist_flag(:)=0;
    back_face_exist_flag=face_exist_flag;
    face_exist_flag(second_group_faces)=1;
    available_matches=sum(face_exist_flag(faces_correspondences1),2)==2;
    current_correspondences=faces_correspondences1(available_matches,:);
    faces_correspondences1(available_matches,:)=[];
    
%     all_faces_in_correspondences=sort(unique([current_correspondences(:,1);current_correspondences(:,2)]));
    current_correspondences=sort(current_correspondences,2);
    current_correspondences=unique(current_correspondences,'rows');
    
    reordered_correspondences_flag=back_face_exist_flag(current_correspondences);
    [~,first_gr_crs]=max(reordered_correspondences_flag,[],2);
    [~,second_gr_crs]=max(~reordered_correspondences_flag,[],2);
    first_gr_crs=sub2ind(size(current_correspondences),(1:length(first_gr_crs))',first_gr_crs);
    second_gr_crs=sub2ind(size(current_correspondences),(1:length(second_gr_crs))',second_gr_crs);
    lum_G1=double(luminance(current_correspondences(first_gr_crs)));
    lum_G2=double(luminance(current_correspondences(second_gr_crs)));
    F=lum_G1-lum_G2;
    error_in_g2=sum((lum_G2+F)>255);
    error_in_g1=sum((lum_G1-F)<0);
    if(error_in_g2<=error_in_g1)
        ratio=double(uint8(luminance(current_correspondences(second_gr_crs))+F))./luminance(current_correspondences(second_gr_crs));
%         luminance(current_correspondences(second_gr_crs))=double(uint8(luminance(current_correspondences(second_gr_crs))+F));
         ratio(ratio==inf)=[];ratio(ratio==-inf)=[];avg_ratio=trimmean(ratio,30);
         luminance(second_group_faces)=double(uint8(luminance(second_group_faces)*avg_ratio));
    else
        ratio=double(uint8(luminance(current_correspondences(first_gr_crs))-F))./luminance(current_correspondences(first_gr_crs));
%         luminance(current_correspondences(first_gr_crs))=double(uint8(luminance(current_correspondences(first_gr_crs))-F));
        ratio(ratio==inf)=[];ratio(ratio==-inf)=[];avg_ratio=trimmean(ratio,30);
        first_group_faces=cell2mat(new_region_faces(1));
        luminance(first_group_faces)=double(uint8(luminance(first_group_faces)*avg_ratio));
        
    end
%     [F,~]=create_F_vector_for_luminance(current_correspondences,faces_colors);
%     A=create_A_matrix_for_luminance(current_correspondences,size(mesh.f,1));
% %     if(size(A,1)>10)
%     Gamma=create_Gamma_matrix_for_luminance(new_region_faces,mesh,all_faces_in_correspondences,gamma_factor,distance_between_neighbor_faces);
%     
%     F=double(F);
%     LHS=A'*A+Gamma'*Gamma;
%     RHS=A'*F;
%     tic;estimated_g =-1*lsqminnorm(LHS,RHS);toc
%     estimated_g=estimated_g-mean(estimated_g);
    
%     luminance=do_balance_operation(number_of_all_pixels,all_faces_in_correspondences,estimated_g,luminance,new_region_faces);
    new_region_faces(1)={[cell2mat(new_region_faces(1));second_group_faces(:)]};
    
%     for_view_luminance=luminance;
%     flag_for_view=true(size(luminance,1),1);
%     flag_for_view([cell2mat(new_region_faces(1));second_group_faces(:)])=0;
%     for_view_luminance(flag_for_view)=0;
%     figure,plot_CAD(mesh.f, mesh.v, '',for_view_luminance);
%     delete(findall(gcf,'Type','light'));
%     end
end
figure; imshow(uint8(luminance));
d=[];