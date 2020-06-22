function [M, I] = permn2(X, N)
    C = cell(1, N); 
    X = X(:); 
    L = length(X); 
    s(1:N - 1) = L; 
    X = reshape(X(:, ones(1, prod(s))), [L, s]); 
    C{N} = X; 
    for iC = 2:N 
        C{N - iC + 1} = permute(X, [2:iC, 1, iC + 1:N]); 
    end 
    M = reshape(cat(N+1, C{:}), [], N); 
    M = M(M(:,1) ~= M(:,2) & M(:,1) ~= M(:,3) & M(:,2) ~= M(:,3),:);
end

% see also 
% permn, allcomb