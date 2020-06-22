%# create AVI object 
% http://stackoverflow.com/questions/11051307/approaches-to-create-a-video-in-matlab
% http://stackoverflow.com/questions/12157558/how-to-make-and-save-a-videoavi-in-matlab

% black = 0; saturation = 4095;
% for i = 1:size(imgs,3)
% lin_bayer(:,:,i) = (imgs(:,:,i)-black)/(saturation-black);
% lin_bayer(:,:,i) = max(0,min(lin_bayer(:,:,i),1));
% end

function createVideoClip(imgs, name, framerate, estimationVectors)
    if isempty(framerate)
        framerate = 25;
    end
    nFrames = size(imgs,4);
    vidObj = VideoWriter(name);
    vidObj.Quality = 100;
%     vidObj.CompressionRatio = 5;
    vidObj.FrameRate = framerate;
    open(vidObj);
    %# create movie
    rgbImage = uint8(255*mat2gray(imgs(:,:,:,1)));
%     rgbImage = repmat(rgbImage(:,:),[1 1 3]);
%     
%     conf_val = estimationVectors(:,1);
%     position = [380 5; 380 27; 380 49; 380 71; 380 93; 380 115; 380 137];
%     for ii=1:7
%         text_str{ii} = ['Light_' num2str(ii) ': ' num2str(conf_val(ii),'%0.3f')];
%         if conf_val(ii) >= 0.5;
%             box_color{ii} = 'green';
%         else
%             box_color{ii} = 'red';
%         end
%     end
    
%     rgbImage = insertText(rgbImage,position,text_str,'FontSize',10,'BoxColor', box_color,'BoxOpacity',0.4,'TextColor','white');
    imshow(rgbImage(:,:,:),[]);
%     movegui(h);
%     set(gcf,'Color','None')
%     gif('myfile.gif') % Or specify options like this: 
    gif('myfile1.gif','DelayTime',1,'LoopCount',1)
    for i=2:nFrames
        rgbImage = uint8(255*mat2gray(imgs(:,:,:,i)));
%         rgbImage = repmat(rgbImage(:,:),[1 1 3]);
%         conf_val = estimationVectors(:,i);
% %         conf_val = mat2gray(estimationVectors(:,i));
%         for ii=1:7
%             text_str{ii} = ['Light_' num2str(ii) ': ' num2str(conf_val(ii),'%0.3f')];
%             if conf_val(ii) >= 0.5;
%                 box_color{ii} = 'green';
%             else
%                 box_color{ii} = 'red';
%             end
%         end
% 
%         rgbImage = insertText(rgbImage,position,text_str,'FontSize',10,'BoxColor', box_color,'BoxOpacity',0.4,'TextColor','white');
        imshow(rgbImage(:,:,:),[]);
%         set(gcf,'Color','None')
        gif
        writeVideo(vidObj, getframe(gca));
    end
    
    close(gcf)
    close(vidObj);
end