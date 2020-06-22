function new_group=estimate_un_appeared_faces_values(group,all_faces_in_group,mesh)
original_frames=group.frames_index;
required_frames=group.frames_index;
new_group=group;
temp_all_appeared_faces_to_check_error=[];
to_check_all_vals=[];


intersection_between_frames=zeros(size(required_frames,1),length(required_frames)-1);
intersected_frames=zeros(size(required_frames,1),length(required_frames)-1);
for frame_index=1:length(required_frames)
%     temp_all_appeared_faces_to_check_error=[];
    estimated_values_for_unappeared_face=ones(size(all_faces_in_group,1), length(required_frames))*-1;
    estimated_values_for_unappeared_face(:,1)=0;
    current_frame=required_frames(frame_index);
    current_frame_appeared_faces=group.frame(current_frame).faces;
%     temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;current_frame_appeared_faces];
%     current_frame_appeared_faces_values=group.frame(current_frame).values;
%     current_frame_UN_appeared_faces=all_faces_in_group;
%     [~,indsa,indsb]=intersect(current_frame_UN_appeared_faces,current_frame_appeared_faces);
%     current_frame_UN_appeared_faces(indsa)=[];
    other_required_frames=required_frames;
    other_required_frames(frame_index)=[];
    for oth_f_index=1:length(other_required_frames)
        other_frame=other_required_frames(oth_f_index);
        other_frame_appeared_faces=group.frame(other_frame).faces;
%         other_frame_appeared_faces_values=group.frame(other_frame).values;
%         temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;other_frame_appeared_faces];
        [common_faces, ~, ~]=intersect(current_frame_appeared_faces,other_frame_appeared_faces);
%         if(length(common_faces)>max_intersection(frame_index,1))
            intersection_between_frames(frame_index,oth_f_index)=length(common_faces);
            intersected_frames(frame_index,oth_f_index)=other_frame;
%         end
        
    end
    [~,inds]=sort(intersection_between_frames(frame_index,:),'descend');
    curr_frames=intersected_frames(frame_index,:);
    intersected_frames(frame_index,:)=curr_frames(inds);
end



for frame_index=1:size(intersected_frames,1)
    required_frames=intersected_frames(frame_index,:);
%     temp_all_appeared_faces_to_check_error=[];
    estimated_values_for_unappeared_face=ones(size(all_faces_in_group,1), length(original_frames))*-1;
    estimated_values_for_unappeared_face(:,1)=0;
    current_frame=original_frames(frame_index);
    current_frame_appeared_faces=group.frame(current_frame).faces;
%     temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;current_frame_appeared_faces];
    current_frame_appeared_faces_values=group.frame(current_frame).values;
    current_frame_UN_appeared_faces=all_faces_in_group;
    [~,indsa,~]=intersect(current_frame_UN_appeared_faces,current_frame_appeared_faces);
    current_frame_UN_appeared_faces(indsa)=[];
    other_required_frames=required_frames;
%     other_required_frames(frame_index)=[];
    for oth_f_index=1:length(other_required_frames)
        other_frame=other_required_frames(oth_f_index);
        other_frame_appeared_faces=group.frame(other_frame).faces;
        other_frame_appeared_faces_values=group.frame(other_frame).values;
%         temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;other_frame_appeared_faces];
        [common_faces, C_f_indsa, C_f_indsb]=intersect(current_frame_appeared_faces,other_frame_appeared_faces);
        division_vals=current_frame_appeared_faces_values(C_f_indsa)./other_frame_appeared_faces_values(C_f_indsb);
        % next removing is for removing what we think it is non correct and
        % large change in face values.(we allow for only +/- 40 degree= 1.16)
        division_vals(division_vals>1.5)=[];
        division_vals(division_vals<0.5)=[];
        if(~isempty(division_vals))
            average_div_vals=median(division_vals);
            faces_in_others_but_not_in_current=other_frame_appeared_faces;
            faces_in_others_but_not_in_current_values=other_frame_appeared_faces_values;
            faces_in_others_but_not_in_current(C_f_indsb)=[];
            [~, faces_in_others_but_not_in_current_index_in_group]=intersect(all_faces_in_group,faces_in_others_but_not_in_current);
            faces_in_others_but_not_in_current_values(C_f_indsb)=[];
         
            estimate_in_current_the_faces_in_others_but_not_in_current=average_div_vals*faces_in_others_but_not_in_current_values;
%             if (oth_f_index==1)
            current_frame_appeared_faces=[current_frame_appeared_faces;faces_in_others_but_not_in_current];
            current_frame_appeared_faces_values=[current_frame_appeared_faces_values;estimate_in_current_the_faces_in_others_but_not_in_current];
%             end
            indexes_of_column_from_big_array=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+2;
            indexes_of_elements_in_big_array=sub2ind(size(estimated_values_for_unappeared_face),faces_in_others_but_not_in_current_index_in_group,indexes_of_column_from_big_array);
            estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current;
            estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+1;
        end
    end
%     aa=unique(temp_all_appeared_faces_to_check_error);
    [~,un_app_in_cur_inds_in_big_array]=intersect(all_faces_in_group,current_frame_UN_appeared_faces);
    fin_estimated=zeros(length(un_app_in_cur_inds_in_big_array),1);
    for un_app_in_cur_index=1:length(un_app_in_cur_inds_in_big_array)
        estimated_vlaues=estimated_values_for_unappeared_face(un_app_in_cur_inds_in_big_array(un_app_in_cur_index),2:end);
        estimated_vlaues(estimated_vlaues==-1)=[];
         if(~isempty(estimated_vlaues))
        fin_estimated(un_app_in_cur_index)=median(estimated_vlaues);
        end
    end
    new_group.frame(current_frame).faces=[new_group.frame(current_frame).faces;current_frame_UN_appeared_faces];
    new_group.frame(current_frame).values=[new_group.frame(current_frame).values;fin_estimated];
    to_check_all_vals(new_group.frame(current_frame).faces,frame_index)=new_group.frame(current_frame).values;
end
d=[];