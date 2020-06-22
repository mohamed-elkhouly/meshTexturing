function [A0,Xr,Yr,Xc,Yc] = isocell_distribution(Nobj,N0,isrand)
%
% Distribute points on a unit circle according to the Isocell method; the circle
% is divided into cells of equal area and a point is created in each cell; this
% method is useful to distribute rays uniformely in space.
%
% Syntax:
%
%   [A0,Xr,Yr[,Xc,Yc]] = isocell_distribution(Nobj,N0,isrand)
%
% Inputs args are:
%   Nobj    the objective number of cells/points
%   N0      the initial division (the number of cells near the center)
%   isrand  indicates if the points are set randomly or not in each cell
%             -1,0    point is set on cell middle point
%                1    point is set randomly in its cell
%                2    point is set randomly (only along radial dir.)
%                3    point is set randomly with a greater probability in the center
%                4    point is set randomly (only along radial dir.)
%
% Outputs args are:
%
%   A0      the cell area (also the weight of each point)
%   Xr,Yr   are the coordinates of the distributed points
%   Xc,Yc   are the coordinates of the cells borders
%
% Example: distribute at least 200 points on the unit circle with no random
%
%   >> [A0,Xr,Yr,Xc,Yc]=isocell_distribution(200,3,0);
%   >> figure
%   >> plot(Xc,Yc,'b')
%   >> hold on
%   >> plot(Xr,Yr,'.r')
%   >> axis equal

%   >> dirk = [Xr; Yr; sqrt(1-Xr.^2-Yr.^2)];
%   >> dirk = dirk';
%   >> figure, plot_vertices(dirk);
%
%  Luc Masset (2009)

%output
varargout=cell(1,nargout);

%output drawing (nargout > 3)
isdraw=0;
if nargout > 3,
 isdraw=1;
end

%args
if nargin < 1, 
 Nobj=10000;
end
if nargin < 2,
 N0=3;
end
if nargin < 3,
 isrand=3;
end

%Number of divisions
n=sqrt(Nobj/N0);
n=ceil(n);
Ntot=N0*n^2;

%init
Xr=zeros(1,Ntot);
Yr=zeros(1,Ntot);
Rr=zeros(1,Ntot);
Tr=zeros(1,Ntot);
Xc=[];
Yc=[];

%cell area
A0=pi/Ntot;

%distance between circles
dR=1/n;

%rings
nn=0;
if isdraw,
 nu=10;
 uu=(0:nu)';
 uu=uu/nu;
end
for i=1:n,
 R=i*dR;
 nc=N0*(2*i-1);
 dth=2*pi/nc;
 th0=rand(1)*dth;
 if isrand == -1,
  th0=0;
 end
 th0=th0+(0:nc-1)*dth;
 ind=nn+(1:nc);
 switch isrand,
 case 1,
  R=R-rand(1,nc)*dR;
  th=th0+rand(1,nc)*dth;
 case 2,
  R=R-rand(1,nc)*dR;
  th=th0+dth/2;
 case 3,
  rr=(1+randn(1,nc)/6.5)/2;
  R=R-rr*dR;
  rr=(1+randn(1,nc)/6.5)/2;
  th=th0+rr*dth/2;
 case 4,
  rr=(1+randn(1,nc)/6.5)/2;
  R=R-rr*dR;
  th=th0+dth/2;
 otherwise
  R=R-dR/2;
  th=th0+dth/2;
 end
 Xr(ind)=R.*cos(th);
 Yr(ind)=R.*sin(th);
 nn=nn+nc;
 if isdraw,
  Rext=i*dR;
  tt=(0:0.5:360)/180*pi;
  Xc=[Xc NaN Rext*cos(tt)];
  Yc=[Yc NaN Rext*sin(tt)];
  rr=Rext-uu*dR;
  xx=[rr*cos(th0);NaN*ones(1,nc)];
  yy=[rr*sin(th0);NaN*ones(1,nc)];
  xx=reshape(xx,1,(nu+2)*nc);
  yy=reshape(yy,1,(nu+2)*nc);
  Xc=[Xc NaN xx];
  Yc=[Yc NaN yy];
 end
end

%outputs
if nargout >= 1,
 varargout{1}=A0;
end
if nargout >= 2,
 varargout{2}=Xr;
end
if nargout >= 3,
 varargout{3}=Yr;
end
if nargout >= 4,
 varargout{4}=Xc;
end
if nargout >= 1,
 varargout{5}=Yc;
end

return