function final_regions_connections=organize_regions_to_be_balanced(faces_correspondences,~,number_of_faces,region_faces)
% at first we will know each face belong to which region.
face_in_region=zeros(number_of_faces,1);
for i=1:length(region_faces)
    faces_in_current_region=cell2mat(region_faces(i));
    face_in_region(faces_in_current_region)=i;
end
% then we will have an array of all regions connected to current region
region_connections=[];
for i=1:length(faces_correspondences)
    current_group_faces=cell2mat(region_faces(i));
    flag_faces_of_current_group=false(number_of_faces,1);
    flag_faces_of_current_group(current_group_faces)=1;
    current_faces_correspondences=cell2mat(faces_correspondences(i));
    current_faces_correspondences=current_faces_correspondences(:,1:2);
    temp_ff=sum(flag_faces_of_current_group(current_faces_correspondences),2)>0;
    current_faces_correspondences=current_faces_correspondences(temp_ff,:);
    current_faces_correspondences(flag_faces_of_current_group(current_faces_correspondences))=[];
    other_reg_faces=current_faces_correspondences;
    connected_regions=unique(face_in_region(other_reg_faces));
    connected_regions(connected_regions==0)=[];
    region_connections(i,1:length(connected_regions))=connected_regions;
end
back=region_connections;
temp_regions_connections=[];
while(1)
    [row]=find(region_connections,1);
    if(~isempty(row))
        to_be_placed=[row,region_connections(row,:)];
        to_be_placed(to_be_placed==0)=[];
       temp_regions_connections (size(temp_regions_connections,1)+1,1:length(to_be_placed))=to_be_placed;
       region_connections(to_be_placed,:)=0;
    else
        break;
    end
end
final_regions_connections(1,:)=temp_regions_connections(1,:);
final_regions_connections(final_regions_connections==0)=[];
final_regions_connections=prepare_next_connections(final_regions_connections,temp_regions_connections,{});
d=[];