function mesh=fill_missing_mesh_using_planes_fitting(mesh,folder_path,scene_name,region_number,view_after_fill,dividing_distance,max_face_area,intersect_thrsh,angle_thrsh,intersect_thrsh2)
% max_face_area=0.01;
% intersect_thrsh=0.2;% this was ratio intersection,to decide to merge regions or no
% angle_thrsh=0.3;% this is the threshold of angle between the planes normal, to decide to merge regions or no
% dividing_distance=0.35;% this is the distance used to divide the axes (x or y or z) to parts to fit plane to each.
% intersect_thrsh2=0.5;
height=1024;
width=1280;

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end
if region_number==length(faces_count_per_regions)
    end_of_faces_indexing=faces_count_per_regions(region_number)+size(mesh.f,1);
else
    end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;
end
se = strel('disk',3);
% vertices_tracking_in_holes_array=zeros([length(mesh.v) 1]);
holes_counter=0;
% y_coordinate_tracker=zeros([length(mesh.v) 1]);
holes_vertices=zeros([1000,1000]);
for k=1:length(mesh.campos)
    frame_number= sprintf( '%06d', k-1) ;
    file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
    [faces_image,~,trans]=imread(file_path);
    r=faces_image(:,:,1);
    g=faces_image(:,:,2);
    b=faces_image(:,:,3);
    A=double([trans(:),r(:),g(:),b(:)]);
    faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
    empty_mask=zeros([length(faces_numbers),1]);
    empty_mask(faces_numbers>4294967294)=255;
    faces_numbers=faces_numbers+1;
    faces_numbers(faces_numbers>(end_of_faces_indexing-1))=-1;
    faces_numbers=faces_numbers-start_of_faces_indexing;
    empty_mask=reshape(empty_mask,[height width])>0;
    
    [Labels,Num_holes]=bwlabel(empty_mask);
    
    for i=1:Num_holes
        new_empty_mask=empty_mask;
        new_empty_mask(:,:)=0;
        new_empty_mask(Labels==i)=1;
        dilated_mask=imdilate(new_empty_mask,se);
        difference_image=dilated_mask-new_empty_mask;
        %             figure;imshow((diff));
        difference_image=difference_image(:);
        boundary_faces = unique(faces_numbers(difference_image>0));
        boundary_faces=boundary_faces(boundary_faces>0);
        
        if(~isempty(boundary_faces))
           
            boundary_vertices=mesh.f(boundary_faces(:),:);
            boundary_vertices=boundary_vertices(:);
            coords_of_vertices_of_neighborhood_faces=mesh.v(boundary_vertices,:);
            %%
            [distances_to_cam,sort_indexes]=sort(vecnorm((mesh.v(boundary_vertices,:)-mesh.campos(k,:))'));
            diff_distances_to_cam=diff(distances_to_cam);
            %%
            temp_x_coords=boundary_vertices;
            [a,b]=max(diff_distances_to_cam);
            if (a<0.1)
                d=[];
            else
                req_index=1;
                while (a>0.1)
                    req_index=req_index+b;
                    [a,b]=max(diff_distances_to_cam(req_index:end));
                end
                coords_of_vertices_of_neighborhood_faces=coords_of_vertices_of_neighborhood_faces(sort_indexes(req_index:end),:);
                temp_x_coords=boundary_vertices(sort_indexes(req_index:end));
                
            end
            holes_counter=holes_counter+1;
%              average_face_area(holes_counter)=(max(mesh.areas(boundary_faces(:)))+min(mesh.areas(boundary_faces(:))))/2;
            holes_vertices(holes_counter,1:length(temp_x_coords))=temp_x_coords;
            d=[];
            
        end
    end
end
holes_vertices((holes_counter+1):end,:)=[];
temp_indexes = ones(size(holes_vertices,1));
temp_indexes = triu(temp_indexes);
intersections=zeros(size(holes_vertices,1));
intersections1=zeros(size(holes_vertices,1));% this matrix to represent how much percent of intersection happened between this object and another
intersections2=zeros(size(holes_vertices,1));
angle_between_normals=zeros(size(holes_vertices,1));
normals=zeros([size(holes_vertices,1),3]);
for ind=1:size(holes_vertices,1)
    reg_points=holes_vertices(ind,:);
    reg_points(reg_points==0)=[];
    [~,normals(ind,:),~]=fit_3d_plane_to_points(mesh.v(reg_points(:),:),0);
end
for row_ind=1:size(holes_vertices,1)
    normal1=normals(row_ind,:);
    for col_ind=1:size(holes_vertices,1)
        if(row_ind==col_ind)
            continue;
        end
        if(temp_indexes(row_ind,col_ind))
            reg1=holes_vertices(row_ind,:);
            reg2=holes_vertices(col_ind,:);
            intersections(row_ind,col_ind)= length( intersect(reg1,reg2,'stable'));
            intersections1(row_ind,col_ind)=intersections(row_ind,col_ind)/length(reg1);
            intersections2(row_ind,col_ind)=intersections(row_ind,col_ind)/length(reg2);
            normal2=normals(col_ind,:);
            ang1=vrrotvec(normal1,normal2);
            angle_between_normals(row_ind,col_ind)=min(ang1(4),(3.14-ang1(4)));
        end
    end
end
intersections1(intersections==1)=0;
intersections2(intersections==1)=0;
angle_between_normals(intersections==1)=0;
intersections(intersections==1)=0;
intersections=triu(intersections)+triu(intersections,1)';
intersections1=triu(intersections1)+triu(intersections1,1)';
intersections2=triu(intersections2)+triu(intersections2,1)';
angle_between_normals=triu(angle_between_normals)+triu(angle_between_normals,1)';
all_holes=1:size(holes_vertices,1);
index=1;
% intersections_threshold=100;% this was num vertices

final_list=[];
% average_face_area;
while ~isempty(all_holes)
    current_hole=all_holes(1);
    exclutions=current_hole;
    %     intersected_holes=find(intersections(all_holes(1),:)>intersections_threshold);
    intersected_holes1=find(intersections1(all_holes(1),:)>intersect_thrsh);
    intersected_holes2=find(intersections2(all_holes(1),:)>intersect_thrsh);
    intersected_holes=intersect(intersected_holes1,intersected_holes2,'stable');
    intersected_holes=unique([intersected_holes,find(intersections1(all_holes(1),:)>intersect_thrsh2),find(intersections2(all_holes(1),:)>intersect_thrsh2)]);
    current_angles=angle_between_normals(all_holes(1),intersected_holes);
    intersected_holes=intersected_holes(current_angles<angle_thrsh);
    while(~isempty(intersected_holes))
        exclutions=[exclutions;intersected_holes(:)];
        intersected_holes=find_related2(intersected_holes,intersections,intersections1,intersections2,exclutions,intersect_thrsh,angle_between_normals,angle_thrsh,intersect_thrsh2);
    end
    for exclutions_index=1:length(exclutions)
        all_holes(all_holes==exclutions(exclutions_index))=[];
    end
    final_list(index,1:length(exclutions))=exclutions;
    index=index+1;
end
for new_holes_index=1:size(final_list,1)
    current_holes=final_list(new_holes_index,:);
    current_holes(current_holes==0)=[];
    current_holes=current_holes(:);
%     final_max_faces_area=mean(average_face_area(new_holes_index));
    current_vertices=holes_vertices(current_holes,:);
    current_vertices=current_vertices(:);
    current_vertices(current_vertices==0)=[];
    coords_of_vertices_of_neighborhood_faces=mesh.v(current_vertices,:);
    [refined_faces,temp_final_vertices] =fit_points_into_plans(coords_of_vertices_of_neighborhood_faces,dividing_distance,max_face_area,0);
    mesh.f=[mesh.f;(refined_faces+length(mesh.v))];
    mesh.v=[mesh.v;temp_final_vertices];
end
if (view_after_fill)
    figure;
    plot_CAD(mesh.f, mesh.v, '',[zeros([size(mesh.f_c,1) 1]); 200*ones([(size(mesh.f,1)-size(mesh.f_c,1)),1])]);
%     savefig(['region',num2str(region_number) ,scene_name,'_hole_filled_multi_plane_1st_iteration_all_points.fig']);
end