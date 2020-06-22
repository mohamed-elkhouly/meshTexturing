function calc_func()
global   row_vec;
global   col_vec;
global   val_vec;
for i=1:length(row_vec)
    bin_r=row_vec==row_vec(i);
    bin_c=col_vec==col_vec(i);
    if(sum(bin_r&bin_c)>1)
        indexes=find(bin_r);
    end
end