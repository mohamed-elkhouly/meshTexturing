function vertices_groups=prepare_vertices_groups(vertices_groups)
final_vertices_groups=zeros(vertices_groups(end),1);
for i=1:length(vertices_groups)-1
 final_vertices_groups(vertices_groups(i)+1:vertices_groups(i+1))=i;   
end
vertices_groups=final_vertices_groups;
d=[];
