%% Human light perception script
% INPUT:
%   1. the extracted mesh 
%   2. the 3D position of the face and the orientation vector (normal)
%   3. the estimated radiosity map
%   4. the lsc

function [list_voxel_property_3D] = lightPerceptionTest(cadModel_, poses, measuredIllumination, lsc)

    P_filtered = cadModel_.v';% / 1000;
     
    % Set the origin so that all points have positive coordinates and there is
    % at least one point on each axis
    xmin = min(P_filtered(1,:));
    ymin = min(P_filtered(2,:));
    zmin = min(P_filtered(3,:));
    
    P_filtered(1,:) = P_filtered(1,:) - min(P_filtered(1,:));
    P_filtered(2,:) = P_filtered(2,:) - min(P_filtered(2,:));
    P_filtered(3,:) = P_filtered(3,:) - min(P_filtered(3,:));
    
    cadModel_.v = P_filtered';
    cadModel_.centroids = cadModel_.centroids - [xmin ymin zmin];
    figure, plot_CAD(cadModel_.f, cadModel_.v);
    plot_vertices(poses.noisyCent  - [xmin ymin zmin], 'b', 300)
    drawVector3d(poses.noisyCent  - [xmin ymin zmin], poses.norm, 'g-', 'LineWidth', 3);
    
    r = vrrotvec(poses.norm, [-1 0 0]);
    M = vrrotvec2mat(r);
    eulXYZ = rad2deg(rotm2eul(M)); % eulXYZ(1) = roll, eulXYZ(2) = pitch, eulXYZ(3) = yaw
    
    grid_sampling_rate = [1000, 1000, 1000, 45, 45]; % sampling rate of the grid, values according to which the dimension of the mesh will be extracted
    dof_constraints = [0, 14000]; % distance that rays can reach, e.g. 4000 -> 4 meters
    field_of_view = 180; % field of view of the camera
    pitch_constraints = [0 360]; % rotation of the reference point over pitch
    number_of_robots = 1;
    robot_max_distance = 200;

    % not clear yet what these variable are
    local_grid_dimensions = [ceil(9 / grid_sampling_rate(1)), ceil(9 / grid_sampling_rate(2)), 1];
    angles_sampling_rate = [field_of_view, field_of_view];

    % not clear yet what these varibles are 
    alpha = 7;
    gamma = 1;
    phi = 1 / 180;
    eta = 10;

    % coordinates of robot in old datasets
    % world_coord = [172 97 1 45 180;
    %                72 97 1 45 270;
    %                72 197 1 45 180;
    %                172 197 1 45 0];

    % % coordinates of lights in space [X Y Z pitch yaw]
    x = poses.noisyCent(1)  - xmin;
    y = poses.noisyCent(2)  - ymin;
    z = poses.noisyCent(3)  - zmin;
    world_coord = [x y z  -eulXYZ(2) -eulXYZ(3)]; % human 3


    % world_coord = [0.88 8.7 1.8 180 90];

    list_voxel_property_3D = swarm3d_INIT_1camera_1motion_2Doccupancy(P_filtered, grid_sampling_rate, dof_constraints, field_of_view, pitch_constraints, number_of_robots, robot_max_distance);

    tic;
    for i = 1:size(world_coord,1)
    %     fprintf('%1.0f...',i);
        list_voxel_property_3D = swarm3d_NEXTMOVE_1camera_1motion_2Doccupancy(list_voxel_property_3D, world_coord(i,:));
    %     [ut,fc_pen,local_grid] = swarm3d_create_cost_xytheta_voxelf1(list_voxel_property_3D, local_grid_dimensions, angles_sampling_rate, world_coord(i,1:3));
    %     [list_voxel_property_3D, world_coord] = compute_best_pose(list_voxel_property_3D, world_coord, ut, fc_pen, local_grid, alpha, gamma, phi, eta);
        [list_voxel_property_3D, fieldName] = getPointsAngles(list_voxel_property_3D, i);
        faces = subMesh2(cadModel_,list_voxel_property_3D.(fieldName).pointsPosition);
%         list_voxel_property_3D.(fieldName).faces = faces;
        list_voxel_property_3D.(fieldName).faces = filterLightPerceptionFaces(list_voxel_property_3D.(fieldName).personPosition, list_voxel_property_3D.(fieldName).pointsPosition, faces, cadModel_);
        
        faces = list_voxel_property_3D.(fieldName).faces;
        
        % here we can add the distribution
        weights = perceptionFactors(cadModel_, 1000, 1, lsc, [], list_voxel_property_3D.(fieldName).personPosition', list_voxel_property_3D.(fieldName).v_center')';
        
        list_voxel_property_3D.(fieldName).measuredLux = round(sum(measuredIllumination(faces,:)*pi.*weights(faces)), 2);
        
        clear faces;
%         list_voxel_property_3D = getCandelas(list_voxel_property_3D, fieldName);
%         disp(world_coord(i,:));
        text(list_voxel_property_3D.(fieldName).personPosition(1), list_voxel_property_3D.(fieldName).personPosition(2), ...
            list_voxel_property_3D.(fieldName).personPosition(3)+200, strcat({'MB:'}, {' '}, {num2str(list_voxel_property_3D.(fieldName).measuredLux)}), ...
            'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold');
%         text(list_voxel_property_3D.(fieldName).personPosition(1), list_voxel_property_3D.(fieldName).personPosition(2), ...
%             list_voxel_property_3D.(fieldName).personPosition(3)+100, strcat({'PB:'}, {' '}, {num2str(list_voxel_property_3D.(fieldName).perceivedBrightness)}), ...
%             'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold');
    end
    % fprintf('Done. \n');
    duration = toc;
    disp(['The computation took ' num2str(duration) ' seconds']);
%     plot_result(list_voxel_property_3D);
    
    list_voxel_property_3D = list_voxel_property_3D.(fieldName).measuredLux;
end