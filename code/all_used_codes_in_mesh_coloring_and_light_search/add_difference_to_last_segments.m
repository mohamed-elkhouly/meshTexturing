function image=add_difference_to_last_segments(image)
% image=uint8([1 0 3 ; 0 0 0;0 0 0; 2 3 4;0 0 0; 0 0 0;5 6 7; 0 0 0;0 0 0  ]);
difference=diff(image);
difference2=diff(double(image));
difference2(difference2>0)=0;
for i=1:size(image,2)
    current_difference_column=difference(:,i);
    current_difference_column_filled=fill_zeros_with_next_value(current_difference_column);
    image(:,i)=[image(:,i)+[current_difference_column_filled;0]];
end
% image=uint8([difference2;zeros([1, size(difference2,2)])]+double(image));
d=[];


function  column=fill_zeros_with_next_value(column)
thr1=50;
column=flipud(column);
current_val_to_add=column(column>0);
current_val_to_add=current_val_to_add(1);
% last_small_value=0;
for i=1:length(column)
    if(column(i)==0 || (current_val_to_add-column(i))<thr1)
        column(i)=current_val_to_add;
    else
        current_val_to_add=column(i);
    end
end
column=flipud(column);
d=[];