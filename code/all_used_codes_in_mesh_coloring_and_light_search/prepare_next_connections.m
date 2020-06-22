function finished_groups=prepare_next_connections(final_regions_connections,temp_regions_connections,finished_groups)
last_connected_regions=final_regions_connections(1,:);
temp_regions_connections(1,:)=[];
while(1)
    [~,inda]=intersect(temp_regions_connections,last_connected_regions);
    if(isempty(inda))
        break;
    end
    [rows,~]=ind2sub(size(temp_regions_connections),inda);
    to_be_placed=temp_regions_connections(rows(1),:);
    to_be_placed(to_be_placed==0)=[];
    final_regions_connections (size(final_regions_connections,1)+1,1:length(to_be_placed))=to_be_placed;
    temp_regions_connections(rows(1),:)=[];
    last_connected_regions=[last_connected_regions(:);to_be_placed(:)];
end

finished_groups (length(finished_groups)+1)={final_regions_connections};
if(~isempty(temp_regions_connections))  
    final_regions_connections=[];
        final_regions_connections(1,:)=temp_regions_connections(1,:);
        final_regions_connections(final_regions_connections==0)=[];
        finished_groups=prepare_next_connections(final_regions_connections,temp_regions_connections,finished_groups);
end