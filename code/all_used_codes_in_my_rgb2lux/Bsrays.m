function [] = Bsrays(colo)
b=(0:5:360)*pi/180; % Definition of the base disk
x = cos(b);y = sin(b);z = zeros(size(b,2));plot3(x,y,z,'k'); hold on;
la = colo(:,1);lo=colo(:,2);
plot3(sin(la).*cos(lo),sin(la).*sin(lo),cos(la),'.k'); hold on;
if la(size(la,1)) > pi/2;
 Bwba(50);hold on;axis equal;axis off; % White sphere
else
 Bwdo(50);hold on;axis equal;axis off; % White dome
end
end