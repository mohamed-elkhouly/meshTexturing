clear all
mesh.scene_name='scene2';
mesh.frame_height=1024;
mesh.frame_width=1280;
mesh=loadSceneData(mesh);
% Uncomment the next line in case that you want to calculate the per-face average
%color from all views
% [faces_colors]=getFacesColors_and_TexturingMesh2_only_for_average_purpose(mesh);
% Uncomment the next line in case that you want to calculate the difference
% between the baked and average dataset.
% get_difference_between_baked_and_average(mesh)
[faces_colors]=getFacesColors_and_TexturingMesh2(mesh);
% Uncomment the next line if you want to calculate the difference between
% the baked and Waechter et al.
% get_difference_between_baked_and_waechter(mesh)
d=[];
