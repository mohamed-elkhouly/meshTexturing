%% Using it as anonymous functions

% isInFOV = @(b, a, na) (acosd(dot(b-a, na)./norm(b-a)) <= 90);
% isPointingToward = @(b, a, nb) (dot(a-b, nb)./norm(a-b) > 0);
% isFacing = @(a, na, b, nb) (isInFOV(b, a, na) && isPointingToward(b, nb, a));

%% and as normal function
function index = isFacing(a, na, b, nb)

  V = bsxfun(@minus, b, a);                     % Compute b-a for all b
  V = bsxfun(@rdivide, V, sqrt(sum(V.^2, 2)));  % Normalize each row
  index = (acosd(V*na.') <= 90);                % Find points in FOV of a
  index(index) = (sum(V(index, :).*nb(index, :), 2) < 0);  % Of those points in FOV,
                                                           %   find those pointing
                                                           %   towards a

end

% https://stackoverflow.com/questions/49132597/determine-whether-two-points-with-known-normals-are-facing-each-other-or-not-ma/49134658?noredirect=1#comment85281692_49134658