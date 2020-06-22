function plotGraphs2(luxMeter, reluxLux, radiosity1, radiosity2, radiosity3)%, radiosity4)

    for i = 1:size(luxMeter,1)
        diff = abs(luxMeter(i,:) - reluxLux(i,:));
        figure, p = plot(luxMeter(i,:), '-s');
        hold on
        h = plot(reluxLux(i,:), '-o');
        hh = plot(radiosity1(i,:), '-o');
        hhh = plot(radiosity2(i,:), '-o');
        hhhh = plot(radiosity3(i,:), '-o');
%         hhhhh = plot(radiosity4(i,:), '-o');
        
        
%         for j = 1:size(luxMeter(i,:),2);
%             if luxMeter(i,j) > reluxLux(i,j)
%                 text(j, luxMeter(i,j) + 20, num2str(round(diff(j))), 'FontSize', 12, 'FontWeight', 'bold');
%             else
%                 text(j, reluxLux(i,j) + 20, num2str(round(diff(j))), 'FontSize', 12, 'FontWeight', 'bold');
%             end
%         end
        
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        set(p, 'LineWidth', 2, 'MarkerSize', 5);
        set(h, 'LineWidth', 2, 'MarkerSize', 5);
        set(hh, 'LineWidth', 2, 'MarkerSize', 5);
        set(hhh, 'LineWidth', 2, 'MarkerSize', 5);
        set(hhhh, 'LineWidth', 2, 'MarkerSize', 5);
%         set(hhhhh, 'LineWidth', 2, 'MarkerSize', 5);
        grid on;
        
        xlim([0 size(luxMeter,2)+1]);
        set(gca, 'Xtick', 0:1:size(luxMeter,2));
        y_lim = max(luxMeter(i,:));
        if(y_lim < max(reluxLux(i,:)))
            y_lim = max(reluxLux(i,:));
        end
        set(gca, 'Ytick', 0:100:y_lim+200);
        set(gca, 'fontsize', 12);
        % get the position of the title
        titleHandle = get(gca, 'Title');
        titlePos = get(titleHandle, 'Position');
        % change the x value  to 0
        titlePos(2) = titlePos(2) - 150; % set position of title for luxmeter
        % update the position
        set(titleHandle , 'Position' , titlePos);
        

        addTopXAxis(gca, 'expression', 'argu', 'xlabstr', 'Active luminaires');
        
        title(strcat({'Luxmeter'}, {' '}, {num2str(i)}));
        xlabel('Different illumination combinations');
        ylabel('Lux');
        legend({'Luxmeter', 'Relux', 'Ours (no LDC/LSC)', 'Ours (with LDC/LSC)', 'RGBD2Lux'}, 'FontSize', 14);
        legend('Location','northwest');
        
%         saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/luxmeter_',num2str(i),'.png'));
%         saveas(gcf, strcat('figs/luxmeter_vs_radiosity(room1)/luxmeter_',num2str(i),'.fig'));
    end

end