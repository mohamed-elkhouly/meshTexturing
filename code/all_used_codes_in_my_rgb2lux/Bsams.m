function [S] = Bsams(nsph)
if nargin == 0;nsph = 290;end; % Input default value
if nsph < 8;nsph=8;end
nsph = round(nsph/2)*2; % Number of cells must be even
idep = nsph/2;tim1=pi/2;rim1=sqrt(2);nim1=idep; % Initializations
nring = floor(sqrt(idep)); % Estimated number of rings
n = zeros(1,nring);nan = 0; % initializations
for i = 1:nring; % Loop on the rings or disks
 n(i) = nim1; % Number of cells in disk i
 ti = tim1-sqrt(2*pi/idep); % Zenithal angle (20)
 ri = 2*sin(ti/2); % equivalent projection (16)
 ni = round(nim1*(ri/rim1)^2); % Number of cells (1)
 nim1 = ni;rim1 = ri;tim1 = ti;
 if nim1 == 2;nim1 = 1;end % Forcing presence of polar disks
 if nim1 == 0;nim1 = 1;end
 if nim1 == 1;if nan == 0;nan = i+1;end;end
end
S = [n(nan:-1:1) 2*n(1)-n(2:nan) nsph];
if size(S,2) < 13;
disp(['SA Sphere sequence of ',num2str(size(S,2)),' layers: ',num2str(S)])
end
end