function [S] = Bsamd(idep)
if nargin == 0, idep = 145; end % Default value of the input
Ims = 1;ccp=7; % Tuning parameters
nring = floor(sqrt(idep));% Defining a tentative realistic number of rings
tp = ones(1,nring)*pi/2;Sp=ones(1,nring)*idep;nan = 0;% initializations
for i = 2:nring;
 tp(i) = tp(i-1)-sqrt(2*pi/idep);
 Sp(i) = round(Sp(i-1)*(sin(tp(i)/2)/sin(tp(i-1)/2))^2);
 if Ims > 0;tp(i)=2*asin( sin(tp(i-1)/2)*sqrt(Sp(i)/Sp(i-1)));end;
 if Sp(i-1)<ccp;Sp(i-1)=1;Sp(i)=0;end% Forcing presence of central disk
 if Sp(i-1) == 1;if nan == 0;nan = i-1;end; end
end
S=zeros(1,nan);for i=nan:-1:1;S(nan-i+1)=Sp(i);end; % Re-ordering the caps
if size(S,2) < 11;
disp(['SA Sequence of ',num2str(size(S,2)),' nested caps: ',num2str(S)])
end
end
