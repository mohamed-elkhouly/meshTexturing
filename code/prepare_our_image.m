function [all_images,image_gradients,image]=prepare_our_image(i,index,all_images,data_path)
image_name=sprintf('frame-%06d.color.jpg',i);
image_name2=sprintf('frame-%06d.color.png',i);
image_path=[data_path,'/frame/',image_name];
image_path2=[data_path,'/frame/',image_name2];
try
    image=imread(image_path);
    try
        image(2,342:916,:)=image(3,342:916,:);image(1,221:1038,:)=image(2,221:1038,:); % fix zeros_which is in top of each image in matterport.
        image(1023,419:836,:)=image(1022,419:836,:);image(1024,267:992,:)=image(1023,267:992,:); % fix zeros_which is in bottom of each image in matterport.
        image(335:670,1,:)=image(335:670,2,:); % fix zeros_which is in
%         left of each image in matterport. we should not use to unify
%         environment


%         img2=image;
%         average_num_pixels=25;
%         number_of_sp=round(size(img2,1)*size(img2,2)/average_num_pixels);
%         show=0;
%         [img2,~]=super_pixel_image(img2,average_num_pixels,show);
%         image=img2;
        
        
    catch
    end
    
catch
    image=imread(image_path2);
end
all_images(index,:,:,:)=image;
image_gradients=imgradient3(image,'sobel');
% [height,width,~]=size(image);
%     M_max=max(image,[],3);
%     M1=M_max;
%     lab_img=rgb2hsv(image);
%     lab_img=rgb2lab(image);
% lab_img=rgb2ycbcr(image);
lab_img=image;
% L_channel=lab_img(:,:,1);
% a_channel=lab_img(:,:,2);
% b_channel=lab_img(:,:,3);