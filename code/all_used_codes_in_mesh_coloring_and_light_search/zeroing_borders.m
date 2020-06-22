function img=zeroing_borders(img,val)
img(1:val,:)=0;
img(:,1:val)=0;
img(end-val+1:end,:)=0;
img(:,end-val+1:end)=0;
