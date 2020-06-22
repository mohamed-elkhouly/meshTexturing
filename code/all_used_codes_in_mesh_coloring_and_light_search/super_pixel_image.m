function  [outputImage,BW]=super_pixel_image(A,average_num_pixels,show)

number_of_sp=round(size(A,1)*size(A,2)/average_num_pixels);
img2=rgb2lab(A);
img2(:,:,2)=img2(:,:,1);
img2(:,:,3)=img2(:,:,1);
tic;[L,N] = superpixels(img2,number_of_sp,'Compactness',0.1,'Method','slic');toc;
  BW = boundarymask(L);
if(show)
    figure;
  
    imshow(imoverlay(A,BW,'cyan'));
end
outputImage = zeros(size(A),'like',A);
idx = label2idx(L);
numRows = size(A,1);
numCols = size(A,2);
for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    outputImage(redIdx) = median(A(redIdx));
    outputImage(greenIdx) = median(A(greenIdx));
    outputImage(blueIdx) = median(A(blueIdx));
end
if(show)
    figure;imshow(outputImage);
end