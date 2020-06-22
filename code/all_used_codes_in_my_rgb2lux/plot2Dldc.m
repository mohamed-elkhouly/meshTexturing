function [] = plot2Dldc(ldc)
    color = 'r';
    line = '-';
    theta = 0:5:180;
    figure,
    for i = 1:7:size(ldc,2)
    polarplot(degtorad(theta),ldc(:,i), 'Color', color, 'LineStyle', line, 'LineWidth', 1.5)
    hold on
    polarplot(-degtorad(theta),ldc(:,i), 'Color' ,color, 'LineStyle', line, 'LineWidth', 1.5)
    color = 'r';
    line = ':';
    end
    ax = gca;
    ax.ThetaZeroLocation = 'bottom';
    ax.RAxisLocation = 0;
    ax.ThetaTickLabel = {'0'; '30'; '60'; '90'; '120'; '150'; '180'; '150'; '120'; '90'; '60'; '30';};
end