function [textures_images_and_faces]=create_A_omega_F_matrices(vertices_on_border_info,mesh,border_vertices_coord,G_vertices,textures_images_and_faces)
num_vertices=size(mesh.v,1);
% here we want to 1) find the common vertices between textures, 2) based on
% the common vertices, we will get the F matrix which contain the
% difference between the colors of the vertices in different textures 3) we
% will also fill the A and omega matrices with +/-1 to be used in
% optimization later.
all_vertices_groups=cell(size(vertices_on_border_info,1),1);
for i=1:size(vertices_on_border_info,1)
    current_vertices_groups=prepare_vertices_groups(cell2mat(vertices_on_border_info(i,3)));
    all_vertices_groups(i)={[current_vertices_groups,false(size(current_vertices_groups,1),1)]};
    all_textures_colores(i,1)=vertices_on_border_info(i,2);
end
%     current_vertices_groups=prepare_vertices_groups(cell2mat(vertices_on_border_info(i,3)));
index=1;
row_A=1;
A_mat=[];
gamma_mat=[];
A_mat_index=1;
for_correcting=[];
vertices_views_mat=zeros(num_vertices,size(vertices_on_border_info,1));
for i=1:size(vertices_on_border_info,1)
    current_vertices=cell2mat(vertices_on_border_info(i,1));
    current_colores=cell2mat(vertices_on_border_info(i,2));
    current_vertices_groups=cell2mat(all_vertices_groups(i));
    %     current_vertices_groups=prepare_vertices_groups(cell2mat(vertices_on_border_info(i,3)));
    for j=1:size(vertices_on_border_info,1)
        % to skip overlapping with self
        if(i==j)
            continue;
        end
        % to skip overlapping between same pairs again (keep only upper triangle)
        if(i>j)
            continue;
        end
        other_vertices=cell2mat(vertices_on_border_info(j,1));
        other_colores=cell2mat(vertices_on_border_info(j,2));
        other_vertices_groups=cell2mat(all_vertices_groups(j));
        %         other_vertices_groups=prepare_vertices_groups(cell2mat(vertices_on_border_info(j,3)));
        [common_vertices,ind_L,ind_R]=intersect(current_vertices,other_vertices);
        
        for k=1:length(common_vertices)
            current_vertices_groups(ind_L(k),2)=1;
            other_vertices_groups(ind_R(k),2)=1;
            F_mat(row_A,:)=current_colores(ind_L(k),:)-other_colores(ind_R(k),:);
            col_A=vertices_views_mat(common_vertices(k),i);
            if(col_A==0)
                vertices_views_mat(common_vertices(k),i)=index;
                col_A=index;
                index=index+1;
            end
            A_mat(A_mat_index,:)=[row_A,col_A,1];
            A_mat_index=A_mat_index+1;
            
            col_A2=vertices_views_mat(common_vertices(k),j);
            if(col_A2==0)
                vertices_views_mat(common_vertices(k),i)=index;
                col_A2=index;
                index=index+1;
            end
            A_mat(A_mat_index,:)=[row_A,col_A2,-1];
            A_mat_index=A_mat_index+1;
            
            
            for_correcting(row_A,:)=[i,j,ind_L(k),ind_R(k),col_A,col_A2];
            row_A=row_A+1;
        end
        
        all_vertices_groups(j)={other_vertices_groups};
    end
    
    all_vertices_groups(i)={current_vertices_groups};
end

gamma_mat_index=1;
row_gamma=1;
for i=1:size(vertices_on_border_info,1)
    current_vertices_groups=cell2mat(all_vertices_groups(i));
    current_vertices_groups=current_vertices_groups(:,2);
    current_vertices=cell2mat(vertices_on_border_info(i,1));
    current_vertices=current_vertices(current_vertices_groups>0);
    current_vertices_positions=mesh.v(current_vertices,:);
    for m=1:size(current_vertices_positions,1)
        curr_vert=current_vertices_positions(m,:);
        other_verts=vecnorm([current_vertices_positions-curr_vert]');
        other_verts(m)=inf;
        [~,adj_ind]=min(other_verts);
        col1=vertices_views_mat(current_vertices(m),i);
        col2=vertices_views_mat(current_vertices(adj_ind),i);
        if(col1==0||col2==0)
            continue;
        end
        gamma_mat(gamma_mat_index,:)=[row_gamma,col1,0.1];
        gamma_mat_index=gamma_mat_index+1;
        gamma_mat(gamma_mat_index,:)=[row_gamma,col2,-0.1];
        gamma_mat_index=gamma_mat_index+1;
        
        row_gamma=row_gamma+1;
    end
    
end
A=[];
Gamma=[];
F_mat;
max_col_A=max(A_mat(:,2));
row_A=row_A-1;
A=zeros(row_A,max_col_A);
A_mat_indices=sub2ind([row_A max_col_A],A_mat(:,1),A_mat(:,2));
A(A_mat_indices)=A_mat(:,3);

max_col_gamma=max_col_A;
row_gamma=row_gamma-1;
Gamma=zeros(row_gamma,max_col_gamma);
gamma_mat_indices=sub2ind([row_gamma max_col_gamma],gamma_mat(:,1),gamma_mat(:,2));
Gamma(gamma_mat_indices)=gamma_mat(:,3);
for i=1:3
    F=double(F_mat(:,i));
    LHS=A'*A+Gamma'*Gamma;
    RHS=A'*F;
        tic;estimated_g(:,i) = -1*conjgrad(LHS,RHS);toc
% tic;estimated_g(:,i) = linsolve(LHS,RHS);toc
% tic;estimated_g(:,i) =1*lsqminnorm(LHS,RHS);
estimated_g(:,i)=estimated_g(:,i)-mean(estimated_g(:,i));
end

for i=1:size(all_textures_colores,1)
    current_texture_colors=cell2mat(vertices_on_border_info(i,2));
    current_text_vertices_coordinates=cell2mat(border_vertices_coord(i));
    vertices_from_current_texture_to_add=for_correcting(:,1)==i;
    g_columns_L=for_correcting(:,5);
    g_columns_L=g_columns_L(vertices_from_current_texture_to_add);
    verts_ind_in_current_texture_L=for_correcting(vertices_from_current_texture_to_add,3);
    
    
    vertices_from_current_texture_to_sub=for_correcting(:,2)==i;
    g_columns_R=for_correcting(:,6);
    g_columns_R=g_columns_R(vertices_from_current_texture_to_sub);
    verts_ind_in_current_texture_R=for_correcting(vertices_from_current_texture_to_sub,4);
    
    % next four lines is to avoid values >255 or lower than 0 after adding
    % g
    temp_result_colors=uint8(double(current_texture_colors(verts_ind_in_current_texture_L,:))+estimated_g(g_columns_L,:));
    estimated_g(g_columns_L,:)=double(temp_result_colors)-double(current_texture_colors(verts_ind_in_current_texture_L,:));
    
    temp_result_colors=uint8(double(current_texture_colors(verts_ind_in_current_texture_R,:))-estimated_g(g_columns_R,:));
    estimated_g(g_columns_R,:)=-1*(double(current_texture_colors(verts_ind_in_current_texture_R,:))-double(temp_result_colors));% this -1 because I will add it in correction, so it will be ready as subtraction
    
    %%%%---------------------------------------------------------------------
    
    
    temp_flag=false(size(current_text_vertices_coordinates,1),1);
    
    X_L=current_text_vertices_coordinates(verts_ind_in_current_texture_L,1);
    Y_L=current_text_vertices_coordinates(verts_ind_in_current_texture_L,2);
    
    X_R=current_text_vertices_coordinates(verts_ind_in_current_texture_R,1);
    Y_R=current_text_vertices_coordinates(verts_ind_in_current_texture_R,2);
    
    X=[X_L;X_R];
    Y=[Y_L;Y_R];
    
    temp_flag(verts_ind_in_current_texture_L)=1;
    temp_flag(verts_ind_in_current_texture_R)=1;
    Xq=current_text_vertices_coordinates(~temp_flag,1);
    Yq=current_text_vertices_coordinates(~temp_flag,2);
    
    
    Vq=[];
    V=[];
    if(length(X)>5&&length(Xq)>2)
        for k=1:3
            V_L=estimated_g(g_columns_L,k);
            V_R=estimated_g(g_columns_R,k);
            V(:,k)=[V_L;V_R];
            F = scatteredInterpolant(X,Y,V(:,k),'natural');
            Vq(:,k) = F(Xq,Yq);
        end
        current_texture_colors(verts_ind_in_current_texture_L,:)=uint8(double(current_texture_colors(verts_ind_in_current_texture_L,:))+estimated_g(g_columns_L,:));
        current_texture_colors(~temp_flag,:)=uint8(double(current_texture_colors(~temp_flag,:))+Vq);
        Vq=double(double(current_texture_colors(~temp_flag,:))-double(current_texture_colors(~temp_flag,:)));
        vertices_on_border_info(i,2)={uint8(current_texture_colors)};
        
%         sum(current_texture_colors(:)<0)
%         sum(current_texture_colors(:)>255)
        X=[X;Xq];
        Y=[Y;Yq];
        V=[V;Vq];
        
        full_text_coordinates=cell2mat(G_vertices(i,1));
        Xq=full_text_coordinates(:,1);
        Yq=full_text_coordinates(:,2);
        Vq=[];
        for k=1:3
            F = scatteredInterpolant(X,Y,V(:,k),'natural');
            Vq(:,k) = F(Xq,Yq);
        end
        min_r=cell2mat(G_vertices(i,2));
        min_c=cell2mat(G_vertices(i,3));
        Xq=Xq-min_r+1;
        Yq=Yq-min_c+1;
        current_texture_image=cell2mat(textures_images_and_faces(i,1));
        [w,h,~]=size(current_texture_image);
        image_indexes=sub2ind([w,h],Xq,Yq);
        
        red=current_texture_image(:,:,1);
        green=current_texture_image(:,:,2);
        blue=current_texture_image(:,:,3);
        
        red(image_indexes)=uint8(double(red(image_indexes))+Vq(:,1));
        green(image_indexes)=uint8(double(green(image_indexes))+Vq(:,2));
        blue(image_indexes)=uint8(double(blue(image_indexes))+Vq(:,3));
        current_texture_image_new=uint8([]);
        current_texture_image_new(:,:,1)=red;
        current_texture_image_new(:,:,2)=green;
        current_texture_image_new(:,:,3)=blue;
        
%         figure;subplot(1,2,2);imshow(current_texture_image_new);subplot(1,2,1);imshow(current_texture_image)
        
        textures_images_and_faces(i,1)={current_texture_image_new};
    end
    
    
    
    
    
    
    % the next one is just correction for the border colors, we will
    % interpolate estimated_g to correct all of the texture colors
    %     current_texture_colors(verts_ind_in_current_texture,:)=current_texture_colors(verts_ind_in_current_texture,:)+estimated_g(g_columns_L,:);
    %     sum(sum(current_texture_colors<0))
    %     sum(sum(current_texture_colors>255))
end

d=[];