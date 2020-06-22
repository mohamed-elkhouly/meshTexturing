function [connected_regions_numbers,connected_regions_count]=count_regions_to_regions_correspondences(border_pixels_correspondences)
regions_numbers=unique(border_pixels_correspondences(:,1:2));
connected_regions_numbers=zeros(length(regions_numbers),20);
connected_regions_count=zeros(length(regions_numbers),20);
for i=1:length(regions_numbers)
    current_region=regions_numbers(i);
    current_region_existed_in_rows=sum(border_pixels_correspondences(:,1:2)==current_region,2)>0;
    rows_of_existence=border_pixels_correspondences(current_region_existed_in_rows,1:2);
    unique_regions_numbers=unique(rows_of_existence(:));
    unique_regions_numbers(unique_regions_numbers==current_region)=[];
    connected_regions_numbers(current_region,1:length(unique_regions_numbers))=unique_regions_numbers;
    for j=1:length(unique_regions_numbers)
        connected_regions_count(current_region,unique_regions_numbers==unique_regions_numbers(j))=sum(rows_of_existence(:)==unique_regions_numbers(j));
    end
    
end