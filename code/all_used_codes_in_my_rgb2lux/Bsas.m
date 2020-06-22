function [drays] = Bsas(S)
Nc = size(S,2)-1; % Size of the interior points set
Nt = max(S); % Number of cells in the hemisphere
aleax=rand(Nt);aleay=rand(Nt); % Random vectors
R = S(2:Nc)-S(1:Nc-1) ; % Definition of the rings
t = acos(1-2*S/Nt); % From disk equal area to 3D
la=zeros(Nt,1);lo=zeros(Nt,1);n=1;
for i = 1 : Nc-1; % Drawing the meridians segments
 lp = 0.;
 for j = 1 : R(i);
 longi = j*2*pi/R(i);
 n=n+1;la(n)=t(i)+aleax(n)*(t(i+1)-t(i));
 lo(n)=lp +aleay(n)*(longi-lp);lp=longi;
 end
end;
la(Nt)=pi;lo(Nt)=0;drays=[la lo];
end