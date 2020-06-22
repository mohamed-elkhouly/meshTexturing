function new_group=estimate_un_appeared_faces_values_cb_cr_lab(group,all_faces_in_group,mesh,group_index)

% var_limit=0.005;


% aaa=zeros(length(mesh.f),1);
% aaa(all_faces_in_group)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% delete(findall(gcf,'Type','light'));
% title(num2str(group_index))


original_frames=group.frames_index;
required_frames=group.frames_index;
new_group=group;
% temp_all_appeared_faces_to_check_error=[];
% to_check_all_vals=[];


intersection_between_frames=zeros(size(required_frames,1),length(required_frames)-1);
intersected_frames=zeros(size(required_frames,1),length(required_frames)-1);
for frame_index=1:length(required_frames)
    %     temp_all_appeared_faces_to_check_error=[];
    %     estimated_values_for_unappeared_face=ones(size(all_faces_in_group,1), length(required_frames))*-1;
    %     estimated_values_for_unappeared_face(:,1)=0;
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
    estimated_values_for_unappeared_face=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face(:,1)=0;
    estimated_values_for_unappeared_face_a=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face_a(:,1)=0;
    estimated_values_for_unappeared_face_b=ones(size(all_faces_in_group,1), length(original_frames)*2)*-1;
    estimated_values_for_unappeared_face_b(:,1)=0;
    current_frame=original_frames(frame_index);
    current_frame_appeared_faces=group.frame(current_frame).faces;
    
    %     temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;current_frame_appeared_faces];
    current_frame_appeared_faces_values=group.frame(current_frame).values;
    current_frame_appeared_faces_values_a=group.frame(current_frame).values_a;
    current_frame_appeared_faces_values_b=group.frame(current_frame).values_b;
    current_frame_UN_appeared_faces=all_faces_in_group;
    [~,indsa,~]=intersect(current_frame_UN_appeared_faces,current_frame_appeared_faces);
    current_frame_UN_appeared_faces(indsa)=[];
    other_required_frames=required_frames;
    [~, faces_in_current_index_in_group]=intersect(all_faces_in_group,current_frame_appeared_faces);
  
    indexes_of_column_from_big_array=estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)+2;
    
            indexes_of_elements_in_big_array=sub2ind(size(estimated_values_for_unappeared_face),faces_in_current_index_in_group,indexes_of_column_from_big_array);
           estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values;
            estimated_values_for_unappeared_face_a(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values_a;
            estimated_values_for_unappeared_face_b(indexes_of_elements_in_big_array)=current_frame_appeared_faces_values_b;
            estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)=estimated_values_for_unappeared_face(faces_in_current_index_in_group,1)+1;
    %     other_required_frames(frame_index)=[];
%     flag_for_knowing_that_it_did_not_find_any_correspondence_at_any_frame=0;
    for oth_f_index=1:length(other_required_frames)
        other_frame=other_required_frames(oth_f_index);
        other_frame_appeared_faces=group.frame(other_frame).faces;
        other_frame_appeared_faces_values=group.frame(other_frame).values;
        other_frame_appeared_faces_values_a=group.frame(other_frame).values_a;
        other_frame_appeared_faces_values_b=group.frame(other_frame).values_b;
        %         temp_all_appeared_faces_to_check_error=[temp_all_appeared_faces_to_check_error;other_frame_appeared_faces];
        [common_faces, C_f_indsa, C_f_indsb]=intersect(current_frame_appeared_faces,other_frame_appeared_faces);
        
        division_vals=current_frame_appeared_faces_values(C_f_indsa)./other_frame_appeared_faces_values(C_f_indsb);
        division_vals_a=current_frame_appeared_faces_values_a(C_f_indsa)./other_frame_appeared_faces_values_a(C_f_indsb);
        division_vals_b=current_frame_appeared_faces_values_b(C_f_indsa)./other_frame_appeared_faces_values_b(C_f_indsb);
        % next removing is for removing what we think it is non correct and
        % large change in face values.(we allow for only +/- 40 degree= 1.16)
        %         division_vals(division_vals>1.3)=[];
        %         division_vals(division_vals<0.7|isinf(division_vals))=[];
        division_vals(isinf(division_vals))=[];
        %         calc_var=std(division_vals);
        %         while(calc_var>var_limit)
        %             division_vals(division_vals<(mean(division_vals)-std(division_vals)))=[];division_vals(division_vals>(mean(division_vals)+std(division_vals)))=[];
        %             if std(division_vals)==calc_var;break;end
        %             calc_var=std(division_vals);
        %         end
        %         division_vals_a(division_vals_a>1.3)=[];
        %         division_vals_a(division_vals_a<0.7|isinf(division_vals_a))=[];
        division_vals_a(isinf(division_vals_a))=[];
        %         calc_var=std(division_vals_a);
        %         while(calc_var>var_limit)
        %             division_vals_a(division_vals_a<(mean(division_vals_a)-std(division_vals_a)))=[];division_vals_a(division_vals_a>(mean(division_vals_a)+std(division_vals_a)))=[];
        %             if std(division_vals_a)==calc_var;break;end
        %             calc_var=std(division_vals_a);
        %         end
        
        %         division_vals_b(division_vals_b>1.3)=[];
        %         division_vals_b(division_vals_b<0.7|isinf(division_vals_b))=[];
        division_vals_b(isinf(division_vals_b))=[];
        %         calc_var=std(division_vals_b);
        %         while(calc_var>var_limit)
        %             division_vals_b(division_vals_b<(mean(division_vals_b)-std(division_vals_b)))=[];division_vals_b(division_vals_b>(mean(division_vals_b)+std(division_vals_b)))=[];
        %             if std(division_vals_b)==calc_var;break;end
        %             calc_var=std(division_vals_b);
        %         end
        
        if(length(C_f_indsa)<25)
            %             calc_var=std(division_vals);
            %             calc_vara=std(division_vals_a);
            %                     calc_varb=std(division_vals_b);
            %              if(length(C_f_indsa)<5||(calc_var+calc_vara+calc_varb)>0.1)
            % the next condition is to exclude the small groups from
            % exiting if they have plausible amount of faces.
            if(length(C_f_indsa)/length(all_faces_in_group)<0.003)
                continue;
            end
        end
        
        if(~isempty(division_vals)|~isempty(division_vals_a)|~isempty(division_vals_b))
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
            
            %             faces_in_others_but_not_in_current(C_f_indsb)=[];
            [~, faces_in_others_but_not_in_current_index_in_group]=intersect(all_faces_in_group,faces_in_others_but_not_in_current);
            %             faces_in_others_but_not_in_current_values(C_f_indsb)=[];
            %             faces_in_others_but_not_in_current_values_a(C_f_indsb)=[];
            %             faces_in_others_but_not_in_current_values_b(C_f_indsb)=[];
            
            estimate_in_current_the_faces_in_others_but_not_in_current=average_div_vals*faces_in_others_but_not_in_current_values;
%             estimate_in_current_the_faces_in_others_but_not_in_current_a=average_div_vals_a*faces_in_others_but_not_in_current_values_a;
%             estimate_in_current_the_faces_in_others_but_not_in_current_b=average_div_vals_b*faces_in_others_but_not_in_current_values_b;
                        estimate_in_current_the_faces_in_others_but_not_in_current_a=faces_in_others_but_not_in_current_values_a;
            estimate_in_current_the_faces_in_others_but_not_in_current_b=faces_in_others_but_not_in_current_values_b;
            
            %             if(sum(estimate_in_current_the_faces_in_others_but_not_in_current>256)>10||sum(estimate_in_current_the_faces_in_others_but_not_in_current_a>256)>10||sum(estimate_in_current_the_faces_in_others_but_not_in_current_b>256)>10)
            %                estimate_in_current_the_faces_in_others_but_not_in_current=(estimate_in_current_the_faces_in_others_but_not_in_current/max(estimate_in_current_the_faces_in_others_but_not_in_current))*255;
            %                estimate_in_current_the_faces_in_others_but_not_in_current_a=(estimate_in_current_the_faces_in_others_but_not_in_current_a/max(estimate_in_current_the_faces_in_others_but_not_in_current_a))*255;
            %                estimate_in_current_the_faces_in_others_but_not_in_current_b=(estimate_in_current_the_faces_in_others_but_not_in_current_b/max(estimate_in_current_the_faces_in_others_but_not_in_current_b))*255;
            %             end
            %             if (oth_f_index==1)
            
            
            %             intermediate=average_div_vals*other_frame_appeared_faces_values(C_f_indsb);
            %             intermediate_a=average_div_vals_a*other_frame_appeared_faces_values_a(C_f_indsb);
            %             intermediate_b=average_div_vals_b*other_frame_appeared_faces_values_b(C_f_indsb);
            %
            %
            %             div_vals_inter=intermediate./current_frame_appeared_faces_values(C_f_indsa);
            %             div_vals_inter_a=intermediate_a./current_frame_appeared_faces_values_a(C_f_indsa);
            %             div_vals_inter_b=intermediate_b./current_frame_appeared_faces_values_b(C_f_indsa);
            %
            %              inter_average_div_vals=median(div_vals_inter);
            %             inter_average_div_vals_a=median(div_vals_inter_a);
            %             inter_average_div_vals_b=median(div_vals_inter_b);
            %
            %             current_frame_appeared_faces_values=inter_average_div_vals*current_frame_appeared_faces_values;
            %             current_frame_appeared_faces_values_a=inter_average_div_vals_a*current_frame_appeared_faces_values_a;
            %             current_frame_appeared_faces_values_b=inter_average_div_vals_b*current_frame_appeared_faces_values_b;
            
            
            current_frame_appeared_faces=[current_frame_appeared_faces;faces_in_others_but_not_in_current];
            current_frame_appeared_faces_values=[current_frame_appeared_faces_values;estimate_in_current_the_faces_in_others_but_not_in_current];
            current_frame_appeared_faces_values_a=[current_frame_appeared_faces_values_a;estimate_in_current_the_faces_in_others_but_not_in_current_a];
            current_frame_appeared_faces_values_b=[current_frame_appeared_faces_values_b;estimate_in_current_the_faces_in_others_but_not_in_current_b];
            
            
            %             end
            indexes_of_column_from_big_array=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+2;
    
            indexes_of_elements_in_big_array=sub2ind(size(estimated_values_for_unappeared_face),faces_in_others_but_not_in_current_index_in_group,indexes_of_column_from_big_array);

            %             if(sum(estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)>-1)>0)
            %                 d=[];
            %             end
            estimated_values_for_unappeared_face(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current;
            estimated_values_for_unappeared_face_a(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current_a;
            estimated_values_for_unappeared_face_b(indexes_of_elements_in_big_array)=estimate_in_current_the_faces_in_others_but_not_in_current_b;
            estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)=estimated_values_for_unappeared_face(faces_in_others_but_not_in_current_index_in_group,1)+1;
%             flag_for_knowing_that_it_did_not_find_any_correspondence_at_any_frame=1;
        end
    end
    %new test it could not be ok and could be ^_^
    %     new_group.frame(current_frame).faces=current_frame_appeared_faces;
    %     new_group.frame(current_frame).values=current_frame_appeared_faces_values;
    %     new_group.frame(current_frame).values_a=current_frame_appeared_faces_values_a;
    %     new_group.frame(current_frame).values_b=current_frame_appeared_faces_values_b;
    %
    
    % %     aa=unique(temp_all_appeared_faces_to_check_error);
    %     [~,un_app_in_cur_inds_in_big_array]=intersect(all_faces_in_group,current_frame_UN_appeared_faces);
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
    
    %     if(size(estimated_values_for_unappeared_face,2)>1) % try to be sure that the array contain the 2nd dimention as it may be that this group appeared in only one frame.
    %         fin_estimated=estimated_values_for_unappeared_face(un_app_in_cur_inds_in_big_array,2);
    %         fin_estimated_a=estimated_values_for_unappeared_face_a(un_app_in_cur_inds_in_big_array,2);
    %         fin_estimated_b=estimated_values_for_unappeared_face_b(un_app_in_cur_inds_in_big_array,2);
    %         current_frame_UN_appeared_faces(fin_estimated==-1)=[];
    %         fin_estimated(fin_estimated==-1)=[];
    %         fin_estimated_a(fin_estimated_a==-1)=[];
    %         fin_estimated_b(fin_estimated_b==-1)=[];
    
    
%             new_group.frame(current_frame).faces=[new_group.frame(current_frame).faces;current_frame_UN_appeared_faces];
%             new_group.frame(current_frame).values=[new_group.frame(current_frame).values;fin_estimated];
%             new_group.frame(current_frame).values_a=[new_group.frame(current_frame).values_a;fin_estimated_a];
%             new_group.frame(current_frame).values_b=[new_group.frame(current_frame).values_b;fin_estimated_b];
%     to_check_all_vals(new_group.frame(current_frame).faces,frame_index)=new_group.frame(current_frame).values;
    
    new_group.frame(current_frame).faces=current_frame_UN_appeared_faces;
    new_group.frame(current_frame).values=fin_estimated;
    new_group.frame(current_frame).values_a=fin_estimated_a;
    new_group.frame(current_frame).values_b=fin_estimated_b;
    
    %     end
end
d=[];