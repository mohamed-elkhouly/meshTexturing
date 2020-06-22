function p = plot_CAD(F, V, filename, C)
% function p = plot_CAD(F, V, C, filename)
%args
    if nargin < 3 
        % if beckers is chosen the specify technique the rays would be
        % arranged, i.e. random = 1 or deterministic = 2
        filename = [];
    end
    if nargin < 4 
        % method to be used for constracting the globe and throwing the
        % rays isocell = 1, or beckers = 2
        C = repmat([0.5 0.5 0.5],[size(F,1) 1]);
    elseif size(C) ~= size(F)
        C = repmat(C,[size(F,1) 1]);
    end
    
% p = patch('Faces', F, 'Vertices' ,V);
p = drawMesh(V, F);

%     set(p, 'facec', 'b');              % Set the face color (force it)
%     set(p, 'facec', [0.5 0.5 0.5]);            % Set the face color gray
    set(p, 'facec', 'flat');            % Set the face color flat

    set(p, 'FaceVertexCData', C);       % Set the color (from file)
%     p.FaceVertexCData = repmat([1 0 0],[size(F,1) 1]);
      
%     set(p, 'facealpha',0.4);             % Use for transparency

    set(p, 'EdgeColor','none');         % Set the edge color
%     set(p, 'EdgeColor',[1 0 0]);      % Use to see triangles, if needed.

    light;                               % add a default light
    daspect([1 1 1]);                    % Setting the aspect ratio
    view(3);                             % Isometric view
    xlabel('X (mm)'),ylabel('Y (mm)'),zlabel('Z (mm)');
%     title(['Imported CAD data from ' filename])
    drawnow;                             %, axis manual