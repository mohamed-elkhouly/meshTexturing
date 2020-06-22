function [hitted_faces_2,faces_places_in_image,back_idxx,index_f,index_in_hitted_faces_1,index_in_all_used_group_faces_1]=get_hitted_faces_in_mesh(i,using_different_mesh,folder_path,mesh,start_of_faces_indexing,end_of_faces_indexing,all_used_groups_faces)
    if(~using_different_mesh)
        file_path=[folder_path,'/frames_faces_mapping/','frame-',sprintf('%06d',i),'.color.png'];
        [faces_image,~,trans]=imread(file_path);
        mar_to_r=20;
        faces_image(1:mar_to_r,:,:)=0;
        faces_image(:,1:mar_to_r,:)=0;
        
        faces_image((end-mar_to_r+1:end),:,:)=0;
        faces_image(:,(end-mar_to_r+1):end,:)=0;
        
        
        r=faces_image(:,:,1);
        g=faces_image(:,:,2);
        b=faces_image(:,:,3);
        %         r=zeroing_borders(r,zero_border_val);g=zeroing_borders(g,zero_border_val);b=zeroing_borders(b,zero_border_val);trans=zeroing_borders(trans,zero_border_val);
        A=double([trans(:),r(:),g(:),b(:)]);
        faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
        idxx=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
    else
        idxx=mesh.frame_face_mapping(i+1,:,:);
        idxx=reshape(idxx,height,width);
        %         idxx=zeroing_borders(idxx);
        idxx=idxx(:);
    end
    
    
    
    idxx=idxx-start_of_faces_indexing;
    back_idxx=[idxx,(1:length(idxx))'];
%     back_back_idxx=[idxx,(1:length(idxx))'];
    back_idxx(idxx>end_of_faces_indexing,:)=[];
    idxx(idxx>end_of_faces_indexing)=[];
    
    back_idxx(idxx<=0,:)=[];
    idxx(idxx<=0)=[];
    [hitted_faces,~,indexes_of_faces_in_originals]=unique(idxx);
    [sorted_f,index_f]=sort(indexes_of_faces_in_originals);
    
    [~,faces_places_in_image,~]=unique(sorted_f);
    faces_places_in_image(length(hitted_faces)+1)=length(sorted_f)+1;
    
    [~,index_in_all_used_group_faces_1,index_in_hitted_faces_1]=intersect(all_used_groups_faces(:,1),hitted_faces);
%     if(isempty(index_in_all_used_group_faces_1))
%         continue;
%     end
    groups_faces=all_used_groups_faces(index_in_all_used_group_faces_1,:);
    
    
    hitted_faces_2=groups_faces(:,1);