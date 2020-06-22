function dot_prod_matrix=create_dot_prod_matrix(mesh,regions_edge_faces)
tic

[temp_ind_x,temp_ind_y]=find(triu(true(length(regions_edge_faces)),1));
length_of_arrays=0;
for c_ind =1:length(temp_ind_x)
    x_indexes=(cell2mat(regions_edge_faces(temp_ind_x(c_ind))));
    y_indexes=(cell2mat(regions_edge_faces(temp_ind_y(c_ind))));
    length_of_arrays=length_of_arrays+length(x_indexes)*length(y_indexes);
end

% dot_prod_array=zeros;
final_x_indexes_list=zeros([length_of_arrays 1]);
final_y_indexes_list=zeros([length_of_arrays 1]);
final_dot_prod_list=zeros([length_of_arrays 1]);
last_ind=0;

for c_ind =1:length(temp_ind_x)
    x_indexes=(cell2mat(regions_edge_faces(temp_ind_x(c_ind))))';
    y_indexes=(cell2mat(regions_edge_faces(temp_ind_y(c_ind))))';
    temp=combvec(x_indexes,y_indexes);
    x_indexes=(temp(1,:))';
    y_indexes=(temp(2,:))';
    
    final_x_indexes_list(last_ind+1:(last_ind+length(x_indexes)))=x_indexes;
    final_y_indexes_list(last_ind+1:(last_ind+length(x_indexes)))=y_indexes;
    final_dot_prod_list(last_ind+1:(last_ind+length(x_indexes)))=dot(mesh.normals(x_indexes,:),mesh.normals(y_indexes,:),2);
    last_ind=last_ind+length(x_indexes);
end

dot_prod_matrix=sparse(final_x_indexes_list,final_y_indexes_list,final_dot_prod_list,size(mesh.f,1),size(mesh.f,1));
time_to_create_dot_prod_matrix=toc
