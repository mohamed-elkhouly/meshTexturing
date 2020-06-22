% plotCamera(T,color,scale);
%
% Syntax:
% ------
%         T = matrice di rototraslazione dal sistema camera al sistema World
%     color = a string containing the color of lines of frame.
%     scale = axes scaling factor (magnitude)
%
% Description: 
% -----------
%     This function plots a 3D pin-hole camera in 3D matlab frame.
%       
function plotCamera (R,t,color,scale)
if nargin==0
    display('Error: function "f_3Dcamera" needs 1 parameter at least');
elseif nargin==1,
    color='r';
    scale=1;
elseif nargin==2,
    color='r';
    scale=1;
elseif nargin>4,
    display('Warning: too much input parameters in "f_3Dcamera"!')
end;

% R=T([1:3],[1:3]);
% t=T([1:3],4);
trasl=t;

Rwf2m=[1,0,0;
       0,1,0;
       0,0,1];
%CAmera points: to be expressed in the camera frame;
CAMup=scale*[-1,-1,  1, 1, 1.5,-1.5,-1, 1;
              1, 1,  1, 1, 1.5, 1.5, 1, 1
              2,-2, -2, 2,   3,   3, 2, 2];

Ri2w=R;
for i=1:length(CAMup(1,:)),    
   CAMupTRASF(:,i)=Ri2w*(CAMup(:,i))+trasl; %disegna la telec. attuale orientata nel verso giusto
end;

CAMdwn=scale*[-1,-1,  1, 1, 1.5,-1.5,-1, 1;
              -1,-1, -1,-1,-1.5,-1.5,-1,-1;
               2,-2, -2, 2,   3,   3, 2, 2];
               
for i=1:length(CAMdwn(1,:)),    
   CAMdwnTRASF(:,i)=Ri2w*(CAMdwn(:,i))+trasl; %disegna la telec. attuale orientata nel verso giusto
end;

%Riporto i punti dal sistema EGT al Matlab frame
for i=1:length(CAMupTRASF(1,:)),    
   CAMupTRASFm(:,i)=CAMupTRASF(:,i);
   CAMdwnTRASFm(:,i)=CAMdwnTRASF(:,i);
end;

hold on,
plot3(CAMupTRASFm(1,:),CAMupTRASFm(2,:),CAMupTRASFm(3,:),color);
plot3(CAMdwnTRASFm(1,:),CAMdwnTRASFm(2,:),CAMdwnTRASFm(3,:),color);
plot3([CAMupTRASFm(1,1),CAMdwnTRASFm(1,1)],[CAMupTRASFm(2,1),CAMdwnTRASFm(2,1)],[CAMupTRASFm(3,1),CAMdwnTRASFm(3,1)],color);
plot3([CAMupTRASFm(1,2),CAMdwnTRASFm(1,2)],[CAMupTRASFm(2,2),CAMdwnTRASFm(2,2)],[CAMupTRASFm(3,2),CAMdwnTRASFm(3,2)],color)
plot3([CAMupTRASFm(1,3),CAMdwnTRASFm(1,3)],[CAMupTRASFm(2,3),CAMdwnTRASFm(2,3)],[CAMupTRASFm(3,3),CAMdwnTRASFm(3,3)],color)
plot3([CAMupTRASFm(1,4),CAMdwnTRASFm(1,4)],[CAMupTRASFm(2,4),CAMdwnTRASFm(2,4)],[CAMupTRASFm(3,4),CAMdwnTRASFm(3,4)],color)
plot3([CAMupTRASFm(1,5),CAMdwnTRASFm(1,5)],[CAMupTRASFm(2,5),CAMdwnTRASFm(2,5)],[CAMupTRASFm(3,5),CAMdwnTRASFm(3,5)],color)
plot3([CAMupTRASFm(1,6),CAMdwnTRASFm(1,6)],[CAMupTRASFm(2,6),CAMdwnTRASFm(2,6)],[CAMupTRASFm(3,6),CAMdwnTRASFm(3,6)],color)