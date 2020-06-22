function [faces_correspondences,all_used_edge_faces]=find_nearest_faces_from_other_groups2(mesh,regions_edge_faces,region_faces,region_number,tempmesh_faces,dot_prod_matrix,plot_lines)
distance_threshold=0.3;
behind_threshold=0.001;
faces_correspondences={};
other_regions_faces_back=cell2mat(regions_edge_faces(:));

tic
for i=1:length(regions_edge_faces)
    other_groups_faces=other_regions_faces_back;
    others_indexes=1:length(regions_edge_faces);
    current_group_faces=cell2mat(regions_edge_faces(i));
    
    others_indexes(i)=[];
    [~,idxs]=intersect(other_groups_faces,current_group_faces,'stable');
    other_groups_faces(idxs)=[];
    nearest_faces_to_current_group_faces=get_nearst_faces_from_other_groups3(cell2mat(region_faces(i)),region_number,tempmesh_faces,current_group_faces,other_groups_faces,mesh.centroids,mesh.normals,distance_threshold,behind_threshold,dot_prod_matrix);
    nearest_faces_to_current_group_faces(nearest_faces_to_current_group_faces(:,2)==0,:)=[];
    unique_target_faces=unique(nearest_faces_to_current_group_faces(:,2));
    %     the next first for loop is to make the relations between faces a 1:1 relations and skip over regions connections.
    new_nearest_faces_to_current_group_faces=zeros([length(unique_target_faces),3]);
    for k=1:length(unique_target_faces)
        new_mat=nearest_faces_to_current_group_faces(nearest_faces_to_current_group_faces(:,2)==unique_target_faces(k),:);
        [~,min_ind]=min(new_mat(:,3));
        new_nearest_faces_to_current_group_faces(k,:)=new_mat(min_ind,:);
    end
    faces_correspondences(i)={new_nearest_faces_to_current_group_faces};
    if(plot_lines)
        for j=1:size(new_nearest_faces_to_current_group_faces,1)
            temp=([mesh.centroids(new_nearest_faces_to_current_group_faces(j,1),:);mesh.centroids(new_nearest_faces_to_current_group_faces(j,2),:)]);
            plot3(temp(:,1),temp(:,2),temp(:,3),'y')
        end
    end
end
time_to_plot_lines=toc

all_used_edge_faces=[];
for ert=1:length(faces_correspondences)
    new_nearest_faces_to_current_group_faces=cell2mat(faces_correspondences(ert));
    temp_appeared_edge_faces=new_nearest_faces_to_current_group_faces(:,1:2);
    temp_appeared_edge_faces=[temp_appeared_edge_faces,ones([size(temp_appeared_edge_faces,1),1])*ert];
    all_used_edge_faces=unique([all_used_edge_faces;temp_appeared_edge_faces],'rows');
end