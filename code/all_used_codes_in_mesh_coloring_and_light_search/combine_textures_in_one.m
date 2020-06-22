function [height_texture_coord_in_img,width_texture_coord_in_img,height,max_width]=combine_textures_in_one(mesh,faces_textures,faces_vertices_indices_in_textures,tex_path)
max_width=1280;
divid_val=10;
[in_array,original_faces_indexes]=sortrows(faces_vertices_indices_in_textures,4,'descend');
faces_textures=faces_textures(original_faces_indexes);
textures=faces_textures(:,1);
texture_coord_in_img=in_array(:,1);
required_margins=in_array(:,5);
required_height_o=cell2mat(in_array(:,2));
required_height=cell2mat(in_array(:,6));
in_array(length(required_height)+1:end,:)=[];
texture_coord_in_img(length(required_height)+1:end)=[];

height_texture_coord_in_img=zeros(size(texture_coord_in_img,1),3);
width_texture_coord_in_img=zeros(size(texture_coord_in_img,1),3);
faces_rect_starting_coordinates=zeros(length(required_height),2);
max_h_b=max(required_height);
max_h=1;
required_width_o=cell2mat(in_array(:,3));
required_width=cell2mat(in_array(:,7));
final_texture_array=uint8(zeros([round(sum(required_height)/divid_val) max_width 3]));
indexing_array=true(round(sum(required_height)/divid_val), max_width);
available_w_per_rows=sum(indexing_array,2);  
last_height_index=1;
last_width_index=1;
st_index_f=1;
tic
for i=1:length(in_array)
    if(i==169)
        d=[];
    end
    current_tex=cell2mat(textures(i));
    current_tex_height=required_height(i);
    current_tex_width=required_width(i);
    available_width=max_width-last_width_index+1;
    
        % set start and end indexes for placing in images.
        start_h=1;end_h=1+current_tex_height-1;
        start_w=last_width_index;end_w=last_width_index+current_tex_width-1;
        flag=0;
        if(available_width>current_tex_width)
             if(sum(sum(~indexing_array(start_h:end_h,start_w:end_w)))==0)
                 flag=1;
             end
        end
        
    if(flag~=1)   
        increasing_value_1=0;
        if(st_index_f<1)
            st_index_f=1;
        end
        while(true)
            to_be_break=false;
%      available_w_per_rows=sum(indexing_array((1:last_height_index+max_h),:),2);  
     last_height_index=find(available_w_per_rows(st_index_f:max_h)>=current_tex_width,1)+increasing_value_1+st_index_f-1;
%      increasing_value_1=increasing_value_1+sum(available_w_per_rows==available_w_per_rows(last_height_index));
increasing_value_1=increasing_value_1+5;
     available_in_w=[1,find(diff(indexing_array(last_height_index,:))>0)+1];
     for k=1:length(available_in_w)
%      last_width_index=find(indexing_array(last_height_index,:),1);
last_width_index=available_in_w(k);
     if(isempty(last_width_index))
         continue;
     end
     available_width=max_width-last_width_index+1;
      if(available_width<current_tex_width)
          continue;
      end
     start_h=last_height_index;end_h=last_height_index+current_tex_height-1;
        start_w=last_width_index;end_w=last_width_index+current_tex_width-1;
        if(sum(sum(~indexing_array(start_h:end_h,start_w:end_w)))==0)
            to_be_break=true;
            break;
        end
     end
     if(to_be_break)
         break;
     end
        end
    end
    final_texture_array(start_h:end_h,start_w:end_w,:)=current_tex;
    available_w_per_rows(start_h:end_h)=available_w_per_rows(start_h:end_h)-current_tex_width;
    st_index_f=max_h-max_h_b;
    if(st_index_f>1)
    available_w_per_rows(1:st_index_f)=0;
    end
    indexing_array(start_h:end_h,start_w:end_w)=0;
%     faces_rect_starting_coordinates(i,:)=[start_h,start_w];
    temp=cell2mat(texture_coord_in_img(i));
    temp_marg=cell2mat(required_margins(i));
    height_texture_coord_in_img(i,:)=temp(1,:)+start_h-1+temp_marg(1);
    width_texture_coord_in_img(i,:)=temp(2,:)+start_w-1+temp_marg(2);
%     height_texture_coord_in_img(i,:)={temp};
    max_h=max(end_h,max_h);
    last_width_index=end_w+1;
    d=[];
end
final_texture_array(max_h+1:end,:,:)=[];
height=size(final_texture_array,1);
imwrite(final_texture_array,[tex_path,'/result_material0000_map_Kd.png']);



f_o_height_texture_coord_in_img=zeros(size(mesh.f,1),3);
f_o_width_texture_coord_in_img=zeros(size(mesh.f,1),3);
face_have_texture=false(size(mesh.f,1),1);

f_o_height_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=1-height_texture_coord_in_img/height;
f_o_width_texture_coord_in_img(original_faces_indexes(1:size(height_texture_coord_in_img,1)),:)=width_texture_coord_in_img/max_width;
face_have_texture(original_faces_indexes(1:size(height_texture_coord_in_img,1)))=1;
% newmesh.v=zeros(size(mesh.f,1)*3,3);
% newmesh.v_n=zeros(size(mesh.f,1)*3,3);
% newmesh.f=mesh.f;
% vertices=zeros(3,1);
% indexes=zeros(3,1);
% for i=1:length(mesh.f)
%     vertices(:)=newmesh.f(i,:);
%     indexes(:)=[i*3-2,i*3-1,i*3];
%     newmesh.v(indexes(1),:)=mesh.v(vertices(1),:);
%     newmesh.v(indexes(2),:)=mesh.v(vertices(2),:);
%     newmesh.v(indexes(3),:)=mesh.v(vertices(3),:);
%     newmesh.v_n(indexes(1),:)=mesh.v_n(vertices(1),:);
%     newmesh.v_n(indexes(2),:)=mesh.v_n(vertices(2),:);
%     newmesh.v_n(indexes(3),:)=mesh.v_n(vertices(3),:);
%     newmesh.f(i,:)=indexes;
% end
% write_into_obj_file(newmesh,f_o_height_texture_coord_in_img,f_o_width_texture_coord_in_img,face_have_texture,tex_path)
write_into_obj_file(mesh,f_o_height_texture_coord_in_img,f_o_width_texture_coord_in_img,face_have_texture,tex_path)
toc
d=[];