function correspondences=prepare_and_balance(required_matrices,mesh,num_frames)

num_all_faces=size(mesh.f,1);
%% prepare faces vertices correspondences
v1=mesh.f(:,1);v2=mesh.f(:,2);v3=mesh.f(:,3);
faces_indexes=1:num_all_faces;
% vertices_array=[];
col=1;
while(1)
    [verts,inds1]=unique(v1);
    vertices_to_faces(verts,col)=faces_indexes(inds1);
    v1(inds1)=[];
    faces_indexes(inds1)=[];
    col=col+1;
    if(isempty(v1))
        break;
    end
end
faces_indexes=1:num_all_faces;
while(1)
    [verts,inds1]=unique(v2);
    vertices_to_faces(verts,col)=faces_indexes(inds1);
    v2(inds1)=[];
    faces_indexes(inds1)=[];
    col=col+1;
    if(isempty(v2))
        break;
    end
end
faces_indexes=1:num_all_faces;
while(1)
    [verts,inds1]=unique(v3);
    vertices_to_faces(verts,col)=faces_indexes(inds1);
    v3(inds1)=[];
    faces_indexes(inds1)=[];
    col=col+1;
    if(isempty(v3))
        break;
    end
end





%%
nearest_correspondences_matrix=[];
rows_to_be_removed_at_the_end=[];
for i=1:num_frames
    reg1_inds=required_matrices(:,1);
reg2_inds=required_matrices(:,2);
all_inds=[reg1_inds;reg2_inds];
    start_i=num_all_faces*(i-1)+1;
    end_i=num_all_faces*(i);
    flag=all_inds>=start_i&all_inds<=end_i;
    existed_indexes=all_inds(flag);
    existed_indexes=existed_indexes-start_i+1;
    
    faces_vertices=mesh.f(existed_indexes,:);
    faces_flags=[];
    faces_flags(existed_indexes)=1;
    tic
    min_ind=[];
    for j=1:length(existed_indexes)
%         if(j==13518)
%             d=[];
%         end
        current_vertices=faces_vertices(j,:);
        neighbors=vertices_to_faces(current_vertices,:);
        neighbors(neighbors==0)=[];
        neighbors(neighbors==existed_indexes(j))=[];
%         neighbors=unique(neighbors);
        neighbors(neighbors>length(faces_flags))=[];
        existed_neighbors=neighbors(faces_flags(neighbors)>0);
        if(~isempty(existed_neighbors))
            min_ind(j)=existed_neighbors(1);
        else
            depth=1;
            while(1)
                fl=0;
            neighbors=vertices_to_faces(current_vertices,:);
            neighbors(neighbors==0)=[];
        neighbors(neighbors==existed_indexes(j))=[];
        current_vertices=mesh.f(neighbors(:),:);
        neighbors=vertices_to_faces(current_vertices(:),:);
        neighbors(neighbors==0)=[];
        neighbors(neighbors==existed_indexes(j))=[];
%         neighbors=unique(neighbors);
        neighbors(neighbors>length(faces_flags))=[];
        existed_neighbors=neighbors(faces_flags(neighbors)>0);
        if(~isempty(existed_neighbors))
            fl=1;
            min_ind(j)=existed_neighbors(1);
        end
        if(fl==1||depth==1)
            break;
        end
        depth=depth+1;
            end
        end
    end
    
    toc
    all_inds(flag)=min_ind;
    all_inds_1=all_inds(1:length(all_inds)/2)==0;
    all_inds_2=all_inds((length(all_inds)/2+1):end)==0;
    temp_inds=required_matrices(all_inds_1,[1,2]);
    rows_to_be_removed_at_the_end=[rows_to_be_removed_at_the_end;temp_inds(:)];
    required_matrices(all_inds_1,:)=[];
    all_inds_2(all_inds_1)=[];
    temp_inds=required_matrices(all_inds_2,[1,2]);
    rows_to_be_removed_at_the_end=[rows_to_be_removed_at_the_end;temp_inds(:)];
    required_matrices(all_inds_2,:)=[];
    
    existed_indexes(min_ind==0)=[];
    min_ind(min_ind==0)=[];
    
existed_indexes=existed_indexes+start_i-1;
min_ind=min_ind+start_i-1;
nearest_correspondences_matrix(existed_indexes)=min_ind;
if sum(required_matrices(:,1)==10690)>0
% if(nearest_correspondences_matrix(11689)>0)
    d=[];
end

end
% existed_indexes=find(nearest_correspondences_matrix>0);
% nearest_correspondences_matrix=nearest_correspondences_matrix(existed_indexes);
required_matrices=[required_matrices,nearest_correspondences_matrix(required_matrices(:,1))',nearest_correspondences_matrix(required_matrices(:,2))'];
while(1)

% 
all_existed_indices=required_matrices(:,[1,2]);
all_existed_indices=all_existed_indices(:);
min_ind1=required_matrices(:,9);
min_ind2=required_matrices(:,10);
rows_to_be_removed_at_the_end=[min_ind1;min_ind2];
find_in_all_indices=[];
find_in_all_indices(max(all_existed_indices))=0;
for i=1:length(all_existed_indices)
    find_in_all_indices(all_existed_indices(i))=i;
end
rows_to_be_removed_at_the_end2=rows_to_be_removed_at_the_end;
to_be_kept_now=rows_to_be_removed_at_the_end2(rows_to_be_removed_at_the_end2>length(find_in_all_indices));
rows_to_be_removed_at_the_end2(rows_to_be_removed_at_the_end2>length(find_in_all_indices))=[];
rows_to_be_removed_at_the_end2(find_in_all_indices(rows_to_be_removed_at_the_end2)>0)=[];
rows_to_be_removed_at_the_end=[to_be_kept_now;rows_to_be_removed_at_the_end2];





min_ind1=required_matrices(:,9);
min_ind2=required_matrices(:,10);

find_in_min_ind1(max(min_ind1))=0;
for i=1:length(min_ind1)
    find_in_min_ind1(min_ind1(i))=i;
end

find_in_min_ind2(max(min_ind2))=0;
for i=1:length(min_ind2)
    find_in_min_ind2(min_ind2(i))=i;
end
rows_to_be_removed_at_the_end(rows_to_be_removed_at_the_end>length(find_in_min_ind1))=[];
which_row1=find_in_min_ind1(rows_to_be_removed_at_the_end);
which_row2=find_in_min_ind2(rows_to_be_removed_at_the_end);
which_row1=which_row1(which_row1>0);
which_row2=which_row2(which_row2>0);
which_row1=unique([which_row1,which_row2]);
 temp_inds=required_matrices(which_row1,[1,2]);
    rows_to_be_removed_at_the_end=[temp_inds(:)];
     required_matrices(which_row1,:)=[];
     if(isempty(which_row1))
         break;
     end
end
[correspondences]=balancing_regions2(required_matrices);
d=[];
