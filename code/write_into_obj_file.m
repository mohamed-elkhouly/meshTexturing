function write_into_obj_file(mesh,f_o_height_texture_coord_in_img,f_o_width_texture_coord_in_img,face_have_texture,tex_path)
% here we will prepare our faces and vertices then send it to write_wobj(OBJ,fullfilename)
faces=mesh.f;
vertices=mesh.v;
try
vertices_normals=mesh.v_n;
catch
    vertices_normals=[];
    print="the vertex normals are not existed"
end
clear mesh;

objfile_name=[tex_path,'/result.obj'];
fid = fopen(objfile_name,'w');
fprintf(fid,'mtllib result.mtl\n');
for i=1:size(vertices,1)
    %     sprintf('v %5.5f %5.5f %5.5f\n', vertices(i,1), vertices(i,2), vertices(i,3));
    fprintf(fid,'v %5.5f %5.5f %5.5f\n', vertices(i,1), vertices(i,2), vertices(i,3));
end
for i=1:size(vertices_normals,1)
    %     sprintf('v %5.5f %5.5f %5.5f\n', vertices(i,1), vertices(i,2), vertices(i,3));
    fprintf(fid,'vn %5.5f %5.5f %5.5f\n', vertices_normals(i,1), vertices_normals(i,2), vertices_normals(i,3));
end
indexes_of_textures=zeros(size(f_o_height_texture_coord_in_img,1),3);
ind=1;
for i=1:size(f_o_height_texture_coord_in_img,1)
%          14596       14597       14598
    if(ind==14596)
        d=[];
    end
    if(face_have_texture(i))
        indexes_of_textures(i,:)=[ind,ind+1,ind+2];
        ind=ind+3;
%     fprintf(fid,'vt %5.6f %5.6f\n', f_o_height_texture_coord_in_img(i,1), f_o_width_texture_coord_in_img(i,1));
%     fprintf(fid,'vt %5.6f %5.6f\n', f_o_height_texture_coord_in_img(i,2), f_o_width_texture_coord_in_img(i,2));
%     fprintf(fid,'vt %5.6f %5.6f\n', f_o_height_texture_coord_in_img(i,3), f_o_width_texture_coord_in_img(i,3));
    
    fprintf(fid,'vt %5.7f %5.7f\n', f_o_width_texture_coord_in_img(i,1),f_o_height_texture_coord_in_img(i,1));
    fprintf(fid,'vt %5.7f %5.7f\n', f_o_width_texture_coord_in_img(i,2), f_o_height_texture_coord_in_img(i,2));
    fprintf(fid,'vt %5.7f %5.7f\n', f_o_width_texture_coord_in_img(i,3), f_o_height_texture_coord_in_img(i,3));
    end
end
fprintf(fid,'usemtl material0000\n');
for j=1:size(faces,1)
    if(j==98833)
        d=[];
    end
    if(face_have_texture(j))
        texture_indexes=indexes_of_textures(j,:);
    else
        texture_indexes=[0 0 0];
    end
    fprintf(fid,'f %d/%d/%d',faces(j,1),texture_indexes(1),faces(j,1));
    fprintf(fid,' %d/%d/%d', faces(j,2),texture_indexes(2),faces(j,2));
    fprintf(fid,' %d/%d/%d\n', faces(j,3),texture_indexes(3),faces(j,3));
end
fclose(fid);
mtlfile_name=[tex_path,'/result.mtl'];
fid = fopen(mtlfile_name,'w');
 fprintf(fid,'newmtl material0000\nKa 1.000000 1.000000 1.000000\nKd 1.000000 1.000000 1.000000\nKs 0.000000 0.000000 0.000000\nTr 1.00000\nillum 1\nNs 1.000000\nmap_Kd result_material0000_map_Kd.png');
fclose(fid);