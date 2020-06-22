function write_mesh_down_into_images(folder_path,region_frames,end_of_faces_indexing,start_of_faces_indexing,current_colors,scene_name,region_number,flag)
figure;
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number)]);
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number),'/original']);
mkdir(['mesh_coloring/',scene_name,'/',num2str(region_number),'/ours']);
for kk=1:size(region_frames,1)
    fame_num=region_frames(kk,1);
 file_path=[folder_path,'/frames_faces_mapping/','frame-',sprintf('%06d',fame_num-1),'.color.png'];
    [faces_image,~,trans]=imread(file_path);
    r=faces_image(:,:,1);
    g=faces_image(:,:,2);
    b=faces_image(:,:,3);
    A=double([trans(:),r(:),g(:),b(:)]);
    faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
    required_faces_from_image=false(size(faces_numbers));
    new_image=zeros(size(faces_numbers,1),3);
    faces_numbers=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
    faces_numbers(faces_numbers>end_of_faces_indexing)=-1;
    faces_numbers=faces_numbers-start_of_faces_indexing;
     required_faces_from_image(faces_numbers>0)=1;
     red=current_colors(:,1);
     green=current_colors(:,2);
     blue=current_colors(:,3);
     new_image(required_faces_from_image,1)=red(faces_numbers(required_faces_from_image));
     new_image(required_faces_from_image,2)=green(faces_numbers(required_faces_from_image));
     new_image(required_faces_from_image,3)=blue(faces_numbers(required_faces_from_image));
     new_image=reshape(new_image,[1024,1280,3]);
     new_image=uint8(new_image);
     
     ycbcr=rgb2ycbcr(new_image);
% windowSize = 17;
% kernel = ones(windowSize) / windowSize^2;
% heat_map = conv(double(ycbcr(:,:,1)), kernel, 'same');
imshow(ycbcr(:,:,1));
colormap(gcf, hsv(256));
%      figure;imshow();

if(flag)
imwrite(new_image,['mesh_coloring/',scene_name,'/',num2str(region_number),'/original/frame-',sprintf('%06d',fame_num-1),'.color.png']);
saveas(gcf,['mesh_coloring/',scene_name,'/',num2str(region_number),'/original/frame-',sprintf('%06d',fame_num-1),'.colorhm.png']);
else
    imwrite(new_image,['mesh_coloring/',scene_name,'/',num2str(region_number),'/ours/frame-',sprintf('%06d',fame_num-1),'.color.png']);
    saveas(gcf,['mesh_coloring/',scene_name,'/',num2str(region_number),'/ours/frame-',sprintf('%06d',fame_num-1),'.colorhm.png']);
end
end

d=[];