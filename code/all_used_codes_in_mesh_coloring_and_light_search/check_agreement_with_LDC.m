function difference=check_agreement_with_LDC(F_ldc,new_faces_luminance)
tic
parfor i=1:size(F_ldc,1)
    
    available_indexes=find(F_ldc(i,:)>0);
    available_indexes(new_faces_luminance(available_indexes)==0)=[];
    if(~isempty(available_indexes))
    current_row_values=F_ldc(i,available_indexes);
    sum_current_row=sum(current_row_values);
    current_row_values_new=full(current_row_values*(1/sum_current_row));% re-make their sum up to 1 again to compare with our normalized luminance.
    corresponding_luminance=double(new_faces_luminance(available_indexes));
    sum_corresponding_luminance=sum(corresponding_luminance);
    corresponding_luminance=corresponding_luminance*(1/sum_corresponding_luminance);
  difference(i)=sum( abs( current_row_values_new'-corresponding_luminance))*1/length(available_indexes);
    else
        difference(i)=2;% set the max possible difference
    end
end
toc