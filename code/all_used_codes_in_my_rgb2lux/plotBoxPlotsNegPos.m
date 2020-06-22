%% script for the signed evaluation of the ground truth luxmeter values with the estimated illumination values
% INPUT:
%   1. luxmeter readings
%   2. luxmeter patches
%   3. estimated illumination map
%   4. title
function [E] = plotBoxPlotsNegPos(luxMeter, luxmeterPatches, h, id)
    E = h(luxmeterPatches, :);
    lux_error = E - luxMeter;
%     round(mean(lux_error,2))
%     round(mean(mean(lux_error,2)))
    figure, notBoxPlot2(lux_error(:,:)', 'jitter', 0.45);
%     figure, notBoxPlot(lux_error(:,:)', 'jitter', 0.45, 'style', 'sdline');
    hold on
    boxplot(lux_error(:,:)');
    medianLine = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    outliers =findobj(gcf, 'tag', 'Outliers'); 
    set(medianLine,'Visible','off');
    set(outliers,'Visible','off');
%     set(medianLine, 'Color', 'g');
    grid on
    ylim([-200 200]);
    set(gca, 'Ytick', -200:50:200);
    set(gca, 'fontsize', 12);
    xlabel('Luxmeters');
    ylabel('Error (Lux)');
    title(id, 'Interpreter', 'none');
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    
%     saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/', id, '.png'));
%     saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/', id, '.fig'));
end