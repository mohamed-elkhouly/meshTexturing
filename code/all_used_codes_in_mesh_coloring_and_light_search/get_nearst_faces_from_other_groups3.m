function nearest_faces_to_current_group_faces=get_nearst_faces_from_other_groups3(region_faces,~,mesh_faces,current_group_faces,other_groups_faces,centroids,normals,distance_threshold,behind_threshold,~)

% region_name=['region',num2str(region_number),'.mat'];
% load(['prepared',region_name]);

temp_faces_numbers=(1:size(mesh_faces,1))';temp_faces_numbers=[temp_faces_numbers,temp_faces_numbers,temp_faces_numbers];temp_faces_numbers=temp_faces_numbers(:);
vertices_indices=mesh_faces;vertices_indices=vertices_indices(:);
vertex_faces=zeros(max(vertices_indices),20);
while(1)
    [unique_verts,inda]=unique(vertices_indices);
    big_arr_indices=sub2ind(size(vertex_faces),unique_verts,(vertex_faces(unique_verts,1)+2));
    vertex_faces(big_arr_indices)=temp_faces_numbers(inda);
    vertex_faces(unique_verts,1)=vertex_faces(unique_verts,1)+1;
    temp_faces_numbers(inda)=[];
    vertices_indices(inda)=[];
    if(isempty(vertices_indices))
        break;
    end
end
vertex_faces(:,1)=[];



original_num_verts=size(vertex_faces,1);
nearest_faces_to_current_group_faces=double([]);
for i_index=1:length(current_group_faces)
    old_faces=current_group_faces(i_index);
    current_faces=current_group_faces(i_index);
    old_centers=centroids(old_faces,:);
    current_centers=centroids(current_faces,:);
    old_distances=0;
    current_distances=old_distances+norm(current_centers-old_centers,2);
    excluded_face=region_faces;
    current_faces_vertices=mesh_faces(current_faces,:);
    old_distances=repmat(current_distances,[1,3]);
    old_faces=repmat(current_faces,[1,3]);
    current_faces_vertices=current_faces_vertices(:);
    old_distances=old_distances(:);
    old_faces=old_faces(:);
    
    
    while(1)
        if(isempty(current_faces_vertices))
            nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
            break;
        end
        old_distances(current_faces_vertices>original_num_verts)=[];
        old_faces(current_faces_vertices>original_num_verts)=[];
        current_faces_vertices(current_faces_vertices>original_num_verts)=[];
        [current_faces_vertices,ia,~]=unique(current_faces_vertices);
        old_distances=old_distances(ia);
        old_faces=old_faces(ia);
        current_faces=vertex_faces(current_faces_vertices,:);
        old_distances=repmat(old_distances,[1,100]);
        old_faces=repmat(old_faces,[1,100]);
        [current_faces,ia,~]=unique(current_faces(:));
        old_distances=old_distances(ia);
        old_distances(current_faces==0)=[];
        old_faces=old_faces(ia);
        old_faces(current_faces==0)=[];
        current_faces(current_faces==0)=[];
        [~,inds]=intersect(current_faces,excluded_face);
        current_faces(inds)=[];
        old_distances(inds)=[];
        old_faces(inds)=[];
        [faces_indexes,~]=intersect(current_faces,other_groups_faces);
        
        old_centers=centroids(old_faces,:);
        current_centers=centroids(current_faces,:);
        current_distances=old_distances+norm(current_centers-old_centers,2);
        [min_val,~]=min(current_distances);
        if(min_val>distance_threshold)
            nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
            break;
        end
        
        current_faces(current_distances>distance_threshold)=[];
        current_distances(current_distances>distance_threshold)=[];
        
        old_distances=repmat(current_distances,[1,3]);
        old_distances=old_distances(:);
        old_faces=repmat(current_faces,[1,3]);
        old_faces=old_faces(:);
        
        
        
        
        %         vertices_indexes=vertices_indexes(inds);
        %         i want to add here the distance based on the propagation through vertices.
        if(~isempty(faces_indexes))
            checker_val=faces_indexes(1);
            plan_center=centroids(current_group_faces(i_index),:);
            faces_centers=centroids(faces_indexes,:);
            plan_normal=normals(current_group_faces(i_index),:);
                        faces_normals=normals(faces_indexes,:);
            %%%%%%%%%%%5
            %             not_behind_faces_indexes=test_behind_plan(plan_center,plan_normal,faces_centers,faces_normals,faces_indexes,behind_threshold);
            neg_ind22 = isFacing(plan_center, plan_normal, faces_centers, faces_normals);
            projected_points=projection_of_points_on_a_plane(faces_centers,plan_center,plan_normal);
            projected_distances=vecnorm(projected_points-faces_centers,1,2);
            faces_indexes(~(projected_distances<behind_threshold|neg_ind22))=[];
            if ~isempty(faces_indexes)
                 if isempty(faces_indexes)
                      nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
                    break;
                 end
                
                distances=sum((centroids(current_group_faces(i_index),:)-centroids(faces_indexes(:),:)).^2,2);
                [min_val,ind]=min(distances);
                
                if(min_val>distance_threshold)
                    nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
                    break;
                end
                nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),faces_indexes(ind),min_val];
                break;
            else % we will make early break condition to stop iterate if the face has no near neighbors
                distances=sum((centroids(current_group_faces(i_index),:)-centroids(checker_val(:),:)).^2,2);
                [min_val,~]=min(distances);
                if(min_val>distance_threshold)
                    nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
                    break;
                end
            end
        end
        % here I want to add a condition to push faces to find nearest
        % faces without passing through other faces from their group by
        % excluding the faces of current_group_faces from current_faces
        % using intersection, check also do we have to do this before
        % adding excluded_face or after it.
        current_faces_vertices=mesh_faces(current_faces,:);
        current_faces_vertices=current_faces_vertices(:);
        excluded_face=unique([excluded_face;current_faces(:)]);
        %         current_faces=
    end
end