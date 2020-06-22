function nearest_faces_to_current_group_faces=get_nearst_faces_from_other_groups(tempmesh_faces,current_group_faces,other_groups_faces,centroids,normals,distance_threshold,behind_threshold,dot_prod_matrix)
nearest_faces_to_current_group_faces=int32([]);
for i_index=1:length(current_group_faces)
    current_faces=current_group_faces(i_index);
    excluded_face=current_faces;
    current_faces_vertices=tempmesh_faces(current_faces,:);
    current_faces_vertices=current_faces_vertices(:);
    while(1)
        temp1=tempmesh_faces(:,1)==current_faces_vertices';
        temp2=tempmesh_faces(:,2)==current_faces_vertices';
        temp3=tempmesh_faces(:,3)==current_faces_vertices';
        current_faces=find(sum([temp1,temp2,temp3],2)>0);
        [~,inds]=intersect(current_faces,excluded_face);
        current_faces(inds)=[];
        faces_indexes=intersect(current_faces,other_groups_faces);
        
        if(~isempty(faces_indexes))
            checker_val=faces_indexes(1);
            plan_center=mesh.centroids(current_group_faces(i_index),:);
            faces_centers=mesh.centroids(faces_indexes,:);
            plan_normal=mesh.normals(current_group_faces(i_index),:);
%             faces_mesh.normals=mesh.normals(faces_indexes,:);
            %%%%%%%%%%%5
            %             not_behind_faces_indexes=test_behind_plan(plan_center,plan_normal,faces_centers,faces_mesh.normals,faces_indexes,behind_threshold);
            faces_position_relative_to_plan=plan_normal(1).*(faces_centers(:,1)-plan_center(1))+plan_normal(2).*(faces_centers(:,2)-plan_center(2))+plan_normal(3).*(faces_centers(:,3)-plan_center(3));
            % we will exclude faces behind the plane by specific threshold
            faces_indexes(faces_position_relative_to_plan<behind_threshold)=[];
            if ~isempty(faces_indexes)
%             faces_centers(faces_position_relative_to_plan<behind_thresh,:)=[];
%             faces_mesh.normals(faces_position_relative_to_plan<behind_thresh,:)=[];
            faces_position_relative_to_plan(faces_position_relative_to_plan<behind_threshold)=[];
            % exclude faces on or behind threshold but has opposite normal
            % (mesh.normals_state is positive if they are in the same direction negative in
            % opposite direction, and zero if they are prependecular
            val1=dot_prod_matrix(faces_indexes,current_group_faces(i_index));
            val2=dot_prod_matrix(current_group_faces(i_index),faces_indexes);
            val1=[full(val1),full(val2)'];
            [~,dot_indexes]=max(abs(val1),[],2);
            row_indexes=1:size(val1,1);
            ind_from_val1=sub2ind([size(val1,1),2],row_indexes',dot_indexes);
            mesh.normals_state=val1(ind_from_val1);
%             mesh.normals_state=dot(faces_mesh.normals,repmat( plan_normal,[size(faces_mesh.normals,1) 1]),2);
            condition=faces_position_relative_to_plan<=0&mesh.normals_state<0;
            faces_indexes(condition)=[];
%             not_behind_faces_indexes=faces_indexes
            %%%%%%%%%%%%%
            
            distances=sum((mesh.centroids(current_group_faces(i_index),:)-mesh.centroids(faces_indexes(:),:)).^2,2);
            [min_val,ind]=min(distances);
            
                if(min_val>distance_threshold)
                    nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),0,1000];
                     break;
                end
                nearest_faces_to_current_group_faces(i_index,:)=[current_group_faces(i_index),faces_indexes(ind),min_val];
                    break;
            else % we will make early break condition to stop iterate if the face has no near neighbors 
                distances=sum((mesh.centroids(current_group_faces(i_index),:)-mesh.centroids(checker_val(:),:)).^2,2);
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
        current_faces_vertices=tempmesh_faces(current_faces,:);
    current_faces_vertices=current_faces_vertices(:);
    excluded_face=[excluded_face;current_faces(:)];
%         current_faces=
    end
end