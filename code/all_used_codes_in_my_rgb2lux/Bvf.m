function [drays] = Bvf(S)
Nc = size(S,2);Nt = S(Nc);R = S(2:Nc)-S(1:Nc-1);% Definition of the rings
aleax=rand(Nt);aleay=rand(Nt);
r = sqrt(S/Nt);t = asin(r);
la=zeros(Nt,1);lo=zeros(Nt,1);n=1;la(1)=aleax(1)*t(1);lo(1)=aleay(1)*2*pi;
for i = 1 : Nc-1; % Drawing the meridians segments
 lp=0.;
 for j = 1 : R(i);
 longi = j*2*pi/R(i);
 n=n+1;
 la(n)=t(i)+aleax(n)*(t(i+1)-t(i));
 lo(n)=lp +aleay(n)*(longi-lp);lp=longi;
 end
end;
drays=[la lo];
end
