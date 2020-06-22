%% Script for creating the initial mesh files with all the information for each of the different illumination scenarios per room.
%  It requires that you have available all the needed information which are:
%
%  1. RGBD data (rgb + depth images)
%  2. albedo map (extracted albedo image)
%  3. light properties (positioning (vertices+faces), normals, reflectance values, etc...)

clear all;
%% Initialize variables.
addpath(genpath('/home/elkhouly/rgbd2lux_linux'));
path = '/home/elkhouly/rgbd2lux_linux/dataset/room4a/data/'; % path where rgbd data are located

fileList = dir(strcat(path,'*.mat'));
files = {fileList.name}';
files = natsortfiles(files);

idcs   = strfind(path,filesep);
path_n = path(1:idcs(end-1));

% load albedo and lights information
load(strcat(path_n,'albedo.mat'),'A'); % if you do not have the albedo map look how to create it in the create_albedo.m script
% load(strcat(path_n,'lights_fluorescent.mat'));
load(strcat(path_n,'lights_led.mat'));

% addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/jointWMF_mex_64bit/complete_mex')
% addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/bilateral_filtering')
% addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/Open3D/mat2open3D')
% addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/geom3d/meshes3d')
% addpath('/home/elkhouly/rgbd2lux_linux/libs+tools/geom3d/geom3d')
% addpath('/home/elkhouly/rgbd2lux_linux/scripts/3d')
% addpath('/home/elkhouly/rgbd2lux_linux/scripts/ploting')

% for i = 1:length(fileList) % loop for all cases, should be used for the dynamic scenes
for i = length(fileList) % just take the full lit case, should be used for the static scenes    
    filename = strcat(path,files{i});

    %% Open the text file.
    load(filename,'colorImages');
    load(filename,'depthImages');

    % apply filtering/smoothing and corrections on the depth map
    depth = depthImages(:,:,3,end);
    depth(isnan(depth)) = 0;
    [~,~,~,e]=size(colorImages);
    test_wmf = jointWMF(depth,colorImages(:,:,:,e),20,25.5,256,256,1,'exp');
%     figure, imshow(round(test_wmf,2),[])
%     impixelinfo
    depth_out = bilateralGrayscale(test_wmf,25,.2);
%     figure, imshow(depth_out,[])
%     impixelinfo

    % extract mesh from the open3d lib
    % INPUT:
    %   1. rgb image (r and g channels need to swifted)
    %   2. depth image (values should be in mm, if your input image is in meters multiply by 1000 since this is what open3d expects. This might change though in newer updates of the lib)
    %   3. albedo image (values should be within the range 0-1 and then multiplied by 10000, in order to get the correct output from open3d. Again this might change in future updates of the lib)
    % OUTPUT:
    %   1. <name>.v --> vertices of mesh
    %   2. <name>.f --> faces of mesh
    %   3. <name>.v_c --> color of the vertices of the mesh
    %   4. <name>.v_albedo --> reflectance value of the vertices of the mesh
    %   5. <name>.v_n --> normals of the vertices of the mesh
    %   6. <name>.f_n --> normals of the faces of the mesh
    %   check file rgbd2Mesh.cpp in rgbd2lux/libs+tools/open3D/mat2open3D/
    [mesh_room1_test.v, mesh_room1_test.f, mesh_room1_test.v_c, mesh_room1_test.v_albedo, mesh_room1_test.v_n, mesh_room1_test.f_n] = rgbd2Mesh(permute(colorImages(:,:,:,end),[2 1 3]), uint16(depth_out*1000)', uint16(A*10000)');
    mesh = mesh_room1_test;
    
    % transpose all matrices of the mesh struct
    mesh = structfun(@ctranspose,mesh,'UniformOutput',false);

    init_size_mesh_v = size(mesh.v);
    init_size_mesh_f = size(mesh.f);

    % move mesh height above 0
    min_z = min(mesh.v(:,3));
    if min_z < 0
        mesh.v(:,3) = mesh.v(:,3) + abs(min(mesh.v(:,3)));
    end

    % extract reflectance values for the faces of the mesh
    mesh.rho = mesh.f(:);
    mesh.rho = mesh.v_albedo(mesh.rho,1);
    mesh.rho = reshape(mesh.rho,size(mesh.f));
    mesh.rho = mean(mesh.rho,2)
    
    % add light faces, vertices, albedo and light patches info to main mesh
    mesh.v = [mesh.v; lights.v];
    mesh.f = [mesh.f; (lights.f+init_size_mesh_v(1))];
    mesh.lightPatches = lights.lightPatches;
    fields = fieldnames(mesh.lightPatches);
    for j = 1:numel(fields)
        mesh.lightPatches.(fields{j})= mesh.lightPatches.(fields{j}) + init_size_mesh_f(1);
    end
    mesh.rho = [mesh.rho; lights.rho];
    mesh.v_n = [mesh.v_n; lights.v_n];
    mesh.f_n = [mesh.f_n; lights.f_n];
    mesh.v_c = [mesh.v_c; lights.v_c];
    mesh.v_albedo = [mesh.v_albedo; lights.v_c];

    % meters to mm
    mesh.v = mesh.v*1000;
    mesh.v_n = mesh.v_n*1000;
    mesh.f_n = mesh.f_n*1000;

    % compute and add mesh face centroids and areas
    mesh.centroids = meshFaceCentroids(mesh.v, mesh.f);
    mesh.areas = meshArea(mesh.f, mesh.v);
    
    % extract the color for the faces of the mesh
    f = mesh.f(:);
    meshFC1 = mesh.v_c(f,1);
    meshFC2 = mesh.v_c(f,2);
    meshFC3 = mesh.v_c(f,3);
    meshFC1 = reshape(meshFC1,size(mesh.f));
    meshFC2 = reshape(meshFC2,size(mesh.f));
    meshFC3 = reshape(meshFC3,size(mesh.f));
    meshFC1 = mean(meshFC1,2);
    meshFC2 = mean(meshFC2,2);
    meshFC3 = mean(meshFC3,2);

    mesh.f_c = [meshFC1 meshFC2 meshFC3];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % you might want to comment this part in case taht you do not want to
    % add the luxmeters positioning (bear in mind that you might need to apply some
    % manual refinement since the normals might from the selected patches might not
    % matching the real cases)
    % plot rgb image in order to select occupants or luxmeter positions
    figure, imshow(colorImages(:,:,:,end));
    [x,y] = getpts;
    luxmeter_rgb_points = [y x];

    % get depth and mesh points from previous points based on the depth data
    for ii = 1:size(luxmeter_rgb_points,1)
        luxmeter_depth_points(ii,:) = depthImages(round(luxmeter_rgb_points(ii,1)),round(luxmeter_rgb_points(ii,2)),:,end);
        luxmeter_depth_points(ii,2) = luxmeter_depth_points(ii,2)*-1;
        luxmeter_depth_points(ii,3) = (luxmeter_depth_points(ii,3)+min_z)*-1;
        luxmeter_depth_points(ii,:) = luxmeter_depth_points(ii,:)*1000;
        [k,d] = dsearchn(luxmeter_depth_points(ii,:), mesh.centroids);
        [~,idx] = min(d);
        luxmeter_patches(ii) = idx;
        luxmeter_mesh_points(ii,:) = mesh.centroids(idx,:);
    end
    
    mesh.luxmeter.patches = luxmeter_patches;
    mesh.luxmeter.patches_c = luxmeter_mesh_points;
    mesh.luxmeter.rgb_points = luxmeter_rgb_points;
    mesh.luxmeter.depth_points = luxmeter_depth_points;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % save mesh file
    save(strcat(path_n,'mesh_',extractBefore(files{i}, '.'),'_7cubics.mat'), 'mesh', 'depth_out', 'colorImages');
    mesh_last = mesh;
    
    %% Clear temporary variables
    clearvars filename ans colorImages depthImages min_z idcs mesh mesh_room1_test test_wmf depth depth_out fields init_size_mesh_* f meshFC1 meshFC2 meshFC3 d idx ii k luxmeter_* x y;
end

clearvars fileList files i j idcs lights path path_n A;

figure, plot_CAD(mesh_last.f, mesh_last.v, '', mesh_last.f_c);
% figure, plot_CAD(mesh.f, mesh.v, ''); % uncoment this line if you want to plot without color, uncomment line 30 in the plot_CAD() script in order to see the patches (triangles)
delete(findall(gcf,'Type','light'))
set(gca,'Color',[0.9 0.9 0.9]) % for visualization reasons
% axis off % uncoment this line if you want to remove the axes

% plot normals of the light patches and luxmeter patches
% drawVector3d(mesh_last.centroids(mesh_last.lightPatches.allLights,:), mesh_last.f_n(mesh_last.lightPatches.allLights,:)*0.2, 'g-');
% drawVector3d(mesh_last.centroids(mesh_last.luxmeter.patches,:), mesh_last.f_n(mesh_last.luxmeter.patches,:)*0.2, 'g-');