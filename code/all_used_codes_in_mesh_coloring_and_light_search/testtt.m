img2=imread('frame/1.jpg');
tic
img2= medfilt3(img2,[3 3 3]);
% figure;subplot(1,2,1);imshow(img);subplot(1,2,2);imshow(img2);
% Filter 1
kernel1 = -1 * ones(3)/9;
kernel1(2,2) = 8/9;
kernel1 = [-1 -2 -1; -2 12 -2; -1 -2 -1]/16;
% Filter the image.  Need to cast to single so it can be floating point
% which allows the image to have negative values.
filteredImage_r = imfilter(single(img2(:,:,1)), kernel1);
filteredImage_g = imfilter(single(img2(:,:,2)), kernel1);
filteredImage_b = imfilter(single(img2(:,:,3)), kernel1);
% figure;subplot(1,3,1);imshow(filteredImage_r>0.7);subplot(1,3,2);imshow(filteredImage_g>0.7);subplot(1,3,3);imshow(filteredImage_b>0.7);
thr=0.3;
min_pixels_in_group=10;
se = strel('disk',1);
se2 = strel('disk',2);
se3 = strel('disk',3);
se4 = strel('disk',4);

thresholded_img=(~(filteredImage_r>thr|filteredImage_g>thr|filteredImage_b>thr));
figure;imshow(thresholded_img);

thresholded_img=bwmorph(thresholded_img,'clean');
black_pixels=~thresholded_img;
black_pixels_cleaned=bwmorph(black_pixels,'clean');
thresholded_img((black_pixels-black_pixels_cleaned)>0)=1;

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
        temp_img=imclose(temp_img,se4);
        L(temp_img)=temp_img(temp_img);
    end
end
figure;imshow(L);

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

[Labels,n_labels]=bwlabel((L>0));
Labels_of_borders=Labels;
Labels_of_borders(~groups_borders)=0;
border_pixels_correspondences=get_border_pixels_correspondences(Labels_of_borders);
region_faces=ConC.PixelIdxList;
number_of_all_pixels=size(Labels,1)*size(Labels,2);
faces_correspondences=cell(1,n_labels);
groups_indexing=border_pixels_correspondences(:,1:2);
for i=1:n_labels
    current_group_pixels_flag=sum(groups_indexing==i,2)>0;
    faces_correspondences(i)={border_pixels_correspondences(current_group_pixels_flag,3:4)};
end
final_regions_connections=organize_regions_to_be_balanced(faces_correspondences,[],number_of_all_pixels,region_faces);



toc
d=[];