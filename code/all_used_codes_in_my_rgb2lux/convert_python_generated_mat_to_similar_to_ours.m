function  mesh=convert_python_generated_mat_to_similar_to_ours(in_var,original_path,simplified,folder_path,region_number)
mesh.v=double(in_var{1});
mesh.v_c=double(in_var{2})/255;
mesh.v_n=double(in_var{3});
mesh.f=cell2mat(in_var{4})+1;
mesh.f_c=meshFaceColors(mesh.v_c, mesh.f);
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
mesh=read_poses(mesh,folder_path);
mesh=get_specular_faces(mesh,folder_path,region_number);