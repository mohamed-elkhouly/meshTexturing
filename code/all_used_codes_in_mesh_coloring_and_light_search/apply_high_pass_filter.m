function thresholded_img=apply_high_pass_filter(img2,thr)
% Filter 1
kernel1 = -1 * ones(3)/9;
kernel1(2,2) = 8/9;
kernel1 = [-1 -2 -1; -2 12 -2; -1 -2 -1]/16;
% Filter the image.  Need to cast to single so it can be floating point
% which allows the image to have negative values.
filteredImage_r = imfilter(single(img2(:,:,1)), kernel1);
filteredImage_g = imfilter(single(img2(:,:,2)), kernel1);
filteredImage_b = imfilter(single(img2(:,:,3)), kernel1);
thresholded_img=(~(filteredImage_r>thr|filteredImage_g>thr|filteredImage_b>thr));

% thr=0.7;
% img3=rgb2lab(img2);
% filteredImage_r = imfilter(single(img3(:,:,1)), kernel1);
% filteredImage_g = imfilter(single(img3(:,:,2)), kernel1);
% filteredImage_b = imfilter(single(img3(:,:,3)), kernel1);
% thresholded_img3=(~(filteredImage_r>thr|filteredImage_g>thr|filteredImage_b>thr));
% 
% thresholded_img=thresholded_img&thresholded_img3;