function view_model_from_all_frames_as_separate_frames(groups2,mesh,region_frames,region_faces)
region_frames=region_frames+1;
for kk=1:size(region_frames,1)
%     kk=67;
    all_faces_numbers=[];
all_faces_values=zeros(length(mesh.f),size(region_frames,1)+1)-1;
all_faces_values_a=zeros(length(mesh.f),size(region_frames,1)+1)-1;
all_faces_values_b=zeros(length(mesh.f),size(region_frames,1)+1)-1;

new_colors=[];
    
    
frame_num=region_frames(kk,1);%32,469,648,664,665
group_index=4;
for group_index=1:length(region_faces)
    
    current_faces=groups2(group_index).frame(frame_num).faces;
    flag=0;
    if(~isempty(current_faces))
        if(group_index==7)
        d=[];
        end
    flag=1;
    indexes_of_column_from_big_array=all_faces_values(current_faces,1)+3;
            indexes_of_elements_in_big_array=sub2ind(size(all_faces_values),current_faces,indexes_of_column_from_big_array);
    all_faces_values(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values;
    all_faces_values_a(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_a;
    all_faces_values_b(indexes_of_elements_in_big_array)=groups2(group_index).frame(frame_num).values_b;
    all_faces_values(current_faces,1)=all_faces_values(current_faces,1)+1;
    end

end

new_colors=zeros(length(mesh.f),1);
new_colors_a=zeros(length(mesh.f),1);
new_colors_b=zeros(length(mesh.f),1);
for kk2=1:length(mesh.f)
    temp=all_faces_values(kk2,2:end);
    temp(temp==-1)=[];
    if(~isempty(temp))
    new_colors(kk2)=mean(temp);
     temp=all_faces_values_a(kk2,2:end);
    temp(temp==-1)=[];
new_colors_a(kk2)=mean(temp);
 temp=all_faces_values_b(kk2,2:end);
    temp(temp==-1)=[];
new_colors_b(kk2)=mean(temp);
    end
end
new_c(:,:,1)=new_colors;
new_c(:,:,2)=new_colors_a;
new_c(:,:,3)=new_colors_b;
% new_c=lab2rgb(new_c);
% new_colors=[new_colors,new_colors_a,new_colors_b];
% final_colors=uint8(new_colors);
aaa=zeros(length(mesh.f),3);
aaa(:,1)=new_c(:,:,1);
aaa(:,2)=new_c(:,:,2);
aaa(:,3)=new_c(:,:,3);
% if(flag==1)
figure,plot_CAD(mesh.f, mesh.v, '',uint8(aaa));
delete(findall(gcf,'Type','light'));
title(num2str(frame_num))
% end
end

% figure,plot_CAD(mesh.f, mesh.v, '',uint8(new_colors));

d=[];


