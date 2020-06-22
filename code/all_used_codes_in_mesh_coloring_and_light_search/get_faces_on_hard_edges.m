function [required_edges_faces,required_edges_vertices]=get_faces_on_hard_edges(mesh_faces,mesh_vertices,val)
num_faces=size(mesh_faces,1);
x=mesh_vertices(:,1);
y=mesh_vertices(:,2);
z=mesh_vertices(:,3);
TR = triangulation(double(mesh_faces),x,y,z);
% each value from TR corresponds to a triangle
required_edges_lines = featureEdges(TR,pi/val)';
required_edges_vertices=unique(required_edges_lines(:));
required_edges_faces=false([num_faces 1]);
tic
while(1)
    [~,ind]=intersect(mesh_faces,required_edges_vertices);
    if(isempty(ind))
        break;
    end    
ind=rem(ind,num_faces);
ind(ind==0)=num_faces;
mesh_faces(ind,:)=0;
required_edges_faces(ind)=1;
end
required_edges_faces=find(required_edges_faces);
toc