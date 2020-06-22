function array=append_to_array_using_xy(array,x_indexes,y_indexes,values)
% x_indexes=[1,2];
% y_indexes=[1,2];
% values=[9;9];
% array=[0 ;5;0];
if(length(values)==1)
    values=ones([length(x_indexes) 1])*values;
end
[height,W,~]=size(array);
if(W==1)
 for i=1:length(x_indexes)
     array(x_indexes(i),y_indexes(i))=values(i);
 end
else
width=max(y_indexes);
if(W<width)
    array=[array,zeros([height 1])];
end
indexes=sub2ind([height width],x_indexes(:),y_indexes(:));
array(indexes)=values;
end
d=[];
