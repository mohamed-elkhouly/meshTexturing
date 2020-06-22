function remove_texture()
clear all
image_height=1024;
image_width=1280;
% load('1LXtFkjw3qL_1.ply.mat');
% mesh=convert_python_generated_mat_to_similar_to_ours(dahy);
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
scene_path='D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux/dataset/';

region_number=21;

scene_name='1LXtFkjw3qL_1'; %2,15,17,21,26,29
%   scene_name='82sE5b5pLXE_1'; %0,1,3
use_simplified=0;
smooth=1;
region_file_no_simplification_path=[scene_path,scene_name,'/original_regions/','region',num2str(region_number),'.mat'];
folder_path=[scene_path,scene_name];
use_simplified=0;
if use_simplified>0
    simplified_version='_0.05_';
    insider_directory=['simplified_regions/','region',num2str(region_number),'/'];
else
    simplified_version='';
    insider_directory='';
end
if smooth
    mesh_file=['meshregion',num2str(region_number),simplified_version,'smmothed','.mat'];
else
    mesh_file=['meshregion',num2str(region_number),simplified_version,'.mat'];
end
region_file_all=['region',num2str(region_number),simplified_version,'.mat'];
try
    %                 delete([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    load([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    
catch
    load([scene_path,scene_name,'/original_regions/',insider_directory,region_file_all])
    tic
    mesh=convert_python_generated_mat_to_similar_to_ours_v_0_6(dahy,region_file_no_simplification_path,use_simplified,folder_path,region_number,scene_name,smooth);
    toc
    save([scene_path,scene_name,'/created_mesh_regions/',mesh_file],'mesh');
end

tic
[required_edges_faces,~]=get_faces_on_hard_edges(mesh.f,mesh.v,15);
time_to_find_3d_edges=toc
% mesh.f_lum=zeros([size(mesh.f,1) 1]);
% mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
% [mesh.f,mesh.v,num_new_faces,required_edges_vertices,max_face_area]=refine_mesh(mesh.f, mesh.v,-1,required_edges_faces,0.5,required_edges_vertices);
%
% mesh.f_lum=zeros([size(mesh.f,1) 1]);
% mesh.f_lum((end-num_new_faces+1):end)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
%

t = opcodemesh((mesh.v)',(mesh.f)');
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
region_frames=mesh.region_frames;
% try
%     delete('meshplus_lum.mat');
%     load('meshplus_lum.mat');
% catch
mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.appeared_faces_in_all_projections=false([size(mesh.f,1) 1]);
tic
for fff=1:length(region_frames)
    i=region_frames(fff);
    image_name=sprintf('frame-%06d.color.jpg',i);
    image_path=[scene_name,'/frame/',image_name];
    %         objects_mask_path=[scene_name,'/masks/',image_name(1:end-3),'png'];
    %         faces_mask_path=[scene_name,'/faces_masks/',image_name(1:end-3),'png'];
    %         objects_numbers_path=[scene_name,'/masks/',image_name(1:end-3),'txt'];
    %%
    image=imread(image_path);
    M_max=max(image,[],3);
    %         figure;subplot(1,2,1),imshow(M_max);
    M1 = imbilatfilt(M_max);
    %         subplot(1,2,2),imshow(M1);
    
    [GmagY, ~] = imgradient(M1,'roberts');
    %         imwrite([M_max,M1,uint8(255*(uint8(GmagY)>10))],['filtering_results/',image_name]);
    merged_borders=uint8(GmagY)>10;
    merged_borders(:,[1:5,end-4:end])=0;
    merged_borders([1:5,end-4:end],:)=0;
    %         imwrite([merged_borders],['output_figures/',image_name]);
    
    hitted_mesh_pixels=[];
    [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(merged_borders));
    [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
    temp_index=ones([size(rays_directions,2),1])*i+1;
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
    hitted_faces=unique(idxx);
    hitted_faces(hitted_faces==0)=[];
    ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces, :), mesh.normals(hitted_faces, :));
    hitted_faces(ind22)=[];
    distance_to_camera=vecnorm((mesh.centroids(hitted_faces, :)-mesh.campos(i+1, :))',1);
    hitted_faces(distance_to_camera>5)=[];
    mesh.f_lum(hitted_faces)=255;
    
    if(1)% keep track of all projected faces to remove the non visible faces
        hitted_mesh_pixels=[];
        [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
        [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
        temp_index=ones([size(rays_directions,2),1])*i+1;
        [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
        appeared_faces=unique(idxx);
        appeared_faces(appeared_faces==0)=[];
        mesh.appeared_faces_in_all_projections(appeared_faces)=1;
    end
    
end
time_to_find_2d_edges=toc
%     save('meshplus_lum_smoothed.mat');
% end


% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
detected_edge_faces_using_images1=sum((mesh.f_lum>0),2)>0;
% create a new mesh which will contain the only the edges  faces itself and
% the faces touching theses edges
tempmesh_faces=mesh.f;
% remove faces which did not appear at all in projections
mesh.f_lum(~mesh.appeared_faces_in_all_projections)=255;

% next three lines we remove faces corresponding to edges
detected_edge_faces_using_images2=sum((mesh.f_lum>0),2)>0;
mesh.v=[mesh.v;min(mesh.v)-0.00001];
mesh.f(detected_edge_faces_using_images2,:)=size( mesh.v,1);

fullpatch.vertices=mesh.v;
fullpatch.faces=mesh.f;
tic
[~,fSets] = splitFV(fullpatch);
time_to_create_groups=toc
color_val = distinguishable_colors(max(fSets));
% color_val=histeq(color_val);
mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.f_lum=[mesh.f_lum(:),mesh.f_lum(:),mesh.f_lum(:)];
regions_edge_faces={};
region_faces={};
region_index=1;
all_used_groups_faces=[];
tic
for i=1:max(fSets)
    %     faces=
    if(sum(fSets==i)<50)
        continue
    end
    C = repmat(color_val(i,:),[sum(fSets==i) 1]);
    mesh.f_lum(fSets==i,:)=C;
    
    faces_indexes=find(fSets==i);
    faces=mesh.f(faces_indexes,:);
    % compute total number of edges
    nFaces  = size(faces, 1);
    nVF     = size(faces, 2);
    nEdges  = nFaces * nVF;
    
    % create all edges (with double ones)
    edges = zeros(nEdges, 2);
    edge_face_index=zeros([nEdges,1]);
    %     for j = 1:nFaces
    %         f = faces(j, :);
    %         edges(((j-1)*nVF+1):j*nVF, :) = [f' f([2:end 1])'];
    %         edge_face_index(((j-1)*nVF+1):j*nVF)=faces_indexes(j);
    %     end
    j=(1:nFaces)';
    ff=faces(j, :);
    ff2=([ff(:,2),ff(:,3),ff(:,1)])';
    ff=ff';
    edges=[ff(:), ff2(:)];
    edge_face_index=([j,j,j])';
    edge_face_index=faces_indexes(edge_face_index(:));
    [sorted_edges,~]=sort(edges, 2);
    [~,~,index_of_sorted_edges_in_uniques]=unique(sorted_edges,'rows','stable');
    div_val=1;
    %     tic
    while(1)
        
        try
            occurence_of_edges=sum(index_of_sorted_edges_in_uniques(1:ceil(length(index_of_sorted_edges_in_uniques)/div_val))==index_of_sorted_edges_in_uniques');
            break;
        catch
            div_val=div_val+2;
        end
    end
    if (sum(occurence_of_edges<2)<1)
        continue;
    end
    len_val=ceil(length(index_of_sorted_edges_in_uniques)/div_val);
    for k=2:div_val-1
        occurence_of_edges=occurence_of_edges+sum(index_of_sorted_edges_in_uniques((k-1)*len_val+1:(k)*len_val)==index_of_sorted_edges_in_uniques');
        if (sum(occurence_of_edges<2)<1)
            continue;
        end
    end
    if(div_val>1)
        occurence_of_edges=occurence_of_edges+sum(index_of_sorted_edges_in_uniques((div_val-1)*len_val+1:end)==index_of_sorted_edges_in_uniques');
    end
    %     toc
    %     tic
    %     occurence_of_edges = zeros(size(index_of_sorted_edges_in_uniques));
    %     for k = 1:length(index_of_sorted_edges_in_uniques)
    %         occurence_of_edges(k) = sum(index_of_sorted_edges_in_uniques==index_of_sorted_edges_in_uniques(k));
    %     end
    %     toc
    
    %     end
    
    single_occured_edges=occurence_of_edges==1;
    edge_face_index=unique(edge_face_index(single_occured_edges));
    if(length(edge_face_index)>1)
        region_faces(region_index)={faces_indexes};
        temp_appeared_group_faces=[faces_indexes,ones([size(faces_indexes,1),1])*region_index];
    all_used_groups_faces=[all_used_groups_faces;temp_appeared_group_faces];
        regions_edge_faces(region_index)={edge_face_index};
        region_index=region_index+1;
        C = repmat([ 255 255 0],[length(edge_face_index) 1]);
        mesh.f_lum(edge_face_index,:)=C;
        % filling the tempmesh_faces indexer
        
        detected_edge_faces_using_images1(edge_face_index)=1;
    end
    
end
time_to_find_border_faces=toc
% tempmesh_faces(~detected_edge_faces_using_images1,:)=size( mesh.v,1);

figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
tic
other_regions_faces_back=cell2mat(regions_edge_faces(:));

[temp_ind_x,temp_ind_y]=find(triu(true(length(regions_edge_faces)),1));
tic
length_of_arrays=0;
for c_ind =1:length(temp_ind_x)
    x_indexes=(cell2mat(regions_edge_faces(temp_ind_x(c_ind))));
    y_indexes=(cell2mat(regions_edge_faces(temp_ind_y(c_ind))));
    length_of_arrays=length_of_arrays+length(x_indexes)*length(y_indexes);
end

% dot_prod_array=zeros;
final_x_indexes_list=zeros([length_of_arrays 1]);
final_y_indexes_list=zeros([length_of_arrays 1]);
final_dot_prod_list=zeros([length_of_arrays 1]);
last_ind=0;

for c_ind =1:length(temp_ind_x)
    x_indexes=(cell2mat(regions_edge_faces(temp_ind_x(c_ind))))';
    y_indexes=(cell2mat(regions_edge_faces(temp_ind_y(c_ind))))';
    temp=combvec(x_indexes,y_indexes);
    x_indexes=(temp(1,:))';
    y_indexes=(temp(2,:))';
    
    final_x_indexes_list(last_ind+1:(last_ind+length(x_indexes)))=x_indexes;
    final_y_indexes_list(last_ind+1:(last_ind+length(x_indexes)))=y_indexes;
    final_dot_prod_list(last_ind+1:(last_ind+length(x_indexes)))=dot(mesh.normals(x_indexes,:),mesh.normals(y_indexes,:),2);
    last_ind=last_ind+length(x_indexes);
    %     dot_prod_ind=1;
    %     tic
    %     for x_iter=1:length(x_indexes)
    %         for y_iter=1:length(y_indexes)
    %             normal1=x_indexes(x_iter);
    %             normal2=y_indexes(y_iter);
    %             dot_prod(dot_prod_ind)=dot(mesh.normals(normal1,:),mesh.normals(normal2,:));
    %             dot_prod_ind=dot_prod_ind+1;
    %         end
    %     end
    %     toc
    %     final_dot_prod=[final_dot_prod;dot_prod];
end

dot_prod_matrix=sparse(final_x_indexes_list,final_y_indexes_list,final_dot_prod_list,size(mesh.f,1),size(mesh.f,1));
time_to_create_dot_prod_matrix=toc
distance_threshold=0.7;
behind_threshold=0.01;
faces_correspondences={};


tic
for i=1:length(regions_edge_faces)
    other_groups_faces=other_regions_faces_back;
    others_indexes=1:length(regions_edge_faces);
    current_group_faces=cell2mat(regions_edge_faces(i));
    
    others_indexes(i)=[];
    [~,idxs]=intersect(other_groups_faces,current_group_faces,'stable');
    other_groups_faces(idxs)=[];
    %     current_region_faces_centers=mesh.centroids(current_group_faces,:);
    %     other_region_faces_centers=mesh.centroids(other_groups_faces,:);
    nearest_faces_to_current_group_faces=get_nearst_faces_from_other_groups2(cell2mat(region_faces(i)),region_number,tempmesh_faces,current_group_faces,other_groups_faces,mesh.centroids,mesh.normals,distance_threshold,behind_threshold,dot_prod_matrix);
    nearest_faces_to_current_group_faces(nearest_faces_to_current_group_faces(:,2)==0,:)=[];
    unique_target_faces=unique(nearest_faces_to_current_group_faces(:,2));
    %     the next first for loop is to make the relations between faces a 1:1 relations and skip over regions connections.
    new_nearest_faces_to_current_group_faces=zeros([length(unique_target_faces),3]);
    for k=1:length(unique_target_faces)
        new_mat=nearest_faces_to_current_group_faces(nearest_faces_to_current_group_faces(:,2)==unique_target_faces(k),:);
        [~,min_ind]=min(new_mat(:,3));
        new_nearest_faces_to_current_group_faces(k,:)=new_mat(min_ind,:);
    end
    faces_correspondences(i)={new_nearest_faces_to_current_group_faces};
%     temp_appeared_edge_faces=new_nearest_faces_to_current_group_faces(:,1:2);
%     temp_appeared_edge_faces=[temp_appeared_edge_faces,ones([size(temp_appeared_edge_faces,1),1])*i];
%     all_used_edge_faces=unique([all_used_edge_faces;temp_appeared_edge_faces],'rows');
    for j=1:size(new_nearest_faces_to_current_group_faces,1)
        temp=([mesh.centroids(new_nearest_faces_to_current_group_faces(j,1),:);mesh.centroids(new_nearest_faces_to_current_group_faces(j,2),:)]);
        plot3(temp(:,1),temp(:,2),temp(:,3),'y')
    end
    %     for j=1:length(current_group_faces)
    %         distances=sum((current_region_faces_centers(j,:)-other_region_faces_centers).^2,2);
    %         ind22 = ~isFacing(current_region_faces_centers(j,:), mesh.normals(current_group_faces(j),:), other_region_faces_centers, mesh.normals(other_groups_faces, :));
    %         %         I want to add a condition here to skip these faces which is falling on the same plane with current vertex from excluding
    %         % also I want to add a condition to
    %         distances(ind22)=max(distances)+1;
    %         [dist,other_face_index_in_distances]=min(distances);
    %         if(dist<0.03)
    %             other_face_index_in_mesh=other_groups_faces(other_face_index_in_distances);
    %             temp=([current_region_faces_centers(j,:);mesh.centroids(other_face_index_in_mesh,:)]);
    %             plot3(temp(:,1),temp(:,2),temp(:,3),'y')
    %         end
    %     end
end
time_to_plot_lines=toc

all_used_edge_faces=[];
for ert=1:length(faces_correspondences)
    new_nearest_faces_to_current_group_faces=cell2mat(faces_correspondences(ert));
    temp_appeared_edge_faces=new_nearest_faces_to_current_group_faces(:,1:2);
    temp_appeared_edge_faces=[temp_appeared_edge_faces,ones([size(temp_appeared_edge_faces,1),1])*ert];
    all_used_edge_faces=unique([all_used_edge_faces;temp_appeared_edge_faces],'rows');
end

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end

end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;% -1 to go down to the last face number in the last region,+1 to use faces numbers as indexes in matlab

visible_pixels_for_faces=zeros(size(all_used_groups_faces,1),150);
distance_visible_pixels_for_faces_from_camera=zeros(size(all_used_groups_faces,1),150);
h = fspecial('average', 3);
tic
for fff=1:length(region_frames)
    i=region_frames(fff);
    image_name=sprintf('frame-%06d.color.jpg',i);
    image_path=[scene_name,'/frame/',image_name];
    image=imread(image_path);
    M_max=max(image,[],3);
    M1=M_max;
%     M1 = imbilatfilt(M_max);
%     M1 = imfilter(M1, h);
%     M1=colfilt(M1, [3 3], 'sliding', @mode);
%     hitted_mesh_pixels=[];
%     [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
%     [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
%     temp_index=ones([size(rays_directions,2),1])*i+1;
%     [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);

file_path=[folder_path,'/frames_faces_mapping/','frame-',sprintf('%06d',i),'.color.png'];
            [faces_image,~,trans]=imread(file_path);
            r=faces_image(:,:,1);
            g=faces_image(:,:,2);
            b=faces_image(:,:,3);
            A=double([trans(:),r(:),g(:),b(:)]);
            faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
            idxx=faces_numbers+1;% this +1 because we stored faces numbers as indexes which start from 1 in matlab not 0 like others.
             
            
            
            idxx=idxx-start_of_faces_indexing;
            back_idxx=[idxx,(1:length(idxx))'];
            back_idxx(idxx>end_of_faces_indexing,:)=[];
             idxx(idxx>end_of_faces_indexing)=[];
             
            back_idxx(idxx<=0,:)=[];
             idxx(idxx<=0)=[];
    [hitted_faces,ia_hitted_faces,indexes_of_faces_in_originals]=unique(idxx);
    [sorted_f,index_f]=sort(indexes_of_faces_in_originals);
%     faces_places_in_image=[];
%     faces_places_in_image(1)=1;
%     parfor kl=2:length(hitted_faces)
%       faces_places_in_image(kl)  =find(sorted_f==kl,1,'first');
%     end
    [~,faces_places_in_image,~]=unique(sorted_f);
    faces_places_in_image(length(hitted_faces)+1)=length(sorted_f)+1;
%     ia_hitted_faces(hitted_faces<=0)=[];
%     hitted_faces(hitted_faces<=0)=[];
      
%     ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces, :), mesh.normals(hitted_faces, :));
%     ia_hitted_faces(ind22)=[];
%     hitted_faces(ind22)=[];
    [~,index_in_all_used_group_faces_1,index_in_hitted_faces_1]=intersect(all_used_groups_faces(:,1),hitted_faces);
%     index_of_hitted_faces_in_image=ia_hitted_faces(index_in_hitted_faces_1);
    groups_faces=all_used_groups_faces(index_in_all_used_group_faces_1,:);


    hitted_faces_2=groups_faces(:,1);
           ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces_2, :), mesh.normals(hitted_faces_2, :));
           if(sum(ind22)>1)
               d=[];
           end
    hitted_faces_2(ind22)=[];
    index_in_hitted_faces_1(ind22)=[];
    groups_faces(ind22,:)=[];
    index_in_all_used_group_faces_1(ind22)=[];
    visible_faces_centroids=mesh.centroids(hitted_faces_2,:);
    points_on_frame=int32(project_points_on_frame(mesh.pose(i+1).pose_matrix,mesh.intrinsics,visible_faces_centroids));
    distance_from_cam=vecnorm(   (visible_faces_centroids-mesh.campos(i+1))');

indexes_for_visible_pixels_for_faces=sub2ind(size(visible_pixels_for_faces),index_in_all_used_group_faces_1,visible_pixels_for_faces(index_in_all_used_group_faces_1,1)+2);
%     indexes_for_visible_pixels_for_faces(points_on_frame(2,:)<1|points_on_frame(2,:)>1024)=[];
%     distance_from_cam(points_on_frame(2,:)<1|points_on_frame(2,:)>1024)=[];
%     points_on_frame(:,points_on_frame(2,:)<1|points_on_frame(2,:)>1024)=[];
    
%     indexes_for_visible_pixels_for_faces(points_on_frame(1,:)<1|points_on_frame(1,:)>1280)=[];
%     distance_from_cam(points_on_frame(1,:)<1|points_on_frame(1,:)>1280)=[];
%     points_on_frame(:,points_on_frame(1,:)<1|points_on_frame(1,:)>1280)=[];
%     centers_indexes=sub2ind([1024 1280],points_on_frame(2,:),points_on_frame(1,:));
    
    distance_visible_pixels_for_faces_from_camera(indexes_for_visible_pixels_for_faces)=distance_from_cam;
    
    all_indexes_in_idxx=back_idxx(:,2);
%     tic
%     values_from_face_pixels=[];
%     for ui=1:length(hitted_faces_2)
%       values_from_face_pixels(ui)=mean(M1( all_indexes_in_idxx(back_idxx(:,1)==hitted_faces_2(ui))));
%     end
%     values_from_face_pixels_back=values_from_face_pixels;
%     toc

% tic
 values_from_face_pixels=zeros(size(hitted_faces_2));
 parfor ui=1:length(hitted_faces_2)
     m=index_in_hitted_faces_1(ui);
     if ui==length(hitted_faces_2)
         required_indexes_for_access_image=index_f(faces_places_in_image(m):end);
     else
     required_indexes_for_access_image=index_f(faces_places_in_image(m):faces_places_in_image(m+1)-1);
     end
      values_from_face_pixels(ui)=mode(M1(all_indexes_in_idxx(required_indexes_for_access_image)));
 end
%     toc
     visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=values_from_face_pixels;
     
%      visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=M1(centers_indexes);
    visible_pixels_for_faces(index_in_all_used_group_faces_1,1)=visible_pixels_for_faces(index_in_all_used_group_faces_1,1)+1;
    %     aa=double(idxx);
%     for oo=1:length(hitted_faces_2)
%         aa(aa==hitted_faces_2(oo))=-1;
%     end
%     aa(aa~=-1)=0;
%     aa(aa==-1)=255;
%     aa=reshape(aa,[1024 1280]);
%     imshow(uint8(aa))
%     sum(sum(aa>0))
%     figure;imshow(aa);
end
time_to_get_faces_colors=toc
just_for_analysis=visible_pixels_for_faces;
just_for_analysis(sum(just_for_analysis,2)<1,:)=[];

distance_just_for_analysis=distance_visible_pixels_for_faces_from_camera;
distance_just_for_analysis(sum(visible_pixels_for_faces,2)<1,:)=[];

temp2=distance_just_for_analysis(:,2:max(visible_pixels_for_faces(:,1))+2);
temp=just_for_analysis(:,2:max(visible_pixels_for_faces(:,1))+2);
% figure;
% hold on
slope=[];
back_x_vals=[];
back_y_vals=[];
a=2;
b=[1 1];
% for iii=1:size(temp2,1)/5
parfor iii=1:size(temp2,1)
    temp_val=temp(iii,:);
    temp2_val=temp2(iii,:);
  
    temp_val(temp2_val==0)=[];
    temp2_val(temp2_val==0)=[];
    
    if (length(temp2_val)>1)
         [temp2_val,i_ia]= sort(temp2_val);
   temp_val=temp_val(i_ia);
        
       y_diff=diff(temp_val);
%          while(sum(y_diff>0)>1)
%              temp2_val(logical([0,y_diff>0]))=[];
%              temp_val(logical([0,y_diff>0]))=[];
%               y_diff=diff(temp_val);
%          end
%          if(isempty(y_diff))
%              continue;
%          end
        x_diff= diff(temp2_val);
        y_diff(x_diff==0)=[];
        x_diff(x_diff==0)=[];
        temp_slope=y_diff./x_diff;
        slope=[slope;temp_slope(:)];
        
        tempee=filter(b,a,temp2_val);
        tempee(1)=[];
        back_x_vals=[back_x_vals;tempee(:)];
        tempee=filter(b,a,temp_val);
        tempee(1)=[];
        back_y_vals=[back_y_vals;tempee(:)];
    end
    
end
back_y_vals(slope<-255|slope>255)=[];
back_x_vals(slope<-255|slope>255)=[];
slope(slope<-255|slope>255)=[];
figure;histogram(slope,512);
negative_slopes_number=sum(slope<0)
positive_slopes_number=sum(slope>0)


xlabel('slope');ylabel('count');title(['illumination change with the increasing of distance for faces_region',num2str(region_number),scene_name]);
savefig(['illumination change with the increasing of distance for faces_region',num2str(region_number),scene_name,'.fig']);
temp=temp(:);
temp(temp==0)=[];
% histogram(temp)
figure;histogram(temp)
savefig(['appeared_colors_histogram_in_faces_region',num2str(region_number),scene_name,'.fig']);
figure;histogram(back_y_vals(slope<0&slope>-4))
figure;histogram(back_y_vals(slope<0&slope>-15))
figure;histogram(back_y_vals(slope<-16&slope>-100))

bar(back_y_vals,slope)
[a1,~,c1] = unique(slope);
A1 = accumarray(c1(:),back_y_vals(:));
figure;bar3h(a1(:),A1(:));
[a2,~,c2] = unique(slope);
A2 = accumarray(c2(:),back_x_vals(:));
figure;bar3h(a2(:),A2(:));
% plot(temp2,temp)
%% this for is to get the border faces visible on each image then we will re assign using it.
for fff=1:length(region_frames)
    i=region_frames(fff);
    image_name=sprintf('frame-%06d.color.jpg',i);
    image_path=[scene_name,'/frame/',image_name];
    image=imread(image_path);
    M_max=max(image,[],3);
    M1 = imbilatfilt(M_max);
    hitted_mesh_pixels=[];
    [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1:image_height*image_width]);
    [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
    temp_index=ones([size(rays_directions,2),1])*i+1;
    [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
    [hitted_faces,ia_hitted_faces,~]=unique(idxx);
    ia_hitted_faces(hitted_faces==0)=[];
    hitted_faces(hitted_faces==0)=[];
    ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(hitted_faces, :), mesh.normals(hitted_faces, :));
    ia_hitted_faces(ind22)=[];
    hitted_faces(ind22)=[];
    [~,index_in_all_used_edge_faces_1,index_in_hitted_faces_1]=intersect(all_used_edge_faces(:,1),hitted_faces);
    [~,index_in_all_used_edge_faces_2,index_in_hitted_faces_2]=intersect(all_used_edge_faces(:,2),hitted_faces);
    [border_faces_index,indices]=intersect(index_in_all_used_edge_faces_1,index_in_all_used_edge_faces_2);
    index_in_hitted_faces_1=index_in_hitted_faces_1(indices);
    index_of_hitted_faces_in_image=ia_hitted_faces(index_in_hitted_faces_1);
    border_faces=all_used_edge_faces(border_faces_index,:);
    hitted_faces_2=hitted_faces(index_in_hitted_faces_1);
    aa=double(idxx);
    for oo=1:length(hitted_faces_2)
        aa(aa==hitted_faces_2(oo))=-1;
    end
    aa(aa~=-1)=0;
    aa(aa==-1)=255;
    aa=reshape(aa,[1024 1280]);
    imshow(uint8(aa))
    sum(sum(aa>0))
    figure;imshow(aa);
end

d=[];