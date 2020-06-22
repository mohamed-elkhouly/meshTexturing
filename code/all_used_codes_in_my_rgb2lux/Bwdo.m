function [xx,yy,zz] = Bwdo(n)
% Bwdo generate a white opaque dome (Beckers white dome)
% [X,Y,Z] = Bwdo(n) generates three (n+1)-by-(n+1)
% matrices so that SURF(X,Y,Z) produces a unit hemispherical dome.
%
% [X,Y,Z] = Bwdo uses n = 20.
%
% Bwdo(n) and just Bwdo graph the sphere as a SURFACE
% and do not return anything (nargout = 0).
%
if nargin == 0, n = 50; end % tests the presence of argument
theta = (-n:2:n)/n*pi;phi = (0:1:n)'/n*pi/2;
cosphi = cos(phi) ; cosphi(1) = 1; cosphi(n+1) = 0;
sintheta = sin(theta); sintheta(n+1) = 0;
scal = .99; % radius of the white dome
x = scal*cosphi*cos(theta);
y = scal*cosphi*sintheta;
z = scal*sin(phi)*ones(1,n+1);
blue=[0.7 0.95 0.95];colormap(blue);%blue dome or white: colormap(white)
if nargout == 0 % computed or returned result
 surf(x,y,z,'EdgeColor','none')
else
 xx = x; yy = y; zz = z;
end