function get_difference_between_baked_and_waechter(mesh)

average_face_colors_mat=[mesh.data_path,mesh.scene_name,'_waechter_colors_per_face.mat'];
baked_face_colors_mat=[mesh.data_path,mesh.scene_name,'_baked_colors_per_face.mat'];
mkdir([mesh.data_path,'baked_images']);
mkdir([mesh.data_path,'waechter_images']);
mkdir([mesh.data_path,'Wdifference_images']);
load(average_face_colors_mat)
load(baked_face_colors_mat)

final_average_colors=double(waechter_colors);
mesh_baked_colors=mesh_baked_colors;
R_baked=mesh_baked_colors(:,1);
G_baked=mesh_baked_colors(:,2);
B_baked=mesh_baked_colors(:,3);

R_average=final_average_colors(:,1);
G_average=final_average_colors(:,2);
B_average=final_average_colors(:,3);
final_difference=abs(mesh_baked_colors-final_average_colors);
final_difference(~(mesh.all_visible_faces))=0;
final_difference_average=sum(final_difference,2);
baked_image=[];
average_image=[];
final_difference_average(final_difference_average>300)=0;
figure;
for i =1:size(mesh.frame_face_mapping,1)
    frame_face_image=squeeze(mesh.frame_face_mapping(i,:,:));
    zero_indices=frame_face_image==0;
    frame_face_image(zero_indices)=1;
    baked_image_R=R_baked(frame_face_image);
    baked_image_G=G_baked(frame_face_image);
    baked_image_B=B_baked(frame_face_image);
    baked_image_R(zero_indices)=0;
    baked_image_G(zero_indices)=0;
    baked_image_B(zero_indices)=0;
    baked_image(:,:,1)=baked_image_R;
    baked_image(:,:,2)=baked_image_G;
    baked_image(:,:,3)=baked_image_B;
%     imwrite(uint8(baked_image),[mesh.data_path,'baked_images','/',num2str(i),'.jpg']);
    avg_image_R=R_average(frame_face_image);
    avg_image_G=G_average(frame_face_image);
    avg_image_B=B_average(frame_face_image);
     avg_image_R(zero_indices)=0;
    avg_image_G(zero_indices)=0;
    avg_image_B(zero_indices)=0;
    average_image(:,:,1)=avg_image_R;
    average_image(:,:,2)=avg_image_G;
    average_image(:,:,3)=avg_image_B;
    imwrite(uint8(average_image),[mesh.data_path,'waechter_images','/',num2str(i),'.jpg']);
    diff_image=final_difference_average(frame_face_image);
    diff_image(zero_indices)=0;
    imagesc(diff_image)
    axis equal off
    colormap jet
    colorbar
    saveas(gcf,[mesh.data_path,'Wdifference_images','/',num2str(i),'.jpg'])
end
% figure,plot_CAD(mesh.f, mesh.v, '',final_difference_average)
% delete(findall(gcf,'Type','light'));