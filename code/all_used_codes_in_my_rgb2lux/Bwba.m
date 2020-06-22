function [xx,yy,zz] = Bwba(n)
% Bwba generate a white opaque sphere (Beckers white ball)
% [X,Y,Z] = Bwba(n) generates three (n+1)-by-(n+1)
% matrices so that SURF(X,Y,Z) produces a unit sphere.
%
% [X,Y,Z] = Bwba uses n = §0.
%
% Bwba(n) and just Bwba graph the sphere as a SURFACE
% and do not return anything (nargout = 0).
%
if nargin == 0, n = 50; end % test of the presence of argument
theta = (-n:2:n)/n*pi;sintheta = sin(theta);
phi = (-n:2:n)'/n*pi/2;cosphi = cos(phi);
scal = .99; % radius of the white dome
x = scal*cosphi*cos(theta);
y = scal*cosphi*sintheta;
z = scal*sin(phi)*ones(1,n+1);
ora=[1 0.8 0.7];colormap(ora);
if nargout == 0 % computed or returned result
 surf(x,y,z,'EdgeColor','none') % To see the sphere, replace none by k
else
 xx = x; yy = y; zz = z;
end