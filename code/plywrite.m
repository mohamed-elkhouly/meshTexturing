function plywrite(filename,faces,verts,varargin)
% plywrite(filename,faces,verts)
% Will write a face vertex mesh data in ply format.
% faces -> polygonal descriptions in terms of vertex indices
% verts -> list of vertex coordinate triplets
% faces and verts can be obtained by using the MATLAB isosurface function.
%
% plywrite(filename,faces,verts,rgb)
% Will add color information.
% rgb -> optional list of RGB triplets per vertex
%
% A by-product of ongoing computational materials science research 
% at MINED@Gatech.(http://mined.gatech.edu/)
%
% Copyright (c) 2015, Ahmet Cecen and MINED@Gatech -  All rights reserved.
% Create File
fileID = fopen(filename,'w');
% Plain Mesh
if nargin == 3
    
    % Insert Header
    fprintf(fileID, ...
        ['ply\n', ...
        'format ascii 1.0\n', ...
        'element vertex %u\n', ...
        'property float32 x\n', ...
        'property float32 y\n', ...
        'property float32 z\n', ...
        'element face %u\n', ...
        'property list uint8 int32 vertex_indices\n', ...
        'end_header\n'], ...
        length(verts),length(faces));
    % Insert Colored Vertices
    for i=1:length(verts)
        fprintf(fileID, ...
            ['%.6f ', ...
            '%.6f ', ...
            '%.6f\n'], ...
            verts(i,1),verts(i,2),verts(i,3));
    end
    % Insert Faces
    dlmwrite(filename,[size(faces,2)*ones(length(faces),1),faces-1],'-append','delimiter',' ','precision',10);
% Colored Mesh
elseif nargin == 4
    
    rgb=varargin{1};
    
    % Insert Header
    fprintf(fileID, ...
        ['ply\n', ...
        'format ascii 1.0\n', ...
        'element vertex %u\n', ...
        'property float32 x\n', ...
        'property float32 y\n', ...
        'property float32 z\n', ...
        'property uchar red\n', ...
        'property uchar green\n', ...
        'property uchar blue\n', ...
        'element face %u\n', ...
        'property list uint8 int32 vertex_indices\n', ...
        'end_header\n'], ...
        length(verts),length(faces));
    % Insert Colored Vertices
    for i=1:length(verts)
    fprintf(fileID, ...
        ['%.6f ', ...
        '%.6f ', ...
        '%.6f ', ...
        '%u ', ...
        '%u ', ...
        '%u\n'], ...
        verts(i,1),verts(i,2),verts(i,3),rgb(i,1),rgb(i,2),rgb(i,3));
    end
    % Insert Faces
    dlmwrite(filename,[size(faces,2)*ones(length(faces),1),faces-1],'-append','delimiter',' ','precision',10);
end