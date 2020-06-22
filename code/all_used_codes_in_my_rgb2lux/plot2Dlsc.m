function [] = plot2Dlsc(lsc)
    color = 'b';
    line = '-';
    theta = 0:10:180;
    figure,
    for i = 1:10:size(lsc,2)
    h1 = polarplot(degtorad(theta),lsc(:,i), 'Color', color, 'LineStyle', line, 'LineWidth', 1.5)
    hold on 
    h2 = polarplot(-degtorad(theta),lsc(:,i), 'Color' ,color, 'LineStyle', line, 'LineWidth', 1.5)
    color = 'b';
    line = ':';
    end
%     legend([h1],{'LSC'});  % Only the blue and green lines appear in the legend
    ax = gca;
    ax.ThetaZeroLocation = 'bottom';
    ax.RAxisLocation = 0;
    ax.ThetaTickLabel = {'0'; '30'; '60'; '90'; '120'; '150'; '180'; '150'; '120'; '90'; '60'; '30';};
end