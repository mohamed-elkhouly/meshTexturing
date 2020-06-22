function [S] = Bvfmd(idep,aspra)
Ad = pi/idep; % Ad = disk cell area
nring = floor(sqrt(idep));% Defining a tentative realistic number of rings
tp = ones(1,nring)*pi/2;Sp=ones(1,nring)*idep; % initializations
r = ones(1,nring);Aring=ones(1,nring)*Ad;nan=0; % initializations
if aspra == 1
 for i = 2:nring;
 r(i) = r(i-1)-sqrt(Ad);Aring(i)=Ad/sin(acos((r(i)+r(i-1))/2))^2;
 tp(i) = tp(i-1) - sqrt(Aring(i));
 Sp(i) = round(Sp(i-1)* (sin(tp(i))/sin(tp(i-1)))^2);
 if Sp(i-1)<6;Sp(i-1)=1;Sp(i)=1;end % Forcing presence central disk
 if Sp(i-1) == 1;if nan == 0;nan = i-1;end;end
 end
else
 for i = 2:nring;
 r(i) = r(i-1) - sqrt(Ad);
 Sp(i) = round(Sp(i-1)*(r(i)/r(i-1))^2); % Equivalent expression
 if Sp(i-1)<6;Sp(i-1)=1;Sp(i)=1;end % Forcing presence central disk
 if Sp(i-1) == 1;if nan == 0;nan = i-1;end;end
 end
end
S=zeros(1,nan);for i = nan:-1:1;S(nan-i+1)=Sp(i);end; % Re-ordering caps
disp(['VF Sequence of ',num2str(size(S,2)),' nested caps: ',num2str(S)])
disp(['Optimization parameter of aspect ratio = ',num2str(aspra)])
end