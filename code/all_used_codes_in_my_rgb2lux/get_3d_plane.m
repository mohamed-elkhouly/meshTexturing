function planefunction=get_3d_plane(P1,P2,P3)
P1 = [0 1 1];
P2 = [-2 0 0];
P3 = [2 0 0];
normal = cross(P1-P2, P1-P3);
syms x y z
P = [x,y,z];
planefunction = dot(normal, P-P1);