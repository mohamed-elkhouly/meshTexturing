figure, notBoxPlot(error(:,1:31)', 'jitter', 0.45, 'style', 'sdline');
hold on
boxplot(error(:,1:31)');
medianLine = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(medianLine, 'Color', 'g');