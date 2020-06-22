function [points,normal,centroid]=fit_3d_plane_to_points(points,draw)
% points are num_points by 3.
% credit to https://www.ilikebigbits.com/2017_09_25_plane_from_points_2.html
if nargin<2
    draw=0;
end
length_of_points=size(points,1);
if length_of_points < 3
    error('you should have at least 3 points.');
end

sum_points =sum(points,1);
centroid=sum_points/length_of_points;
[max_distance_to_center,index]=max(vecnorm([points-centroid],2,2));


% Calculate full 3x3 covariance matrix, excluding symmetries:

r=points-centroid;
xx=r(:,1).*r(:,1);
xx=sum(xx)/length_of_points;

xy=r(:,1).*r(:,2);
xy=sum(xy)/length_of_points;

xz=r(:,1).*r(:,3);
xz=sum(xz)/length_of_points;

yy=r(:,2).*r(:,2);
yy=sum(yy)/length_of_points;

yz=r(:,2).*r(:,3);
yz=sum(yz)/length_of_points;

zz=r(:,3).*r(:,3);
zz=sum(zz)/length_of_points;

weighted_dir=[0 0 0];

%% for x
det_x = yy*zz - yz*yz;
axis_dir=[det_x, xz*yz - xy*zz, xy*yz - xz*yy];

weight = det_x * det_x;
if (weighted_dir*axis_dir')<0
    weight = -weight;
end
weighted_dir = weighted_dir + axis_dir*weight;

%% for y
det_y = xx*zz - xz*xz;
axis_dir=[xz*yz - xy*zz, det_y, xy*xz - yz*xx];
weight = det_y * det_y;
if (weighted_dir*axis_dir')<0
    weight = -weight;
end
weighted_dir = weighted_dir + axis_dir*weight;

%% for z
det_z = xx*yy - xy*xy;
axis_dir =[xy*yz - xz*yy, xy*xz - yz*xx, det_z];
weight = det_z * det_z;
if (weighted_dir*axis_dir')<0
    weight = -weight;
end
weighted_dir = weighted_dir + axis_dir*weight;
normal = weighted_dir/norm(weighted_dir);
if(sum(isfinite(normal))==3)
    theintv=0.1;
    radius=max_distance_to_center;
    points=circlePlane3D( centroid, normal, radius, theintv);
    if draw==1
        hold on;
        H = fill3(points(:,1), points(:,2), points(:,3), 'r');
        H = plot3([centroid(1) centroid(1)+normal(1)],[centroid(2) centroid(2)+normal(2)],[centroid(3) centroid(3)+normal(3)]);
    end
    d=[];
else
end

