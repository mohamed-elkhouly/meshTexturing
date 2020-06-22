function [ newv, newf, newc, newn, newa ] = subMesh( mesh, face_roi )
%[ submesh, vertmap, facemap ] = subMesh( mesh, face_roi )
%   pick out submesh using face ROI

newverts = [];


newf = mesh.f(face_roi,:);
vert_roi = unique( [newf(:,1); newf(:,2); newf(:,3)] );
newv = mesh.v(vert_roi,:);
newn = [];
if ( ~ isempty(mesh.normals) )
    newn = mesh.normals(face_roi,:);
end
newc = [];
if ( ~ isempty(mesh.centroids) )
    newc = mesh.centroids(face_roi,:);
end

newa = [];
if ( ~ isempty(mesh.areas) )
    newa = mesh.areas(face_roi,:);
end

vertmap = [1:numel(vert_roi); vert_roi']';
facemap = [1:numel(face_roi); face_roi']';

% rewrite face indices
for i = 1:numel(face_roi)
    f = newf(i,:);
    for j = 1:numel(f);
        f(j) = vertmap(find(vertmap(:,2) == f(j)), 1);
    end
    newf(i,:) = f;
end

% submesh = makeMesh(newv, newf, newn, newu);

end