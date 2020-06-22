for i=1:11
A=imread(['frame/',num2str(i),'.jpg']);
number_of_sp=round(size(A,1)*size(A,2)/100);
tic;[L,N] = superpixels(A,number_of_sp,'Compactness',0.1,'Method','slic');toc;
figure;
BW = boundarymask(L);
imshow(imoverlay(A,BW,'cyan'));
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
% figure;imshow(outputImage)
ycbcr_im=rgb2ycbcr(outputImage);
figure;imshow(ycbcr_im(:,:,1));

A=outputImage;
number_of_sp=round(size(A,1)*size(A,2)/5000);
tic;[L,N] = superpixels(A,number_of_sp,'Compactness',0.1,'Method','slic');toc;
figure;
BW = boundarymask(L);
imshow(imoverlay(A,BW,'cyan'));
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
figure;imshow(outputImage)
end