function [sunlight_pixels, artificial_pixels, specular_pixels, skylight_pixels,auto_detected_light]=show_region(scene_from_json,region_to_view,all_frames_path,scene_name,write_flag)
if nargin<5
    write_flag=0;
end
sunlight_pixels=[];
artificial_pixels=[]; 
specular_pixels=[]; 
skylight_pixels=[];
auto_detected_light=[];
required_frames=scene_from_json.region(region_to_view+1).all_frames;
for i=1:length(required_frames)
    
    %     hold on
    frame_string_name=sprintf('frame-%06d.color.jpg',required_frames(i));
    frame_name=sprintf([all_frames_path,frame_string_name]);
    if(~isempty(all_frames_path))
        original_image=imread(frame_name);
    else
        original_image=[];
    end
    
    
    current_frame=scene_from_json.frames(required_frames(i)+1);
    if(~isempty(current_frame.sunlight_annotations))
        %        sunlight annotation view
        sunlight_pixels(end+1,1)=required_frames(i);
        all_annotations=current_frame.sunlight_annotations;
        [original_image,sunlight_pixels_temp]=get_annotated_pixels(all_annotations,original_image,[255,255,0]);
        sunlight_pixels(end,2:length(sunlight_pixels_temp)+1)=sunlight_pixels_temp';
    end
    if(~isempty(current_frame.artificial_annotations))
        
        %        artificial_annotations view
        artificial_pixels(end+1,1)=required_frames(i);
        all_annotations=current_frame.artificial_annotations;
        [original_image,artificial_pixels_temp]=get_annotated_pixels(all_annotations,original_image,[0,255,0]);
        artificial_pixels(end,2:length(artificial_pixels_temp)+1)=artificial_pixels_temp';
    end
    if(~isempty(current_frame.specular_annotations))
        %        specular_annotations view
        specular_pixels(end+1,1)=required_frames(i);
        all_annotations=current_frame.specular_annotations;
        [original_image,specular_pixels_temp]=get_annotated_pixels(all_annotations,original_image,[255,0,0]);
        specular_pixels(end,2:length(specular_pixels_temp)+1)=specular_pixels_temp';
        
    end
    if(~isempty(current_frame.skylight_annotations))
        %        skylight_annotations view
        skylight_pixels(end+1,1)=required_frames(i);
        all_annotations=current_frame.skylight_annotations;
        [original_image,skylight_pixels_temp]=get_annotated_pixels(all_annotations,original_image,[0,255,255]);
        skylight_pixels(end,2:length(skylight_pixels_temp)+1)=skylight_pixels_temp';
        
    end
    try
    if(~isempty(current_frame.reflection_annotations))
        %        sunlight annotation view
        auto_detected_light(end+1,1)=required_frames(i);
        all_annotations=current_frame.reflection_annotations;
        [original_image,reflection_pixels_temp]=get_annotated_pixels(all_annotations,original_image,[255,255,0]);
        auto_detected_light(end,2:length(reflection_pixels_temp)+1)=reflection_pixels_temp';
    end
    catch
        d=[];
    end
    %     imshow(original_image)
    if(write_flag==1)
        imwrite(original_image,['annotated/',scene_name,'/',frame_string_name]);
    end
end
end

function [original_image,all_annotated_pixels]=get_annotated_pixels(all_annotations,original_image,color)
all_annotated_pixels=[];
if (~isempty(original_image))
red=original_image(:,:,1);
green=original_image(:,:,2);
blue=original_image(:,:,3);
image_size=size(original_image);
else
image_size=[1024 1280 3];    
end

image_size(3)=[];
for k=1:length(all_annotations)
    all_points_x=all_annotations(k).all_points_x;
    all_points_y=all_annotations(k).all_points_y;
    new_image=zeros(image_size);
    I = sub2ind(image_size,all_points_x,all_points_y);
    new_image(I)=1;
    new_image=new_image>0;
    new_image=imfill(new_image,'holes');
    all_annotated_pixels=[all_annotated_pixels;find(new_image)];
    %                 imshow(new_image>0);
end
%         [I,J] = ind2sub(image_size,all_annotated_pixels);
if(~isempty(original_image))
red(all_annotated_pixels)=color(1);
green(all_annotated_pixels)=color(2);
blue(all_annotated_pixels)=color(3);
original_image(:,:,1)=red;
original_image(:,:,2)=green;
original_image(:,:,3)=blue;
end
end
