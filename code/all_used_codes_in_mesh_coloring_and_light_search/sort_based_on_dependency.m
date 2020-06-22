function [sorted_overlapping_mat,sorted_to_be_modified_textures]=sort_based_on_dependency(overlapping_mat,to_be_modified_textures)
ready_text=find(overlapping_mat==1);
sorted_to_be_modified_textures=ready_text;
dependant=find(overlapping_mat~=1);
while(~isempty(dependant))
    dependant_on=overlapping_mat(dependant);
    [val,ind]=intersect(dependant_on,sorted_to_be_modified_textures);
    sorted_to_be_modified_textures=[sorted_to_be_modified_textures,dependant(ind)];
    dependant(ind)=[];
end
sorted_overlapping_mat=overlapping_mat(sorted_to_be_modified_textures);
sorted_to_be_modified_textures=to_be_modified_textures(sorted_to_be_modified_textures);