function [faces,vertices]=fit_points_into_plans(points,dividing_distance,max_face_area,view)
% max_face_area=0.001;
% points=[5 0 1;
%     4 2 1;       3 3 1;       2 4 1;       0 5 1;     -2 4 1;    -3 3 1;   -4 1 1;    -5 0 1;
%     -5 0 -1;    -4 1 -1;    -3 3 -1;    -2 4 -1;    0 5 -1;    2 4 -1;    3 3 -1;    4 2 -1;    5 0 -1];
% dividing_distance=1;
faces=[];
vertices=[];
min_in_all=min(points,[],1);
min_x=min_in_all(1);
min_y=min_in_all(2);
min_z=min_in_all(3);

max_in_all=max(points,[],1);
max_x=max_in_all(1);
max_y=max_in_all(2);
max_z=max_in_all(3);
x_length=max_x-min_x;
y_length=max_y-min_y;
z_length=max_z-min_z;
max_length=max([x_length,y_length,z_length]);
if(max_length>dividing_distance)
    % if x_length>y_length
    %     slice_x=dividing_distance;
    %     slices_in_x=min_x:slice_x:max_x;
    %     [faces,vertices]=divide_into_plane_using(slices_in_x,points(:,1),points(:,2),points(:,3),0,max_face_area,view);
    % else
    %     slice_y=dividing_distance;
    %     slices_in_y=min_y:slice_y:max_y;
    %     [faces,vertices]=divide_into_plane_using(slices_in_y,points(:,2),points(:,1),points(:,3),1,max_face_area,view);
    % end
    
    slices_in_x=min_x:dividing_distance:max_x;
    if length(slices_in_x)>1
        [facesx,verticesx,errors_x]=divide_into_plane_using(slices_in_x,points(:,1),points(:,2),points(:,3),0,max_face_area,view,dividing_distance);
    else
        errors_x=1000;
    end
    
    slices_in_y=min_y:dividing_distance:max_y;
    if length(slices_in_y)>1
        [facesy,verticesy,errors_y]=divide_into_plane_using(slices_in_y,points(:,2),points(:,1),points(:,3),1,max_face_area,view,dividing_distance);
    else
        errors_y=1000;
    end
    
    slices_in_z=min_z:dividing_distance:max_z;
    if length(slices_in_z)>1
        [facesz,verticesz,errors_z]=divide_into_plane_using(slices_in_z,points(:,3),points(:,2),points(:,1),2,max_face_area,view,dividing_distance);
    else
        errors_z=1000;
    end
    min_error=min([errors_x,errors_y,errors_z]);
    if min_error<0.001
    if (errors_x<errors_y && errors_x<errors_z)
        faces=facesx;
        vertices=verticesx;
    elseif (errors_y<errors_x && errors_y<errors_z || (errors_z==1000&&errors_y~=1000))
        faces=facesy;
        vertices=verticesy;
    elseif(errors_z~=1000)
          faces=facesz;
        vertices=verticesz;
    end
    else
        d=[];
    end
    
else
    try
        [faces,vertices,~]=points2mesh(points,max_face_area,[],[]);
%         trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3),'Facecolor','cyan');
    catch
        
    end
end
d=[];
function [faces,vertices,errors]=divide_into_plane_using(slices_in_x,x,y,z,flipped,max_face_area,view,dividing_distance)
% dividing_distance=1;
errors=[];
min_x_cord=x-slices_in_x;
faces=[];vertices=[];indexes_for_next_step=[];
for i=2:length(slices_in_x)
    indexes_in_plane_i=unique([find((-1*dividing_distance)<=min_x_cord(:,i-1) & min_x_cord(:,i-1)<=dividing_distance);find((-1*dividing_distance)<=min_x_cord(:,i) & min_x_cord(:,i)<=dividing_distance)]);
    indexes_in_plane_i=[indexes_in_plane_i;indexes_for_next_step];
    indexes_in_plane_i=unique(indexes_in_plane_i);
    if(flipped==0)
        points_in_plane=[x(indexes_in_plane_i),y(indexes_in_plane_i),z(indexes_in_plane_i)];
    elseif(flipped==1)
        points_in_plane=[y(indexes_in_plane_i),x(indexes_in_plane_i),z(indexes_in_plane_i)];
    elseif(flipped==2)
        points_in_plane=[z(indexes_in_plane_i),y(indexes_in_plane_i),x(indexes_in_plane_i)];
    end
    try
        [faces,vertices,errors(i-1)]=points2mesh(points_in_plane,max_face_area,faces,vertices);
        indexes_for_next_step=[];
    catch
        indexes_for_next_step=[indexes_for_next_step;indexes_in_plane_i];
    end
end
if isempty(errors)
    errors=1000;
else
errors=mean(errors);
end
if(view)
    trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3),'Facecolor','cyan');
end
d=[];

function [faces,vertices,errors]=points2mesh(points_in_plane,max_face_area,faces,vertices)
[~,normal,plane_center]=fit_3d_plane_to_points(points_in_plane,0);
projected_points =projection_of_points_on_a_plane(points_in_plane,plane_center,normal);

distance_between_projections=points_in_plane-projected_points;
errors=norm(distance_between_projections)/length(distance_between_projections);

convex_hull_faces =convhull(projected_points(:,1),projected_points(:,2),projected_points(:,3));
[refined_faces,temp_final_vertices]=refine_mesh(convex_hull_faces,projected_points,max_face_area);
%         unique_faces=unique(refined_faces);
%         temp_final_vertices=temp_final_vertices(unique_faces,:);
faces=[faces;(refined_faces+size(vertices,1))];
vertices=[vertices;temp_final_vertices];
