function faces_indexes=test_behind_plan(plan_center,plan_normal,faces_centers,faces_normals,faces_indexes,behind_thresh)
% behind_thresh=0;
% faces_indexes=[1;2;3;4;5;6];
% plan_center=[0,0,0];
% plan_normal=[0,1,0];
% 
% faces_centers=[0,0,0;
%     0,-1,0;
%     1,0,0;
%     1,0,0;
%     0,1,0
%     0,0,0
%     ];
% faces_normals=[0,-1,0;
% 0,1,0;
% 0,1,0;
% 0,-1,0;
% 0,0,-1;
% 0,1,0
% ];
% the next line determine whether the faces are in front or  on or behind the  plane;
faces_position_relative_to_plan=plan_normal(1).*(faces_centers(:,1)-plan_center(1))+plan_normal(2).*(faces_centers(:,2)-plan_center(2))+plan_normal(3).*(faces_centers(:,3)-plan_center(3));
% we will exclude faces behind the plane by specific threshold
faces_indexes(faces_position_relative_to_plan<behind_thresh)=[];
faces_centers(faces_position_relative_to_plan<behind_thresh,:)=[];
faces_normals(faces_position_relative_to_plan<behind_thresh,:)=[];
faces_position_relative_to_plan(faces_position_relative_to_plan<behind_thresh)=[];
% exclude faces on or behind threshold but has opposite normal
% (normals_state is positive if they are in the same direction negative in
% opposite direction, and zero if they are prependecular
normals_state=dot(faces_normals,repmat( plan_normal,[size(faces_normals,1) 1]),2);
condition=faces_position_relative_to_plan<=0&normals_state<0;
faces_indexes(condition)=[];
% faces_centers(condition,:)=[];
% faces_normals(condition,:)=[];
% faces_position_relative_to_plan(condition)=[];
d=[];