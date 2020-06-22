clear all;
img2=imread('frame/12.jpg');

tic
ycbcr=rgb2ycbcr(img2);
luminance=ycbcr(:,:,1);
figure;imshow(luminance)

img2_back=img2;
% img2=rgb2lab(img2);
% img2(:,:,2)=img2(:,:,1);
% img2(:,:,3)=img2(:,:,1);
% img2=rgb2ycbcr(img2);
% average_num_pixels=10000;
% for i=1:30
average_num_pixels=25;
number_of_sp=round(size(img2,1)*size(img2,2)/average_num_pixels);
show=1;
[img2,BW]=super_pixel_image(img2,average_num_pixels,show);
% end
thr=0.7;
min_pixels_in_group=10;

max_pix_distance=13;
se = strel('disk',1);se2 = strel('disk',2);se3 = strel('disk',3);se4 = strel('disk',4);
% figure;subplot(1,2,1);imshow(img);subplot(1,2,2);imshow(img2);

img2=img2_back;
img2= medfilt3(img2,[3 3 3]);
thresholded_img=apply_high_pass_filter(img2,thr);
thresholded_img=~([~thresholded_img+BW]);
% figure; imshow(imoverlay(img2,[~thresholded_img+BW],'cyan'));

thresholded_img=bwmorph(thresholded_img,'clean');
black_pixels=~thresholded_img;
black_pixels_cleaned=bwmorph(black_pixels,'clean');
thresholded_img((black_pixels-black_pixels_cleaned)>0)=1;

% figure; imshow(imoverlay(img2,~thresholded_img,'cyan'));

% [L,N]=bwlabel(thresholded_img);
% outputImage=apply_median_on_labeled_image(img2,L,N);
% figure; imshow(outputImage);

% img2=outputImage;

ConC = bwconncomp(thresholded_img);
ALL_groups=ConC.PixelIdxList;
% flag=false(length(ALL_groups),1);
% fill the black holes in regions by closing each region separately.
temp_img=black_pixels;
L=black_pixels;
L(:)=0;
for i=1:length(ALL_groups)
    flag=length(cell2mat(ALL_groups(i)))>min_pixels_in_group;
    if(flag)
        temp_img(:)=0;
        temp_img(cell2mat(ALL_groups(i)))=1;
        temp_img2=temp_img;
        temp_img=bwmorph(temp_img,'spur');
        temp_img=imclose(temp_img,se);
%         temp_img(outer_border)=temp_img2(outer_border);
        L(temp_img)=temp_img(temp_img);
    end
end
figure;imshow(L);
[L2,N]=bwlabel(L);
outputImage=apply_median_on_labeled_image(img2,L2,N);
figure; imshow(outputImage);

[L,n] = bwlabel(L);
% [L,n] = bwlabel(thresholded_img);
[L_blkbefore,n_blkbefore] = bwlabel(L==0);
black_pixels=black_pixels_cleaned;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
[L_blk,n_blk] = bwlabel(~L);
temp_img=L>0;
count=0;
% fill the black holes which all of its border line fall in one group.
for i=1:n_blk
    temp_img(:)=0;
    which_pixels=L_blk==i;
    temp_img(which_pixels)=1;
    temp_img=imdilate(temp_img,se);
    which_pixels=temp_img>0;
    labels_on_border=unique(L(which_pixels));
    labels_on_border(1)=[];
    if(length(labels_on_border)==1)
        L(which_pixels)=labels_on_border;
        count=count+1;
    end
end
figure;imshow(L);
ConC = bwconncomp(L);
groups_borders=(L>0)-imerode((L>0),se);
figure;imshow(groups_borders);
[L2,N]=bwlabel(L);
outputImage=apply_median_on_labeled_image(img2,L2,N);
figure; imshow(outputImage);

[Labels,n_labels]=bwlabel((L>0));
Labels_of_borders=Labels;
Labels_of_borders(~groups_borders)=0;

border_pixels_correspondences=[];
for i=1:max_pix_distance
temp_border_pixels_correspondences=get_border_pixels_correspondences2(Labels_of_borders,i);
border_pixels_correspondences=[border_pixels_correspondences;temp_border_pixels_correspondences];
end
[connected_regions_numbers,connected_regions_count]=count_regions_to_regions_correspondences(border_pixels_correspondences);
region_faces=ConC.PixelIdxList;
number_of_all_pixels=size(Labels,1)*size(Labels,2);
faces_correspondences=cell(1,n_labels);
groups_indexing=border_pixels_correspondences(:,1:2);
num_faces_in_region=[];
for i=1:n_labels
    current_group_pixels_flag=sum(groups_indexing==i,2)>0;
    faces_correspondences(i)={border_pixels_correspondences(current_group_pixels_flag,3:4)};
    num_faces_in_region(i)=length(cell2mat(region_faces(i)));
end

[~,inda]=sort(num_faces_in_region,'descend');
% region_faces=region_faces(inda);
% faces_correspondences=faces_correspondences(inda);

final_regions_connections=organize_regions_to_be_balanced(faces_correspondences(inda),[],number_of_all_pixels,region_faces(inda));
for j=1:length(final_regions_connections)
temp_r_co=cell2mat(final_regions_connections(j));
temp_r_co2=temp_r_co;
for i=1:length(inda)
    temp_r_co2(temp_r_co==i)=inda(i);
end
final_regions_connections(j)={temp_r_co2};
end

ycbcr=rgb2ycbcr(img2);
luminance=ycbcr(:,:,1);
mask_size=13;
luminance=medfilt2(luminance,[mask_size mask_size]);
faces_correspondences1=[];
for i=1:length(faces_correspondences)
    faces_correspondences1=[faces_correspondences1;cell2mat(faces_correspondences(i))];
end
for i=1:length(final_regions_connections)
    current_connected_groups=cell2mat(final_regions_connections(i));
    %     current_connected_groups2=order_groups_based_on_correspondings(current_connected_groups,faces_correspondences1,region_faces);
    %     current_connected_groups=current_connected_groups2;
    current_connected_groups=current_connected_groups';
    current_connected_groups=current_connected_groups(:);
    current_connected_groups(current_connected_groups==0)=[];
    % remove repeated elements in the next for
    for j=1:length(current_connected_groups)
        flag=current_connected_groups==current_connected_groups(j);
        flag(j)=0;% forbidden it from counting our current case;
        current_connected_groups(flag)=0;
    end
    current_connected_groups(current_connected_groups==0)=[];
    luminance=perform_balance_on_pixels_groups(current_connected_groups,region_faces,faces_correspondences1,number_of_all_pixels,luminance,connected_regions_numbers,connected_regions_count);
end
toc
d=[];