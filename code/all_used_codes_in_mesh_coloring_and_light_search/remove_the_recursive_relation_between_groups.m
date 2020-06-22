function [max_val,copy_all_correspondences,unique_pairs_and_correspondences]=remove_the_recursive_relation_between_groups(max_val,copy_all_correspondences)
max_val_copy=max_val;
max_val_copy(:,1)=[];
inds_of_max_col=max_val_copy(:,2);
max_val_copy(:,2)=[];
[sorted_groups_inds,orig_order_in_max_val_copy]=sort(max_val_copy,2);
[unique_pairs,~,~]=unique(sorted_groups_inds,'rows');
sorted_groups_inds=sorted_groups_inds';
% max_groups_numbers=sorted_groups_inds((orig_order_in_max_val_copy==inds_of_max_col)');
max_groups_numbers=max_val_copy(:,1);
sorted_groups_inds=sorted_groups_inds';
% unique_pairs_and_correspondences=[unique_pairs,zeros(size(unique_pairs,1),1)];
unique_pairs_and_correspondences=zeros(size(max_val_copy,1),3);
for i=1:size(unique_pairs,1)
    current_pair=unique_pairs(i,:);
    mode_group=mode(max_groups_numbers(sum(sorted_groups_inds==current_pair,2)==2));
    smaller_value=current_pair;
    smaller_value(smaller_value==mode_group)=[];
    temp_logical=max_groups_numbers(sum(sorted_groups_inds==current_pair,2)==2)==smaller_value;
    temp_val=max_val_copy((sum(sorted_groups_inds==current_pair,2)==2),:);
    temp_val(temp_logical,:)=0;
    max_val_copy((sum(sorted_groups_inds==current_pair,2)==2),:)=temp_val;
    unique_pairs_and_correspondences((sum(sorted_groups_inds==current_pair,2)==2),:)=repmat([current_pair,length(temp_logical)],sum((sum(sorted_groups_inds==current_pair,2)==2)),1);
end
max_val_copy(:,3)=max_val_copy(:,2);
max_val_copy(:,2)=inds_of_max_col;
max_val(:,2:4)=max_val_copy;
copy_all_correspondences(max_val(:,2)==0,:)=[];
unique_pairs_and_correspondences(max_val(:,2)==0,:)=[];
max_val(max_val(:,2)==0,:)=[];
d=[];