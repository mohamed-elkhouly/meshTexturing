%% add needed paths
clear all;
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
addpath(genpath('/home/elkhouly/rgbd2lux_linux'));

room_num=0;

%% load mesh for computing the form factors
if room_num==0
    
    
%     for jj=10:40
        
%         warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
%         addpath(genpath('/home/elkhouly/rgbd2lux_linux'));
        scene_name='1LXtFkjw3qL_1';
%         region_number=jj;
        region_number=15;
        use_simplified=0;
        if use_simplified
            simplified_version='_0.3_';
            insider_directory=['simplified_regions/','region',num2str(region_number),'/'];
        else
            simplified_version='';
            insider_directory='';
        end
        
        
        mesh_file=['meshregion',num2str(region_number),simplified_version,'.mat'];
        scene_path='/home/elkhouly/rgbd2lux_linux/dataset/';
        region_file_all=['region',num2str(region_number),simplified_version,'.mat'];
        region_file_no_simplification_path=[scene_path,scene_name,'/original_regions/','region',num2str(region_number),'.mat'];
        try
            load([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
            
        catch
            load([scene_path,scene_name,'/original_regions/',insider_directory,region_file_all])
            tic
            mesh=convert_python_generated_mat_to_similar_to_ours(dahy,region_file_no_simplification_path,use_simplified);
            toc
            save([scene_path,scene_name,'/created_mesh_regions/',mesh_file],'mesh');
        end
        colors_v(:,:,1)=mesh.f_c(:,1);colors_v(:,:,2)=mesh.f_c(:,2);colors_v(:,:,3)=mesh.f_c(:,3);
        colors_v=rgb2ycbcr(uint8(colors_v*255));
        colors=colors_v(:,:,1);
        figure, plot_CAD(mesh.f, mesh.v, '', [colors]);
        delete(findall(gcf,'Type','light'));
        savefig([scene_path,scene_name,'/created_mesh_regions/',mesh_file,'luminance.fig']);
        d=[];
%         clear all;
%     end
elseif room_num==1
    load('/home/elkhouly/rgbd2lux_linux/dataset/room1/mesh_room1_12_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
elseif room_num==2
    load('/home/elkhouly/rgbd2lux_linux/dataset/room2/mesh_room2_1234_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
elseif room_num==3
    load('/home/elkhouly/rgbd2lux_linux/dataset/room3/mesh_room4_12345678_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
    % load('/home/elkhouly/rgbd2lux_linux/dataset/room3a/mesh_room6_12345678e_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
elseif room_num==4
    load('/home/elkhouly/rgbd2lux_linux/dataset/room4/mesh_room5_12345678_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
    % load('/home/elkhouly/rgbd2lux_linux/dataset/room4a/mesh_room7_12345678d_7cubics.mat') % for the static scenes you need only one mesh for all light activation cases, for the dynamic scenes you need to load each individual mesh for each lighting case
end

% if you do not have the mesh look how to create it by checking on create_meshes.m script

%% load ldc and lsc distributions for the installed light sources and luxmeters respectively
if room_num==1 || room_num==2 || room_num==0
    load('/home/elkhouly/rgbd2lux_linux/dataset/room1/ldc_fluorescent.mat') %rooms 1,2 you should load the corresponding ldc located in each folder (i.e. ldc_fluorescent or ldc_led) depending on the luminaire type
else
    load('/home/elkhouly/rgbd2lux_linux/dataset/room3/ldc_led.mat') %rooms 3,3a,4,4a you should load the corresponding ldc located in each folder (i.e. ldc_fluorescent or ldc_led) depending on the luminaire type
end

load('/home/elkhouly/rgbd2lux_linux/dataset/room1/lsc_pasco.mat')%
lsc=lsc_pasco;
% bring ldc and lsc in the format that are needed for processing
ldc = struct('ldc', ldc, 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));
lsc = struct('lsc', lsc, 'ldcSymetric', cat(2, lsc, fliplr(lsc(:,1:end-1))), 'ldcZ', (0:10:180)', 'ldcX', (0:10:180));

%% calculate form factors, you will need a computer with big memory in case that your mesh has a lot of faces (for only matlab based code use viewFactors3.m script instead)
% tic;[F] = viewFactors4OPCODE(mesh, 1000, 1);toc % form factors without any distribution isotropic calculation
% tic; save("room1_F.mat",'-v7.3',"F","ldc","lsc");toc;% around 5 minutes save
%
% tic;[F_ldc] = viewFactors4OPCODE(mesh, 1000, 1, ldc, viewFactors4OPCODE(mesh, 1000, 1), mesh.lightPatches.allLights);toc % form factors with ldc distribution applied on the light sources
% clearvars F;
% tic;save("room1_F_ldc.mat",'-v7.3',"F_ldc");toc;
% % tic;[F_lsc] = viewFactors4OPCODE(mesh, 1000, 1, lsc, F.ij, mesh.lightPatches.allLights);toc % form factors with lsc distribution applied on the light sources
global iteration;
iteration=0;
global counter;
counter=0;
tic;[F_ldc_lsc] = viewFactors4OPCODE_sparse3(mesh, 1000, 1, lsc, viewFactors4OPCODE_sparse3(mesh, 1000, 1, ldc, viewFactors4OPCODE_sparse3(mesh, 1000, 1), mesh.lightPatches.allLights), mesh.luxmeter.patches);toc % form factors with ldc and lsc distributions applied
% tic;[F_ldc_lsc] = viewFactors4OPCODE(mesh, 1000, 1, lsc, viewFactors4OPCODE(mesh, 1000, 1, ldc, viewFactors4OPCODE(mesh, 1000, 1), mesh.lightPatches.allLights), mesh.luxmeter.patches);toc % form factors with ldc and lsc distributions applied
% clearvars F_ldc;
% tic;save("room1_F_ldc_lsc_new.mat",'-v7.3',"F_ldc_lsc");toc;
% load("room1_F_ldc_lsc.mat");
%% compute radiosities for static rooms
if room_num==0 %
    light_combination_labels = [0;1;1]; %  this one for matterport rooms, we consider only one light source inside it
elseif room_num==1
    light_combination_labels = [0;1;2;12;]; % room1
elseif room_num==2
    light_combination_labels = [0; 1; 2; 3; 4; 12; 13; 14; 23; 24; 34; 123; 124; 134; 234; 1234]; % room2
elseif room_num==3||room_num==4
    light_combination_labels = [0; 1; 2; 3; 4; 5; 6; 7; 8; 12; 15; 16; 25; 26; 34; 37; 38; 47; 48; 56; 78; 125; 126; 156; 256; 347; 348; 378; 478; 1256; 3478; 12345678]; % room3 and room4
end
% light_combination_labels = [0; 1; 12; 15; 34; 34; 2345; 2345; 2345; 3478; 3478; 345678; 12345678; 12345678; 12345678; 12345678; 12345678]; % room3a
% light_combination_labels = [0; 1; 12; 15; 16; 25; 26; 34; 34; 78; 345; 1346; 2345; 2345; 2345; 3478; 3478; 34567; 123456; 345678; 12345678; 12345678; 12345678]; % room4a

%% create the self emmitance matrix e (multiple vectors, one for each light combination to be evaluated), corresponding to the light sources and
% initialize e
if room_num==1 || room_num==2
    e_4800 = zeros(length(mesh.f), length(light_combination_labels)); % room1 and room2
else
    e_7913 = zeros(length(mesh.f), length(light_combination_labels)); % room3, room4, room3a and room4a
end

% specify the luminous intensity of the light sources (luminaires)
if room_num==1 || room_num==2
    luminous_intensity = 4800; % put this to the corresponding luminous intensity of the light sources (luminaires) (room1 and room2)
else
    luminous_intensity = 7913; % put this to the corresponding luminous intensity of the light sources (luminaires) (room3, room4, room3a and room4a)
end

%


% specify values in the matrix e
for i = 2:length(light_combination_labels)
    name = regexp(num2str(light_combination_labels(i)), '.', 'match');
    index = [];
    for j = 1:length(name)
        name{j} = strcat('light', name{j});
        index = [index; getfield(mesh.lightPatches, name{j})];
    end
    if room_num==1 || room_num==2
        e_4800(index, i) = luminous_intensity;
    else
        e_7913(index, i) = luminous_intensity;
    end
    clear index
end
clear i j name ans

% OUTPUT:
% r = radiosities
% h = illuminance
% q = flux (we do not really use at all)
%% Dahy added the next lines:
nbf=size(F_ldc_lsc,1);
indexes=1:nbf;
tic;
% F_ldc_lsc=sparse(F_ldc_lsc);
F_ldc_lsc=sparse(indexes,indexes,mesh.rho)*F_ldc_lsc;
K=speye(nbf,nbf)-F_ldc_lsc;
toc;
%%
tic;for i = 1:length(light_combination_labels)
    if room_num==1 || room_num==2
        [r(:,i), h(:,i), q(:,i)] = RT_SolveRadiosityEquation(F_ldc_lsc, mesh.rho, e_4800(:,i), 2,K); % be aware that for the dynamic scenes you should load a different F_ldc_lsc and mesh.rho while e_4800 or e_7913 will be different size each time depending on the faces number of the mesh
    else
        [r(:,i), h(:,i), q(:,i)] = RT_SolveRadiosityEquation(F_ldc_lsc, mesh.rho, e_7913(:,i), 2,K); % be aware that for the dynamic scenes you should load a different F_ldc_lsc and mesh.rho while e_4800 or e_7913 will be different size each time depending on the faces number of the mesh
    end
end
toc

% visualize the illumination estimation map
% the next lines till the while loop is for remove the little values which is too high to give us visible scale of ranges
new_h=(h(:,3)/max(h(:,3)))*255;
val=255;
stop_threshold=0.01*length(new_h);
if sum(sum(h>0))>0
    while(1)
        if sum(new_h>val)>stop_threshold
            break;
        end
        val=val-2;
    end
    new_h(new_h>val)=val;
    figure, plot_CAD(mesh.f, mesh.v, '', new_h);
    savefig([scene_path,scene_name,'/created_mesh_regions/',mesh_file,'.fig']);
    delete(findall(gcf,'Type','light'))
    savefig([scene_path,scene_name,'/created_mesh_regions/',mesh_file,'no_light.fig']);
end
% evaluating the estimated values with the ground truth luxmeter values
if room_num==1
    luxmeters = readLuxmeterValues_dahy('/home/elkhouly/rgbd2lux_linux/dataset/room1/lux');
elseif room_num==2
    luxmeters = readLuxmeterValues_dahy('/home/elkhouly/rgbd2lux_linux/dataset/room2/lux');
elseif room_num==3
    luxmeters = readLuxmeterValues_dahy('/home/elkhouly/rgbd2lux_linux/dataset/room3/lux');
elseif room_num==4
    luxmeters = readLuxmeterValues_dahy('/home/elkhouly/rgbd2lux_linux/dataset/room4/lux');
end
if room_num~=0
    error = plotBoxPlots(luxmeters, mesh.luxmeter.patches, h, 'RGBD2Lux illuminance'); % absolute
    error = plotBoxPlotsNegPos(luxmeters, mesh.luxmeter.patches, h, 'RGBD2Lux illuminance'); % signed
end