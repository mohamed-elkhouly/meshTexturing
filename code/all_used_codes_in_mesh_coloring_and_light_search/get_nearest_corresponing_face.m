function min_ind=get_nearest_corresponing_face(c1,c2)

div_val=1;
%     tic
while(1)
    try
        [~,min_ind]=min(sqrt((c1(:,1)-c2(1:ceil(size(c2,1)/div_val),1)').^2+(c1(:,2)-c2(1:ceil(size(c2,1)/div_val),2)').^2+(c1(:,3)-c2(1:ceil(size(c2,1)/div_val),3)').^2));
        %             [min_diff_c1,min_ind]=min(abs(c1(:,1)-c2(1:ceil(size(c2,1)/div_val),1)'));
        break;
    catch
        div_val=div_val*2;
    end
end
if (div_val>1)
    div_val=div_val+4;
    min_ind(size(c2,1))=0;
    for k=2:div_val-1
        start_ind=(k-1)*(ceil(size(c2,1)/div_val))+1;
        end_ind=k*(ceil(size(c2,1)/div_val));
        [~,min_ind(start_ind:end_ind)]=min(sqrt((c1(:,1)-c2(start_ind:end_ind,1)').^2+(c1(:,2)-c2(start_ind:end_ind,2)').^2+(c1(:,3)-c2(start_ind:end_ind,3)').^2));
    end
    if(div_val>1)
        k=div_val;
        start_ind=(k-1)*(ceil(size(c2,1)/div_val))+1;
        [~,min_ind(start_ind:end)]=min(sqrt((c1(:,1)-c2(start_ind:end,1)').^2+(c1(:,2)-c2(start_ind:end,2)').^2+(c1(:,3)-c2(start_ind:end,3)').^2));
    end
end