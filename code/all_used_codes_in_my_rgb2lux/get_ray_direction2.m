function [final_rays_direction,back_projected_point]=get_ray_direction2(pose_matrix,intrinsics,point_2d,FN,t,start_of_faces_indexing,req_vertices)
point_3d=req_vertices';
point_3d(4,:)=1;

%% the next commented lines are test example up to line 18
% point_3d=[0;3;0;1];
% rotation_matrix=[
%        0.1971501, -0.5626401,  0.8028499;
%        0.5626401, -0.6056999, -0.5626401;
%        0.8028499,  0.5626401,  0.1971501
%     ];
% origin=[-5; 0 ;0];
% % origin=[0; 0 ;0];
% translation=-1*rotation_matrix*origin;
% RT_matrix=[rotation_matrix,translation];
% % RT_matrix=[RT_matrix;0 0 0 1]; % not usable anymore
% pose_matrix=rotation_matrix';
% pose_matrix(1:3,4)=origin;
% pose_matrix(4,:)=[0,0,0,1];
% intrinsics=[1071.65 0 630.843 ; 0 1072.26 504.318 ; 0 0 1 ];
% % intrinsics=[1071.65 0 630.843 0; 0 1072.26 504.318 0; 0 0 1 0; 0 0 0 1]; % not usable anymore
rotation_matrix=pose_matrix(1:3,1:3)';
camera_position_in_world=pose_matrix(1:3,4);
translation=-1*rotation_matrix*camera_position_in_world;
RT_matrix=[rotation_matrix,translation];
RT_matrix=[RT_matrix;0 0 0 1];
rotx=[1 0 0 0;0 -1 0 0; 0 0 -1 0;0 0 0 1];
roty=[-1 0 0 0;0 1 0 0; 0 0 -1 0;0 0 0 1];
rotz=[-1 0 0 0;0 -1 0 0; 0 0 1 0;0 0 0 1];
% RT_matrix=pose_matrix;
% camera_position_in_world=translation;
% intrinsics=intrinsics(1:3,1:3);
% RT_matrix(3,3)=RT_matrix(3,3)*-1;
% intrinsics(1,3)=intrinsics(1,3)*-1;
% intrinsics(3,3)=intrinsics(3,3)*-1;
% intrinsics(2,2)=intrinsics(2,2)*-1;
% intrinsics(:,3)=intrinsics(:,3)*-1;
projection_matrix=intrinsics*RT_matrix;
point_2d_generated=projection_matrix*point_3d;
point_2d_generated=point_2d_generated(1:3,:)./point_2d_generated(3,:);
inverse_projection_matrix=pinv(projection_matrix) ;

% point_2d=point_2d/point_2d(3);
point_2d(3,:)=1;
point_2d(4,:)=1;
back_projected_point=inverse_projection_matrix*point_2d;
back_projected_point=back_projected_point(1:4,:)./back_projected_point(4,:);
back_projected_point(4,:)=[];
final_rays_direction=back_projected_point-camera_position_in_world;
final_rays_direction=final_rays_direction./vecnorm(final_rays_direction,1);
center=[camera_position_in_world,camera_position_in_world,camera_position_in_world,camera_position_in_world];
% final_rays_direction(2,:)=-1*final_rays_direction(2,:);
[~,~,idxx,~,~] = t.intersect(center,final_rays_direction);
face_mumer=start_of_faces_indexing+idxx;
[val,~]=intersect(face_mumer,FN)
% FN
d=[];
