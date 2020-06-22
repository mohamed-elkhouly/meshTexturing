function [new_v, new_f] = subdivideFaces(f, v, div)
    
    areas = meshArea(f,v);
    big_f_idx = areas > 80000;
    big_f = f(big_f_idx,:);
    small_f = f(~big_f_idx,:);
    
    [new_v, new_f] = subdivideMesh(v, big_f, div);
    new_f = [small_f; new_f];
end