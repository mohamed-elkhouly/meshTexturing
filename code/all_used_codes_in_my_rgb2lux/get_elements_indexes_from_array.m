function required_indexes=get_elements_indexes_from_array(search_array,required_elements)
% required_indexes=[];
% required_indexes=(search_array==required_elements(:));
% required_indexes=sum(required_indexes);
% required_indexes=find(required_indexes);
% d=[];
% for i=1:length(required_elements)
%     current_inds=find(search_array==required_elements(i));
%     required_indexes=[required_indexes;current_inds(:)];
% end
array_control_var=1000;
last_indexes=zeros([1 length(search_array)]);
required_elements=required_elements(:);
if length(required_elements)>array_control_var
iterations=ceil(length(required_elements)/array_control_var);


if (iterations~=1)
    for i=1:iterations-1
        current_indexes=(search_array==required_elements((i-1)*array_control_var+1:i*array_control_var));
        temp=sum(current_indexes);
        last_indexes=sum([temp;last_indexes]);
    end
else
    i=1;
end
current_indexes=(search_array==required_elements((i)*array_control_var+1:end));
temp=sum(current_indexes);
last_indexes=sum([temp;last_indexes]);
else
    current_indexes=(search_array==required_elements(:));
temp=sum(current_indexes,1);
last_indexes=sum([temp;last_indexes],1);
end
required_indexes=find(last_indexes);
d=[];