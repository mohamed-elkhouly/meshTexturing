clear all;
% fn='frame-000018.color.jpg';
% fn='frame-000022.color.jpg';
% fn='frame-000030.color.jpg';
% fn='frame-000239.color.jpg';
% fn='frame-000267.color.jpg';
% fn='frame-000460.color.jpg';
% fn='frame-000468.color.jpg';
% fn='frame-000479.color.jpg';
% fn='frame-000594.color.jpg';
% fn='frame-000600.color.jpg';
fn='frame-000604.color.jpg';
% fn='frame-000684.color.jpg';
% fn='frame-000723.color.jpg';
% fn='frame-000727.color.jpg';
% fn='frame-000722.color.jpg';
% fn='frame-000717.color.jpg';
% fn='frame-000714.color.jpg';
% fn='frame-000714.color2.jpg';
% fn='frame-000041.color.jpg';
% fn='frame-000065.color.jpg';
x=imread(fn);
% x=imread('frame-000018.color.jpg');
% x=imread('frame-000022.color.jpg');
% x=imread('frame-000030.color.jpg');
% x=imread('frame-000239.color.jpg');
% x=imread('frame-000267.color.jpg');
% x=imread('frame-000460.color.jpg');
% x=imread('frame-000468.color.jpg');
% x=imread('frame-000479.color.jpg');
% x=imread('frame-000594.color.jpg');
% x=imread('frame-000600.color.jpg');
% x=imread('frame-000604.color.jpg');
% x=imread('frame-000684.color.jpg');
% x=imread('frame-000723.color.jpg');
% x=imread('frame-000727.color.jpg');
% x=imread('frame-000722.color.jpg');
% x=imread('frame-000717.color.jpg');
% x=imread('frame-000714.color.jpg');
% x=imread('frame-000714.color2.jpg');
% x=imread('frame-000041.color.jpg');
% x=imread('frame-000065.color.jpg');
% x=imread('strange.jpg');
hsv_im=rgb2hsv(x);
ycbcr_im=rgb2ycbcr(x);
y=(ycbcr_im(:,:,1));
new_y=y;
[w,h]=size(y);

thresh_values = multithresh(y,20);
median_value=median(thresh_values);
yn =uint8( imquantize(y,thresh_values));
% yn =uint8( imquantize(y,[lower_thresh_values upper_thresh_values]));
%%
yn=histeq(yn);
figure;imshow((yn));
yn=medfilt2(yn,[10 10]);
figure;imshow((yn));
thresh_values=unique(yn);
%%
% se = strel('disk',10);
% closegray = imclose((yn),se);
% BW1 = edge(closegray,'canny');
% BW2 = edge(closegray,'sobel');
% BW1=BW1-BW2;
% figure;
% subplot(1,2,1);
% imshow((yn));
% subplot(1,2,2);imshow((BW1));
N=11;
tic
% required_group2={};
try 
    load([fn '.mat']);
catch
    for i=1:length(thresh_values)
        group_level(i).level=thresh_values(end-i+1);
        image_levels(:,:,i)=(yn==thresh_values(end-i+1));
        image_skel(:,:,i)=bwskel(imclose(image_levels(:,:,i),strel('disk',N)),'MinBranchLength',N);
        [image_objects(:,:,i),image_groups(i)]=bwlabel(image_levels(:,:,i));
        [image_skel_objects(:,:,i),image_skel_groups(i)]=bwlabel(image_skel(:,:,i));
        required_group=[];

        temp_var=image_objects(:,:,i);
        for j=1:image_skel_groups(i)
            current_group_mask=image_skel_objects(:,:,i)==j;        
            temp_var_val=temp_var(current_group_mask);   
           temp_var_val2= unique(temp_var_val);
%            temp_var_val2(temp_var_val2==0)=[];
           if ~isempty(temp_var_val2)
             required_group(j)=max(temp_var_val2);
    %          required_group2(i,j,:)={temp_var_val2};
             group_level(i).group(j).labels_contained={temp_var_val2};
           else
             required_group(j)=0;
    %          required_group2(i,j,:)={0};
             group_level(i).group(j).labels_contained={};
           end
            group_level(i).group(j).skeleton_size=sum(sum(temp_var_val>0));
            group_level(i).group(j).region_size=0;
            all_pixels=[];
            for k=1:length(temp_var_val2)            
             group_level(i).group(j).region_size=group_level(i).group(j).region_size+sum(sum(temp_var==temp_var_val2(k)));
             all_pixels=[all_pixels;find(temp_var==temp_var_val2(k))];
             temp_var(temp_var==temp_var_val2(k))=required_group(j);
            end
            group_level(i).group(j).pixels={all_pixels};
        end

    % check if the group is not from the skeleton selected groups make it zero
        for j=1:image_groups(i)
            if sum(required_group==j)==0
                temp_var(temp_var==j)=0;
            end
        end
        final_image_objects(:,:,i)=temp_var;
        image_regions(i,:)={required_group};
    end
    for i=1:length(thresh_values)
    %     current_used_groups=required_group2(i,:,:);
    %     %# find empty cells
    %     emptyCells = cellfun(@isempty,current_used_groups);
    %     %# remove empty cells
    %     current_used_groups(emptyCells) = [];
        current_image_level=image_levels(:,:,i);
        current_image_skel=image_skel(:,:,i);
        current_level_labeled_image=image_objects(:,:,i);
        current_skel_labeled_image=image_skel_objects(:,:,i);
        for j=1:length(group_level(i).group)% for each region
            current_used_groups=cell2mat(group_level(i).group(j).labels_contained);
            all_border_values=[];
            for k=1:length(current_used_groups)% for each small region related to this region.
                current_label_from_current_level=(current_level_labeled_image==current_used_groups(k));
                border_of_label_image=imdilate(current_label_from_current_level,strel('disk',3))-current_label_from_current_level;
                all_border_values=[all_border_values;yn(border_of_label_image>0)];
            end
            try
                next_lower_level=group_level(i+1).level;
            catch
                next_lower_level=-1;
            end
             try
                next_higher_level=group_level(i-1).level;
            catch
                next_higher_level=256;
            end
            
            group_level(i).group(j).total_border_all_low_ratio=sum(all_border_values<group_level(i).level)/length(all_border_values);            
            group_level(i).group(j).total_border_next_low_ratio=sum(all_border_values==next_lower_level)/length(all_border_values);
            group_level(i).group(j).total_border_next_high_ratio=sum(all_border_values==next_higher_level)/length(all_border_values);
            group_level(i).group(j).total_border_higher_ratio=sum(all_border_values>group_level(i).level)/length(all_border_values);
            group_level(i).group(j).border_levels={all_border_values};
        end
    end   
    save([fn '.mat'],'-v7.3');
end
 toc
figure;
subplot(2,3,1);imshow(image_levels(:,:,1));
subplot(2,3,2);imshow(image_levels(:,:,2));
subplot(2,3,3);imshow(image_levels(:,:,3));
subplot(2,3,4);imshow(image_levels(:,:,4));
subplot(2,3,5);imshow(image_levels(:,:,5));
subplot(2,3,6);imshow(image_levels(:,:,6));

figure;
subplot(2,3,1);imshow(image_skel(:,:,1));
subplot(2,3,2);imshow(image_skel(:,:,2));
subplot(2,3,3);imshow(image_skel(:,:,3));
subplot(2,3,4);imshow(image_skel(:,:,4));
subplot(2,3,5);imshow(image_skel(:,:,5));
subplot(2,3,6);imshow(image_skel(:,:,6));

figure;
subplot(2,3,1);imshow(image_levels(:,:,7));
subplot(2,3,2);imshow(image_levels(:,:,8));
subplot(2,3,3);imshow(image_levels(:,:,9));
subplot(2,3,4);imshow(image_levels(:,:,10));
subplot(2,3,5);imshow(image_levels(:,:,11));
subplot(2,3,6);imshow(image_levels(:,:,12));


figure;
subplot(2,3,1);imshow(image_skel(:,:,7));
subplot(2,3,2);imshow(image_skel(:,:,8));
subplot(2,3,3);imshow(image_skel(:,:,9));
subplot(2,3,4);imshow(image_skel(:,:,10));
subplot(2,3,5);imshow(image_skel(:,:,11));
subplot(2,3,6);imshow(image_skel(:,:,12));


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% h = fspecial('average', 11);
% y = imfilter(y, h);
% for i=1:w
%  [~, wpl]=  findpeaks(y(i,:));
%  new_y(i,wpl)=1;
% end
% figure;imshow(new_y);
% for i=1:h
%  [~, hpl]=  findpeaks(y(:,i));
%  new_y(hpl,i)=1;
% end
% figure;imshow(new_y);
% d=[];