function new_group=estimate_un_appeared_faces_values_for_balancing(group,all_faces_in_group,mesh,group_index)

original_frames=group.frames_index;
required_frames=group.frames_index;
new_group=group;

intersection_between_frames=zeros(size(required_frames,1),length(required_frames)-1);
intersected_frames=zeros(size(required_frames,1),length(required_frames)-1);
for frame_index=1:length(required_frames)
    current_frame=required_frames(frame_index);
    current_frame_appeared_faces=group.frame(current_frame).faces;
    other_required_frames=required_frames;
    other_required_frames(frame_index)=[];
    for oth_f_index=1:length(other_required_frames)
        other_frame=other_required_frames(oth_f_index);
        other_frame_appeared_faces=group.frame(other_frame).faces;
        [common_faces, ~, ~]=intersect(current_frame_appeared_faces,other_frame_appeared_faces);
        intersection_between_frames(frame_index,oth_f_index)=length(common_faces);
        intersected_frames(frame_index,oth_f_index)=other_frame;
    end
    [~,inds]=sort(intersection_between_frames(frame_index,:),'descend');
    curr_frames=intersected_frames(frame_index,:);
    intersected_frames(frame_index,:)=curr_frames(inds);
end



% intersected_frames = triu(intersected_frames,1);
% intersected_frames(intersection_between_frames==0)=0;

num_all_faces=size(mesh.f,1);
required_matrices=[];
processed_frames_pairs=[0 0];
for frame_index=1:size(intersected_frames,1)
    required_frames=intersected_frames(frame_index,:);

    estimated_values_for_unappeared_face=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face(:,1)=0;
    estimated_values_for_unappeared_face_a=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face_a(:,1)=0;
    estimated_values_for_unappeared_face_b=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face_b(:,1)=0;
    current_frame=original_frames(frame_index);
    current_frame_appeared_faces=group.frame(current_frame).faces;
    
    current_frame_appeared_faces_values=group.frame(current_frame).values;
    current_frame_appeared_faces_values_a=group.frame(current_frame).values_a;
    current_frame_appeared_faces_values_b=group.frame(current_frame).values_b;
    current_frame_UN_appeared_faces=all_faces_in_group;
    [~,indsa,~]=intersect(current_frame_UN_appeared_faces,current_frame_appeared_faces);
    other_required_frames=required_frames;
    [~, faces_in_current_index_in_group]=intersect(all_faces_in_group,current_frame_appeared_faces);
  
    indexes_of_column_from_big_array=estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)+2;
    
            indexes_of_elements_in_big_array=sub2ind(size(estimated_values_for_unappeared_face),faces_in_current_index_in_group,indexes_of_column_from_big_array);
           estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values;
            estimated_values_for_unappeared_face_a(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values_a;
            estimated_values_for_unappeared_face_b(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values_b;
            estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)=estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)+1;

local_required_matrices=[];
    for oth_f_index=1:length(other_required_frames)
        other_frame=other_required_frames(oth_f_index);
        c=[min([current_frame,other_frame]),max([current_frame,other_frame])];
        
        [found_flag, ~] = ismember(c, processed_frames_pairs, 'rows');
        if(found_flag)
            continue;
        end
        processed_frames_pairs=[processed_frames_pairs;c];
        
        if(other_frame==0)
            continue;
        end
        other_frame_appeared_faces=group.frame(other_frame).faces;
        other_frame_appeared_faces_values=group.frame(other_frame).values;
        other_frame_appeared_faces_values_a=group.frame(other_frame).values_a;
        other_frame_appeared_faces_values_b=group.frame(other_frame).values_b;
        [common_faces, C_f_indsa, C_f_indsb]=intersect(current_frame_appeared_faces,other_frame_appeared_faces);
       
        division_vals=current_frame_appeared_faces_values(C_f_indsa)./other_frame_appeared_faces_values(C_f_indsb);
        division_vals_a=current_frame_appeared_faces_values_a(C_f_indsa)./other_frame_appeared_faces_values_a(C_f_indsb);
        division_vals_b=current_frame_appeared_faces_values_b(C_f_indsa)./other_frame_appeared_faces_values_b(C_f_indsb);

        division_vals(isinf(division_vals))=[];

        division_vals_a(isinf(division_vals_a))=[];

        division_vals_b(isinf(division_vals_b))=[];

        if(length(C_f_indsa)<25)

            if(length(C_f_indsa)/length(all_faces_in_group)<0.003)
                continue;
            end
        end
        
        if(~isempty(division_vals)||~isempty(division_vals_a)||~isempty(division_vals_b))
            
             ref_for_current=common_faces+(find(original_frames==current_frame)-1)*num_all_faces;
        ref_for_other=common_faces+(find(original_frames==other_frame)-1)*num_all_faces;
        local_required_matrices=[local_required_matrices;[ref_for_current,ref_for_other,...
            [current_frame_appeared_faces_values(C_f_indsa),other_frame_appeared_faces_values(C_f_indsb),...
        current_frame_appeared_faces_values_a(C_f_indsa),other_frame_appeared_faces_values_a(C_f_indsb),...
        current_frame_appeared_faces_values_b(C_f_indsa),other_frame_appeared_faces_values_b(C_f_indsb)],...
        ]];
            
            
            
            division_vals(isinf(division_vals)|isnan(division_vals))=[];
            division_vals_a(isinf(division_vals_a)|isnan(division_vals_a))=[];
            division_vals_b(isinf(division_vals_b)|isnan(division_vals_b))=[];
            average_div_vals=trimmean(division_vals,30);
            average_div_vals_a=trimmean(division_vals_a,30);
            average_div_vals_b=trimmean(division_vals_b,30);
            
            if(isnan(average_div_vals))
                average_div_vals=[];
            end
            if(isnan(average_div_vals_a))
                average_div_vals_a=[];
            end
            if(isnan(average_div_vals_b))
                average_div_vals_b=[];
            end
            mean_val=mean([average_div_vals,average_div_vals_a,average_div_vals_b]);
            if(isempty(average_div_vals))
                average_div_vals=mean_val;
            end
            if(isempty(average_div_vals_a))
                average_div_vals_a=mean_val;
            end
            if(isempty(average_div_vals_b))
                average_div_vals_b=mean_val;
            end
            
            faces_in_others_but_not_in_current=other_frame_appeared_faces;
            
            faces_in_others_but_not_in_current_values=other_frame_appeared_faces_values;
            faces_in_others_but_not_in_current_values_a=other_frame_appeared_faces_values_a;
            faces_in_others_but_not_in_current_values_b=other_frame_appeared_faces_values_b;
            
            [~, faces_in_others_but_not_in_current_index_in_group]=intersect(all_faces_in_group,faces_in_others_but_not_in_current);
            
            estimate_in_current_the_faces_in_others_but_not_in_current=average_div_vals*faces_in_others_but_not_in_current_values;
            estimate_in_current_the_faces_in_others_but_not_in_current_a=average_div_vals_a*faces_in_others_but_not_in_current_values_a;
            estimate_in_current_the_faces_in_others_but_not_in_current_b=average_div_vals_b*faces_in_others_but_not_in_current_values_b;
            % in the next line I add the faces in the new image to my
            % faces.
%             current_frame_appeared_faces=[current_frame_appeared_faces;faces_in_others_but_not_in_current];
            current_frame_appeared_faces_values=[current_frame_appeared_faces_values;estimate_in_current_the_faces_in_others_but_not_in_current];
            current_frame_appeared_faces_values_a=[current_frame_appeared_faces_values_a;estimate_in_current_the_faces_in_others_but_not_in_current_a];
            current_frame_appeared_faces_values_b=[current_frame_appeared_faces_values_b;estimate_in_current_the_faces_in_others_but_not_in_current_b];

            indexes_of_column_from_big_array=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+2;
    
            indexes_of_elements_in_big_array=sub2ind(size(estimated_values_for_unappeared_face),faces_in_others_but_not_in_current_index_in_group,indexes_of_column_from_big_array);

            estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current;
            estimated_values_for_unappeared_face_a(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current_a;
            estimated_values_for_unappeared_face_b(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current_b;
            estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+1;
        end
    end
    required_matrices=[required_matrices;local_required_matrices];
    un_app_in_cur_inds_in_big_array=1:length(all_faces_in_group);
    current_frame_UN_appeared_faces=all_faces_in_group;
    fin_estimated=zeros(length(un_app_in_cur_inds_in_big_array),1);
    fin_estimated_a=zeros(length(un_app_in_cur_inds_in_big_array),1);
    fin_estimated_b=zeros(length(un_app_in_cur_inds_in_big_array),1);
    for un_app_in_cur_index=1:length(un_app_in_cur_inds_in_big_array)
        estimated_vlaues=estimated_values_for_unappeared_face(un_app_in_cur_inds_in_big_array(un_app_in_cur_index),2:end);
        estimated_vlaues(estimated_vlaues==-1)=[];
        if(~isempty(estimated_vlaues))
            fin_estimated(un_app_in_cur_index)=median(estimated_vlaues);
        end
        
        estimated_vlaues=estimated_values_for_unappeared_face_a(un_app_in_cur_inds_in_big_array(un_app_in_cur_index),2:end);
        estimated_vlaues(estimated_vlaues==-1)=[];
        if(~isempty(estimated_vlaues))
            fin_estimated_a(un_app_in_cur_index)=median(estimated_vlaues);
        end
        
        estimated_vlaues=estimated_values_for_unappeared_face_b(un_app_in_cur_inds_in_big_array(un_app_in_cur_index),2:end);
        estimated_vlaues(estimated_vlaues==-1)=[];
        if(~isempty(estimated_vlaues))
            fin_estimated_b(un_app_in_cur_index)=median(estimated_vlaues);
        end
        
    end
    
    new_group.frame(current_frame).faces=current_frame_UN_appeared_faces;
    new_group.frame(current_frame).values=fin_estimated;
    new_group.frame(current_frame).values_a=fin_estimated_a;
    new_group.frame(current_frame).values_b=fin_estimated_b;
    
    %     end
end
num_frames=length(original_frames);
correspondences=prepare_and_balance(required_matrices,mesh,num_frames);
num_all_faces=size(mesh.f,1);
% save("up_to_here.mat");
% load("up_to_here.mat");

% 
for frame_index=1:num_frames
   current_frame=original_frames(frame_index);
all_inds=correspondences(:,1);
    start_i=num_all_faces*(frame_index-1)+1;
    end_i=num_all_faces*(frame_index);
    flag=all_inds>=start_i&all_inds<=end_i;
    existed_indexes=all_inds(flag);
    existed_indexes=existed_indexes-start_i+1;
    existed_indexes_values=correspondences(flag,2:4);
    current_frame_appeared_faces=group.frame(current_frame).faces;
    current_frame_appeared_faces_values=group.frame(current_frame).values;
    current_frame_appeared_faces_values_a=group.frame(current_frame).values_a;
    current_frame_appeared_faces_values_b=group.frame(current_frame).values_b;
    all_values=[current_frame_appeared_faces_values,current_frame_appeared_faces_values_a,current_frame_appeared_faces_values_b];
    
    indexing_frame_faces=[];
    for i=1:length(current_frame_appeared_faces)
        indexing_frame_faces(current_frame_appeared_faces(i))=i;
    end
   
    place_of_modified_in_original=indexing_frame_faces(existed_indexes);
    
     existed_faces_values=all_values(place_of_modified_in_original,:);
    current_frame_appeared_faces(place_of_modified_in_original)=[];
    current_frame_appeared_faces_values(place_of_modified_in_original)=[];
    current_frame_appeared_faces_values_a(place_of_modified_in_original)=[];
    current_frame_appeared_faces_values_b(place_of_modified_in_original)=[];
    rquired_faces=current_frame_appeared_faces;
    required_faces_values=[current_frame_appeared_faces_values,current_frame_appeared_faces_values_a,current_frame_appeared_faces_values_b];
    
    coordinates_of_estimated_faces=mesh.centroids(existed_indexes,:);
    coordinates_of_required_faces=mesh.centroids(rquired_faces,:);
    X=coordinates_of_estimated_faces(:,1);Y=coordinates_of_estimated_faces(:,2);Z=coordinates_of_estimated_faces(:,3);
    Xq=coordinates_of_required_faces(:,1);Yq=coordinates_of_required_faces(:,2);Zq=coordinates_of_required_faces(:,3);
    try
    Vq=zeros(size(Xq,1),3);
    for i=1:3
    V=existed_indexes_values(:,1);
    F = scatteredInterpolant(X,Y,Z,V,'nearest');
    Vq(:,i) = F(Xq,Yq,Zq);
    end
    catch
        Vq=0;
    end
    
%     modified_values_existed_faces=existed_faces_values;
    modified_values_existed_faces=existed_faces_values+existed_indexes_values;
    modified_required_faces_values=required_faces_values+Vq;
    
    temp_matrix_for_checking(existed_indexes,frame_index,:)=modified_values_existed_faces;
%     modified_values_existed_faces=existed_faces_values;
%     modified_required_faces_values=required_faces_values;
     new_group.frame(current_frame).faces=[existed_indexes;rquired_faces];
    new_group.frame(current_frame).values=[modified_values_existed_faces(:,1);modified_required_faces_values(:,1)];
    new_group.frame(current_frame).values_a=[modified_values_existed_faces(:,2);modified_required_faces_values(:,2)];
    new_group.frame(current_frame).values_b=[modified_values_existed_faces(:,3);modified_required_faces_values(:,3)];
    
%      new_group.frame(current_frame).faces=[existed_indexes];
%     new_group.frame(current_frame).values=[modified_values_existed_faces(:,1)];
%     new_group.frame(current_frame).values_a=[modified_values_existed_faces(:,2)];
%     new_group.frame(current_frame).values_b=[modified_values_existed_faces(:,3)];
end
d=[];