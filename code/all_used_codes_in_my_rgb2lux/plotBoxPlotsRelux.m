function plotBoxPlotsRelux(luxMeter, reluxLux, id)
    lux_error = abs(luxMeter - reluxLux);
%     lux_error = reluxLux - luxMeter;%abs(luxMeter - reluxLux);
    round(mean(lux_error,2))
    round(mean(mean(lux_error,2)))
%     figure, notBoxPlot2(lux_error(:,:)', 'jitter', 0.45);
    figure, notBoxPlot(lux_error(:,:)', 'jitter', 0.45, 'style', 'sdline');
    hold on
    boxplot(lux_error(:,:)');
    medianLine = findobj(gcf, 'type', 'line', 'Tag', 'Median');
%     set(medianLine,'Visible','off');
    set(medianLine, 'Color', 'g');
    grid on
    ylim([-100 800]);
    set(gca, 'Ytick', -100:100:800);
    set(gca, 'fontsize', 12);
    xlabel('Luxmeters');
    ylabel('Error (Lux)');
    title(id, 'Interpreter', 'none');
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    
%     saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/', id, '.png'));
%     saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/', id, '.fig'));
end