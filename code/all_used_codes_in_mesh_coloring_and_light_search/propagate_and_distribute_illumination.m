function [new_groups,appeared_groups]=propagate_and_distribute_illumination(groups,all_correspondences,appeared_groups,faces_correspondences,frame_number,mesh,view)
backup_groups=groups;
use_backup=false;
% all_faces_numbers1=[];
all_faces_values1=[];
for group_index=1:length(appeared_groups)
    %     all_faces_numbers1=[all_faces_numbers1;groups(appeared_groups(group_index)).frame(frame_number).faces];
    all_faces_values1=[all_faces_values1;groups(appeared_groups(group_index)).frame(frame_number).values];
    
end

num_val_great_than_255=sum(all_faces_values1>255);

for oo=1:10
    all_faces=[];
    all_values=[];
    difference_threshold=10;
    for i=1:length(appeared_groups)
        cur_gr_faces=groups(appeared_groups(i)).frame(frame_number).faces;
        cur_gr_faces=[cur_gr_faces,ones(size(cur_gr_faces))*appeared_groups(i)];
        cur_gr_values=groups(appeared_groups(i)).frame(frame_number).values;
        all_faces=[all_faces;cur_gr_faces];
        all_values=[all_values;cur_gr_values];
    end
    max_val=int32([]);
    temp=logical([]);
    for i=1:size(all_correspondences,1)
        temp(:,1)=all_faces(:,1)==all_correspondences(i,1);
        temp(:,2)=all_faces(:,1)==all_correspondences(i,2);
        if (abs(all_values(temp(:,1))-all_values(temp(:,2)))>difference_threshold)
            [curr_max,ind]=max([all_values(temp(:,1)),all_values(temp(:,2))]);
            
            curr_ind=all_faces(temp(:,ind),2);
            if(ind==1)
                other_ind=2;
            else
                other_ind=1;
            end
            other_ind=all_faces(temp(:,other_ind),2);
            % the second added column here represent from which group (group number )did we got
            % the max value. while the third added column represent the face which
            % has this max value in all_correspondences, while other_ind represent the other group.
            max_val=[max_val; [curr_max,curr_ind,ind,other_ind]];
        else
            max_val=[max_val; [0,0,0,0]];
        end
    end
    copy_all_correspondences=all_correspondences;
    copy_all_correspondences(max_val(:,1)==0,:)=[];
    max_val(max_val(:,1)==0,:)=[];
    [max_val,copy_all_correspondences,unique_pairs_and_correspondences]=remove_the_recursive_relation_between_groups(max_val,copy_all_correspondences);
    % in the next step I will delete the max faces and keep only the min faces
    copy_all_correspondences(sub2ind(size(copy_all_correspondences),1:size(copy_all_correspondences,1),max_val(:,3)'))=0;
    copy_all_correspondences(copy_all_correspondences(:,1)==0,1)=copy_all_correspondences(copy_all_correspondences(:,1)==0,2);
    copy_all_correspondences(:,2)=[];
    
    
    % aaa=zeros(length(mesh.f),1);
    % aaa(copy_all_correspondences)=255;
    % figure,plot_CAD(mesh.f, mesh.v, '',aaa);
    % delete(findall(gcf,'Type','light'));
    
    change_happened=false;
    new_groups=[];
    for i=1:length(appeared_groups)
        cur_gr_faces=groups(appeared_groups(i)).frame(frame_number).faces;
        cur_gr_values=groups(appeared_groups(i)).frame(frame_number).values;
        [~,ia,ib]=intersect(cur_gr_faces,copy_all_correspondences);
        current_relations=unique_pairs_and_correspondences(ib,:);
        % we will try to stop distributing if there are less than 50% of all
        % correspondences between these two groups to be sure that no noise or
        % recursive operation to the same group will happen.
        unique_relations=unique(current_relations,'rows');
        for j=1:size(unique_relations,1)
            current_relation_groups=unique_relations(j,:);
            all_num_relations=current_relation_groups(3);
            appeared_in=sum(current_relations==current_relation_groups,2)==3;
            if(sum(appeared_in)>(0.5*all_num_relations))
                continue;
            else
                ib(appeared_in)=[];
                ia(appeared_in)=[];
                current_relations(appeared_in,:)=[];
            end
            
        end
        % we will stop distributing if there are less than 5 correspondences to
        % be sure
        
        new_groups(appeared_groups(i)).frame(frame_number).faces=[];
        new_groups(appeared_groups(i)).frame(frame_number).values=[];
        ib(cur_gr_values(ia)==0)=[];
        ia(cur_gr_values(ia)==0)=[];
        if(length(ia)>0)
            %     new_groups(appeared_groups(i)).frame(frame_number).faces=cur_gr_faces(ia);
            %     new_groups(appeared_groups(i)).frame(frame_number).values=cur_gr_values(ia);
            new_groups(appeared_groups(i)).frame(frame_number).faces_index_in_other_group=ia;
            division_vals=double(max_val(ib,1))./cur_gr_values(ia);
            %     cur_gr_faces(ia)=[];
            %     cur_gr_values(ia)=[];
            if(sum(isinf(division_vals))>0)
                d=[];
            end
            division_vals(isinf(division_vals))=[];
            
            
            
            if(~isempty(division_vals))
                average_div_vals=median(division_vals);
                temp_for_values_great_than_255=sum(cur_gr_values>255);
                if(sum((cur_gr_values*average_div_vals)>255)>temp_for_values_great_than_255)
                    division_vals=[];
                    index_of_group_to_be_removed=i;
                    use_backup=true;
                    break;
                end
            end
            
            
            
            if(~isempty(division_vals))
                
                
                average_div_vals=median(division_vals);
                if(average_div_vals<1.001)
                    % this will be the stop condition from iterating and
                    % keep finding changes between groups in the biggest
                    % main loop
                    d=[];
                end
                
                
                change_happened=true;
                new_groups(appeared_groups(i)).frame(frame_number).faces=[new_groups(appeared_groups(i)).frame(frame_number).faces ; cur_gr_faces];
                new_groups(appeared_groups(i)).frame(frame_number).values=[new_groups(appeared_groups(i)).frame(frame_number).values ; cur_gr_values*average_div_vals];
            else
                new_groups(appeared_groups(i)).frame(frame_number).faces=[new_groups(appeared_groups(i)).frame(frame_number).faces ; cur_gr_faces];
                new_groups(appeared_groups(i)).frame(frame_number).values=[new_groups(appeared_groups(i)).frame(frame_number).values ; cur_gr_values];
            end
        else
            new_groups(appeared_groups(i)).frame(frame_number).faces=[new_groups(appeared_groups(i)).frame(frame_number).faces ; cur_gr_faces];
            new_groups(appeared_groups(i)).frame(frame_number).values=[new_groups(appeared_groups(i)).frame(frame_number).values ; cur_gr_values];
        end
    end
    if(use_backup)
        break;
    end
    % all_faces_numbers1=[];
    all_faces_values1=[];
    for group_index=1:length(appeared_groups)
        %     all_faces_numbers1=[all_faces_numbers1;new_groups(appeared_groups(group_index)).frame(frame_number).faces];
        all_faces_values1=[all_faces_values1;new_groups(appeared_groups(group_index)).frame(frame_number).values];
    end
    
    groups=new_groups;
    if(~change_happened)
        break;
    end
end

if(use_backup)
    appeared_groups(index_of_group_to_be_removed)=[];
    [new_groups,appeared_groups]=propagate_and_distribute_illumination(backup_groups,all_correspondences,appeared_groups,faces_correspondences,frame_number,mesh,0);
end

if(view==1)
    % for viewing purpose
    % frame_number=32;%32,469,648,664,665
    all_faces_numbers1=[];
    all_faces_values1=[];
    for group_index=1:length(appeared_groups)
        all_faces_numbers1=[all_faces_numbers1;new_groups(appeared_groups(group_index)).frame(frame_number).faces];
        all_faces_values1=[all_faces_values1;new_groups(appeared_groups(group_index)).frame(frame_number).values];
        
    end
    aaa=zeros(length(mesh.f),1);
    aaa(all_faces_numbers1)=all_faces_values1;
    figure,plot_CAD(mesh.f, mesh.v, '',aaa);
    delete(findall(gcf,'Type','light'));
end
d=[];
% all_faces_numbers=[];
% all_faces_values=[];
% for group_index=1:length(appeared_groups)
%     all_faces_numbers=[all_faces_numbers;groups(appeared_groups(group_index)).frame(frame_num).faces];
%     all_faces_values=[all_faces_values;groups(appeared_groups(group_index)).frame(frame_num).values];
%
% end
% aaa=zeros(length(mesh.f),1);
% aaa(all_faces_numbers)=all_faces_values;
% figure,plot_CAD(mesh.f, mesh.v, '',aaa);
% delete(findall(gcf,'Type','light'));