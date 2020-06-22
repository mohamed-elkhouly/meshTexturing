function plot_vertices (points, color, markerSize)

    %args
    if nargin < 2 
        % initialize number of rays to be thrown in the scene each time
        color = 'b.'; % color should be always in the form of 'color.', do not forget the dot (.)
    end
    
    if nargin < 3 
        % initialize number of rays to be thrown in the scene each time
        markerSize = 5;
    end
    
    if size(points,2)>size(points,1) && size(points,1) > 2
        points = points';
    end
    % Plot all the points
%     plot3(points(:,1),points(:,2),points(:,3),color,'MarkerSize', markerSize)
%     for i = 1:size(points,2)
%     text(points(1,i), points(2,i), points(3,i), num2str(i), 'Color', 'b', 'FontSize', 10);
%     end
%     or
    scatter3(points(:,1),points(:,2),points(:,3), markerSize, color, 'Marker', '.');
    
%     % Adjust settings
%     set(gcf,'PaperPosition',[0.6345175 6.34517 20.30456 15.22842]);
%     set(gcf,'PaperSize',[20.984 29.677]);
%     set(gcf,'Position',[1 1 959 725]);
%     set(gca,'Position',[0.13 0.11 0.775 0.815])
% %     set(gca,'View',[-21.20 88.48])
% %     set(gca,'CameraPosition',[-622.722 -913.060 1404.062])
% %     set(gca,'CameraTarget',[163.02 110.939 19.93])
% %     set(gca,'CameraUpVector',[0.445 0.58 0.68])
% %     set(gca,'CameraViewAngle',7.693)
%     axis equal
%     set(gcf,'Color','White')
    
    hold on
end