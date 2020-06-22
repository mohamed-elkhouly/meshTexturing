function view_each_group_in_figure_alone(groups2,mesh,region_frames,region_faces)
for group_index=1:length(region_faces)
    all_required_faces_for_group=cell2mat(region_faces(group_index));
    aaa=zeros(length(mesh.f),1);
aaa(all_required_faces_for_group)=255;
figure,plot_CAD(mesh.f, mesh.v, '',aaa);
delete(findall(gcf,'Type','light'));
title(num2str(group_index));
end