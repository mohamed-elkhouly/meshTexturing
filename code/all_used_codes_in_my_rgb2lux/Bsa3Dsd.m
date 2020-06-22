function [drays] = Bsa3Dsd(S)
cs = 20;npas=8;b=(0:10:360)*pi/180; % Parameter for the execution
Nc = size(S,2)-1; % Size of the interior points set
Nt = max(S); % Number of cells in the hemisphere
R = S(2:Nc)-S(1:Nc-1) ; % Definition of the rings
t = acos(1-2*S/Nt); % From disk equal area to 3D
r = sin(t);h = cos(t);
for i= 1 : Nc; % Drawing the parallels in axnometric projection
 x = r(i)*cos(b);y = r(i)*sin(b);z = ones(size(b,2))*h(i);
 plot3(x,y,z,'k'); hold on;
end
la=zeros(Nt,1);lo=zeros(Nt,1);n=1;
for i = 1 : Nc-1; % Drawing the meridians segments
 lp = 0.;
 for j = 1 : R(i);
 longi = j*2*pi/R(i);
 lai = t(i);las = t(i+1);pala = (las-lai)/npas;
 mxi = sin(lai:pala:las)*cos(longi);
 myi = sin(lai:pala:las)*sin(longi);
 mzi = cos(lai:pala:las);
 plot3(mxi',myi',mzi','k');hold on
 if nargout >0;
 n=n+1;la(n)=(t(i+1)+t(i))/2;lo(n)=(longi+lp)/2;lp=longi;
 end
 end
end;
la(Nt)=pi;lo(Nt)=0;if nargout > 0;drays=[la lo];end
title(['Equal solid angle sphere composed of ',num2str(Nt),...
 ' elements'],'fontsize',cs);Bwba;hold on;axis equal;axis off;
end