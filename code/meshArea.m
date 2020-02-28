function [areaTIN] = meshArea(faces, points)
%MESHAREA: Calculate the area of a triangular irregular network
%   INPUT: faces - mx3 face indexes of the mesh
%          points - nx3 vertex data of the mesh
%   OUTPUT: areaTIN - mx1 triangular area measurements matched to faces


% error check
if  size(points, 2) < 3 | size(points, 2) > 3
    error('Inputs must be nx3 vertex / face lists');
end

if  size(faces, 2) < 3 | size(faces, 2) > 3
    error('Inputs must be nx3 vertex / face lists');
end

P0 = points(faces(:,1),:);
P1 = points(faces(:,2),:);
P2 = points(faces(:,3),:);

% compute individual vectors
P10 = bsxfun(@minus, P1, P0);
P20 = bsxfun(@minus, P2, P0);

% cross product
v = cross(P10, P20, 2);

% 3D vector norm to calculate triangle area
areaTIN = sqrt(sum(v.*v, 2))/2;
end