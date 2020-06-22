function luminance3=do_balance_operation(mesh,all_faces_in_correspondences,estimated_g,luminance,region_faces_backup)
face_appeared_flag=false(size(mesh.f,1),1);
face_appeared_flag(all_faces_in_correspondences)=1;
luminance3=luminance;
for i=1:length(region_faces_backup)
    current_group_faces=cell2mat(region_faces_backup(i));
    faces_appeared=current_group_faces(face_appeared_flag(current_group_faces));
    unappeared_faces=current_group_faces(~face_appeared_flag(current_group_faces));
    estimated_g_of_appeared_faces=estimated_g(faces_appeared);
    new_luminance_of_faces=double(luminance(faces_appeared))+estimated_g_of_appeared_faces;
    ratio=new_luminance_of_faces./double(luminance(faces_appeared));
    ratio(ratio==inf)=[];
    ratio(ratio==-inf)=[];
        avg_ratio=trimmean(ratio,30);
    luminance3(unappeared_faces)=round(double(luminance(unappeared_faces)).*avg_ratio);
    luminance3(faces_appeared)=double(luminance(faces_appeared)).*avg_ratio;
    
%     ag=false(size(mesh.f,1),1);
% ag(current_group_faces)=1;
% g=zeros(size(mesh.f,1),1);
% g(ag)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',g);
% delete(findall(gcf,'Type','light'));
end