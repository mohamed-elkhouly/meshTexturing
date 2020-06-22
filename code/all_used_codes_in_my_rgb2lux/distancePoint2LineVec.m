function [d, C, t0] = distancePoint2LineVec(A, B, P, varargin)
% distancePoint2Line  Calculate the distance between a point and a line
%   D = distancePoint2Line(A, B, P) returns the distance from point P to the
%   line through A and B in an N-dimensional space. 
%
%   D = distancePoint2Line(A, B, P, LineType) returns the distance from 
%   point P to 
%   - a line through A and B, 
%   - a ray which starts at A and passes through B, or 
%   - a line segment AB.
%   The definition of distance D depends on LineType, see below.
%
%   [D, C, t0] = distancePoint2Line(A, B, P, ..) returns in addition the 
%   closest point C and the running parameter t0 that defines the intersection  
%   point of the line through A,B and the perpendicular through P. The 
%   definition of closest point depends on LineType, see below. 
%
%   Definitions of distance (D) and closest point (C):
%
%   If LineType is 'line' (the default):
%   - C is the intersection point.
%   - D is the distance from P to closest point C.  
% 
%   If LineType is 'segment', there are two cases:
%   (1) the intersection point is on line segment AB
%       - C is the intersection point, 
%       - D is the distance from P to the closest point C.
%   (2) the intersection point is outside line segment AB
%       - closest point C is the end of the segment,
%       - D is the distance from P to the end of the segment.
%
%   If LineType is 'ray', there are two cases:
%   (1) the intersection point is on the ray through A and B
%       - C is the intersection point, 
%       - D is the distance from P to the closest point C.
%   (2) the intersection point is not on the ray (behind source A)
%       - C is the source at point A,
%       - D is the distance from P to the source at point A.
%
% Inputs:
%   A	     Starting point. N-element vector.
%   B        End point. N-element vector.
%   P        Independent point. N-element vector.
%   LineType Line type definition: 'line' (default), 'segment' or 'ray'.
% 
% Outputs:
%   D        Distance between the independent point and the line, segment or ray. Scalar.
%   C        Point on the line, segment or ray closest to the independent point. N-element vector.
%   t0       Running parameter that defines the intersection point of the line through
% 			 A and B and the perpendicular through P. At point A, t0 = 0. At point B, t0 = 1. Scalar. 
%
% Example:
%    A = [1, 1];
%    B = [5, 4];
%    P = [-1, 2];
%    % To calculate distance from P to line through A and B:
%    [D, C, t0] = distancePoint2Line(A, B, P)
%    % To calculate distance from P to segment AB: 
%    [D, C, t0] = distancePoint2Line(A, B, P, 'segment')
%
% For more information and background, see the <a href="matlab: web('http://monkeyproofsolutions.nl/en/how-to-calculate-the-shortest-distance-between-a-point-and-a-line', '-browser')">MonkeyProof blog item</a>.

% Copyright (C) 2008-2016 MonkeyProof Solutions BV

%% Checks: 
% - number of inputs
narginchk(3, 4);

% % - points defined as vectors
% if ~(isvector(A) && isvector(B) && isvector(P))
%     error('distancePoint2Line:InvalidVectorInput', ...
%             'Points A, B and P should be defined as vectors.');
% end
% 
% % - points all defined in N-dimensional space
% N = length(A); 
% if ~(length(B) == N && length(P) == N)
%     error('distancePoint2Line:VectorLengthMismatch', ...
%             'A, B and P should be vectors of the same length.');
% end
% 
% % - at least a 2D problem
% if N < 2
%      error('distancePoint2Line:VectorLengthLimit', ...
%             'Vectors A, B and P must have 2 or more elements.');
% end

% - lineType definition
if (nargin < 4)
    lineType = 'line';
else
    lineType = varargin{1};
    if ~ischar(lineType)
        error('distancePoint2Line:InvalidLineType', ...
            'Line type must be a character array.'); 
    end
    if ~any(strcmp(lineType, {'line', 'segment', 'ray'}))
        error('distancePoint2Line:LineTypeNotSpecified', ...
            ['Line type "' lineType '" is not recognized as a valid entry.']);
    end
end

%% Algorithm

[~,indx]=ismember(A,P,'rows');

if indx ~= 0
    P(indx,:) = Inf;
end

% Direction vector 
% M = B - A;
% M = bsxfun(@minus, B, A); 
M = B;

% Running parameter t0 defines the intersection point of line through A and B
% and the perpendicular through P
% t0  = dot(M, P - A) / dot(M, M);
K = bsxfun(@minus, P, A);
V = M*K.';
U = M*M.';
t0 = bsxfun(@rdivide, V, diag(U));
t0 = t0(:);

% Intersection point of the perpendicular and line through A and B
% intersectPnt = A + t0 * M;
mul = bsxfun(@times, repmat(M, [size(P,1) 1]), t0);
intersectPnt = bsxfun(@plus, repmat(A, [size(t0,1) 1]), mul);

C = intersectPnt;

idx = find(t0<0);
idx2 = find(t0>1);
% C(idx,:) = repmat(A,[size(idx,1) 1]);

switch lower(lineType)
    case 'line'
        % Line: intersection point is always closest.
        C   = intersectPnt;

    case 'segment'
        % Line segment
%         if t0 < 0
            % Start point is closest.
%             C   = A;
            C(idx,:) = repmat(A,[size(idx,1) 1]);
%         elseif t0 > 1
            % End point is closest.
%             C   = B;
            C(idx2,:) = repmat(B,[size(idx2,1) 1]);
%         else
            % Intersection point is closest.
%             C   = intersectPnt;
%         end     
    
    case 'ray'
        % Ray
%         if t0 < 0
            % Start point is closest.
%             C   = A;
%             C   = Inf;
%         else
            % Intersection point is closest.
%             C   = intersectPnt;
%         end
        C(idx,:) = repmat([Inf Inf Inf],[size(idx,1) 1]);
    
end

% Distance between independent point and closest point
% d   = norm(P-C);
d = pdist2(P,C);

%% https://stackoverflow.com/questions/49231667/how-to-efficiently-get-a-multivalue-diagonal-of-a-non-square-matrix/49244933#49244933
% method 1
d = d(sub2ind(size(d), repmat((1:size(d,1)).', 1, size(B,1)), (1:size(B,1))+((1:size(B,1):size(d,2))-1).'));

% % or 
% 
% % method 2
% % Define the script parameters...
% k = size(B,1);
% n = size(d,2) / k;
% 
% % Create the auxiliary matrix for indexing...
% aux = repmat({ones(1,k)},1,n);
% idx = blkdiag(aux{:});
% 
% % Extract the elements using the indexing and properly reshape the result...
% d = reshape(d(logical(idx)),k,size(d,1)).';

%% 
C = permute(reshape(C, size(B,1), size(P,1), []), [2 1 3]);
t0 = reshape(t0, size(B,1), size(P,1))';
end