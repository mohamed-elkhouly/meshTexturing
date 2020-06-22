function  mesh=convert_python_generated_mat_to_similar_to_ours_v_0_4(in_var,original_path,simplified,folder_path,region_number,scene_name)

mesh.v=double(in_var{1});
mesh.v_c=double(in_var{2})/255;
mesh.v_n=double(in_var{3});
mesh.f=cell2mat(in_var{4})+1;
mesh.f_c=meshFaceColors(mesh.v_c, mesh.f);
%% enclosing our mesh inside a sphere (which can enclose whole scene). comment it to remove the sphere
% [x,y,z]=sphere(400);
% wide_range=30;
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% fvc=surf2patch(x,y,z,'triangles');
% 
% mesh.f=[mesh.f;(fvc.faces+length(mesh.v))];
% mesh.v=[mesh.v;fvc.vertices];
%% enclosing our mesh inside a sphere (only specific for this region). comment it to remove the sphere
min_val=min(mesh.v);
max_val=max(mesh.v);
wide_range=norm(min_val+max_val)/2;
circle_center_point=(min_val+max_val)/2;
[x,y,z]=sphere(150);
% wide_range=30;
x=x*wide_range;
y=y*wide_range;
z=z*wide_range;
fvc=surf2patch(x,y,z,'triangles');
% 
mesh.f=[mesh.f;(fvc.faces+length(mesh.v))];
fvc.vertices=[fvc.vertices+circle_center_point];
min_circle_val=min(fvc.vertices);
max_circle_val=max(fvc.vertices);
mesh.v=[mesh.v;fvc.vertices];
% figure, plot_CAD(mesh.f, mesh.v, '');
% delete(findall(gcf,'Type','light'));
%% 
mesh.rho=double(in_var{6});
mesh.areas = meshArea(mesh.f,mesh.v);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.luxmeter.patches=[];
if simplified
    try  % this try and catch to skip this part in case that I didn't annotate this region for lights
    load(original_path);
    centroids = meshFaceCentroids(dahy{1},cell2mat(dahy{4})+1);% of the original
    light1=double(dahy{5})+1;% of the original
    light1_faces_centers=centroids(light1(:),:);% of the original
    for i=1:length(light1_faces_centers)
        [~,ind(i)]=min(abs(sum(abs(mesh.centroids-light1_faces_centers(i,:)),2))); %find the minimum distance between new centroids and old light faces centroids
    end
    mesh.lightPatches.light1=unique(ind);
    mesh.lightPatches.allLights=mesh.lightPatches.light1;
    catch
        mesh.lightPatches.light1=double(in_var{5})+1;
        mesh.lightPatches.allLights=double(in_var{5})+1;
    end
else
    mesh.lightPatches.light1=double(in_var{5})+1;
    mesh.lightPatches.allLights=double(in_var{5})+1;
end
mesh=read_poses_and_intrinsics(mesh,folder_path);
mesh=get_specular_faces_v_0_2(mesh,folder_path,region_number,scene_name);