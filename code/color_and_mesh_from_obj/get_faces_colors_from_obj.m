folder_name='marbled_bathroom_refined_0.001_d_m_full_baked';
fullfilename=[folder_name,'/',folder_name,'.obj'];
OBJ=read_wobj(fullfilename);
vertices_textures=OBJ.vertices_texture;
mesh.v=OBJ.vertices;
mesh.f=[];
mesh.tex=[];
mesh.colors=[];
objects=OBJ.objects;
flag=false;
save('after_reading.mat')
load('after_reading.mat')
for i=1:length(objects)
    type=objects(i).type;
    data=objects(i).data;        
            if(type=='usemtl')
                if(data(end-3:end)=="dahy")
%                     if(length(data)==length('Bathtub_dahy'))
%                         if(data=='Bathtub_dahy')
%                             d=[];
%                         end
%                     end
                    current_object_image=[folder_name,'/',data,'.png'];
                    texture_image=imread(current_object_image);
                    [img_height,img_width,~]=size(texture_image);
                    red=texture_image(:,:,1);
                    green=texture_image(:,:,2);
                    blue=texture_image(:,:,3);
                    flag=true;
                end
            elseif(type=='f'&&flag==true)
                current_object_faces=data.vertices;
                current_object_textures=data.texture;
                mesh.f=[mesh.f;current_object_faces];
                mesh.tex=[mesh.tex;current_object_textures];
                faces_colors=current_object_faces;
                for j=1:size(current_object_textures,1)
                    current_face_texture=current_object_textures(j,:);
                    current_face_tex_coord=vertices_textures(current_face_texture,:);
                   current_face_tex_coord= round(current_face_tex_coord.*[ img_width img_height]);
                   indh=img_height-current_face_tex_coord(:,2);
                   indw=current_face_tex_coord(:,1);
                    [~,~,height_inds,width_inds]=get_face_indexes((indh-min(indh)+1),(indw-min(indw)+1));
                    height_inds=height_inds+min(indh)-1;
                    width_inds=width_inds+min(indw)-1;
                    % the next two lines could cause noise in case that the
                    % face has no texture (0) i saw some cases
                    height_inds(height_inds>img_height)=img_height;height_inds(height_inds<1)=1;
                    width_inds(width_inds>img_width)=img_width;width_inds(width_inds<1)=1;
                    
%                     try
                    face_indices_in_2d_image=sub2ind([img_height img_width],height_inds,width_inds);
%                     catch
%                         d=[];
%                     end
                    faces_colors(j,:)=[sum(red(face_indices_in_2d_image)), sum(green(face_indices_in_2d_image)), sum(blue(face_indices_in_2d_image))]/length(face_indices_in_2d_image);
                end
                mesh.colors=[mesh.colors;faces_colors];
                flag=false;
            end
        
    
    
end

figure,plot_CAD(mesh.f, mesh.v, '',uint8(mesh.colors))
delete(findall(gcf,'Type','light'));
plywrite(['scene.ply'],mesh.f,mesh.v);
d=[];