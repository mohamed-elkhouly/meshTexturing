function outputImage=apply_median_on_labeled_image(A,L,N)
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