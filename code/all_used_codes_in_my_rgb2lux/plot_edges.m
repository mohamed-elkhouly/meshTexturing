function h = plot_edges(edges, vertex, color, lineWidth)

% plot_edges - plot a list of edges
%
%   h = plot_edges(edges, vertex, color);
%
%   Copyright (c) 2004 Gabriel Peyr

if nargin < 3
    color = 'b';
end

if nargin < 3
    lineWidth = 1;
end

if size(vertex,1)>size(vertex,2)
    vertex = vertex';
end

if size(edges,1)>size(edges,2)
    edges = edges';
end

x = [ vertex(1,edges(1,:)); vertex(1,edges(2,:)) ];
y = [ vertex(2,edges(1,:)); vertex(2,edges(2,:)) ];
if size(vertex,1)==2
    h = line(x,y, 'color', color);
elseif size(vertex,1)==3
    z = [ vertex(3,edges(1,:)); vertex(3,edges(2,:)) ];
    h = line(x,y,z, 'color', color, 'LineWidth', lineWidth);    
else
    error('Works only for 2D and 3D plots');    
end

    % Adjust settings
    set(gcf,'PaperPosition',[0.6345175 6.34517 20.30456 15.22842]);
    set(gcf,'PaperSize',[20.984 29.677]);
    set(gcf,'Position',[1 1 959 725]);
    set(gca,'Position',[0.13 0.11 0.775 0.815])
%     set(gca,'View',[-21.20 88.48])
%     set(gca,'CameraPosition',[-622.722 -913.060 1404.062])
%     set(gca,'CameraTarget',[163.02 110.939 19.93])
%     set(gca,'CameraUpVector',[0.445 0.58 0.68])
%     set(gca,'CameraViewAngle',7.693)
    axis equal
    set(gcf,'Color','White')
    
    hold on