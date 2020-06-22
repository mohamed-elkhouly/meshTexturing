function A=create_A_matrix_for_luminance(faces_correspondences1,number_of_faces,g_indexes_correspondences)

faces_L=faces_correspondences1(:,1);
faces_R=faces_correspondences1(:,2);
indexes=1:size(faces_L,1);
indexes=indexes(:);
rows=[indexes;indexes];
% columns=[g_indexes_correspondences(faces_L);g_indexes_correspondences(faces_R)];
columns=[(faces_L);(faces_R)];
value=[ones(size(faces_L,1),1);-1*ones(size(faces_L,1),1)];
% A=sparse(rows,columns,value,max(rows),max([faces_L;faces_R]));
if(~isempty(rows))
    A=sparse(rows,columns,value,max(rows),max([faces_L;faces_R]));
else
    A=sparse(1,max([faces_L;faces_R]));
end
