function faces_roi = subMesh2(mesh, vertices_roi)
%     % find faces where verctices complete a full triangle
%     [lia,locb] = ismember(hp.descriptor_1.pointsPosition', hp.points3D_all', 'rows');
%     visible_f = permn(locb,3);
%     [lia2, locb2] = ismember(visible_f, cadModel_.f, 'rows');
%     idx = find(locb2);
% 
%     % figure, plot_CAD(cadModel_.f, hp.points3D_all');
%     hp = lightPerceptionTest(cadModel_, poses);
%     plot_CAD(cadModel_.f(locb2(idx),:), hp.points3D_all', [], [0 1 0]);

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if size(vertices_roi,2)>size(vertices_roi,1) && size(vertices_roi,1) > 2
        vertices_roi = vertices_roi';
     end
   
    % find all related faces
    [~,locb] = ismember(vertices_roi, mesh.v, 'rows');
    %%%%%%%%%%%%%%%%% v.1 by using permutations, too much memory expensive %%%%%%%%%%%%%%%%%
%     visible_f = permn2(locb,3);
%     [lia2, ~] = ismember(mesh.f, visible_f);
%     [row,~] = find(lia2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [rows,~] = find(sum(ismember(mesh.f, locb)~= 0, 2) >= 2); % consider only faces where at least 2 vertices are visible to the person
    faces_roi = unique(rows);

      % plot found faces
%     hp = lightPerceptionTest(cadModel_, poses);
%     plot_CAD(cadModel_.f(faces_roi,:), hp.points3D_all', [], [0 1 0]);
end
