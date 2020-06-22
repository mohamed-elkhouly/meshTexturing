function projected_points=projection_of_points_on_a_plane(points,plan_orig,normal)
v = points-plan_orig;
dists=v*normal';
projected_points=points-dists.*normal;
d=[];