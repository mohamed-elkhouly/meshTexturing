% renaming_masks

path='Face_numbers_masks'
scenes=dir(path);
scenes(1:2)=[];
for i =1:length(scenes)
    scene_name=scenes(i).name;
    movefile([path,'/',scene_name,'/masks'],[path,'/',scene_name,'/frames_faces_mapping']);
%     frames_path=[path,'/',scene_name,'/masks/*.png'];
%     images=dir(frames_path);
%     for j=1:length(images)
%         image_name=images(j).name;
%         new_image_name=sprintf('frame-%06d.color.png',str2num(image_name(7:end-4)));
% %         image=imread([path,'/',scene_name,'/masks/',image_name]);
% %         imwrite(image,[path,'/',scene_name,'/masks/',new_image_name]);
% %         delete([path,'/',scene_name,'/masks/',image_name]);
%         movefile([path,'/',scene_name,'/masks/',image_name],[path,'/',scene_name,'/masks/',new_image_name]);
% %         movefile([path,'/',scene_name,'/masks/',[image_name(1:end-3),'txt']],[path,'/',scene_name,'/masks/',[new_image_name(1:end-3),'txt']]);
%     end
%     d=[];
end