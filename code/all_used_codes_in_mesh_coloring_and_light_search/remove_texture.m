function remove_texture()
image_height=1024;
image_width=1280;
% load('1LXtFkjw3qL_1.ply.mat');
% mesh=convert_python_generated_mat_to_similar_to_ours(dahy);
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
scene_path='D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux/dataset/';
region_number=15;
scene_name='1LXtFkjw3qL_1'; %2,15,17,21,26,29
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
    %         delete([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    load([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    
catch
    load([scene_path,scene_name,'/original_regions/',insider_directory,region_file_all])
    tic
    mesh=convert_python_generated_mat_to_similar_to_ours_v_0_6(dahy,region_file_no_simplification_path,use_simplified,folder_path,region_number,scene_name,smooth);
    toc
    save([scene_path,scene_name,'/created_mesh_regions/',mesh_file],'mesh');
end

%      figure, plot_CAD(mesh.f, mesh.v, '');
%     delete(findall(gcf,'Type','light'));

% pose_num=223;
% mesh1=mesh;
% wide_range=1/6;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% circle_center_point=mesh1.campos(pose_num+1,:);
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
%
% wide_range=1/4;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% [rays_directions,~]=get_ray_direction(mesh1.pose(pose_num+1).pose_matrix,mesh1.intrinsics,[1 ;1]);
% % rays_directions(2)=1-2*rays_directions(2);
% circle_center_point=mesh1.campos(pose_num+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% % figure, plot_CAD(mesh1.f, mesh1.v, '');
%
%
% wide_range=1/4;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% [rays_directions,~]=get_ray_direction(mesh1.pose(pose_num+1).pose_matrix,mesh1.intrinsics,[1;1024;]);
% % rays_directions(2)=1-2*rays_directions(2);
% circle_center_point=mesh1.campos(pose_num+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% % figure,plot_CAD(mesh1.f, mesh1.v, '');
%
% wide_range=1/4;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% [rays_directions,~]=get_ray_direction(mesh1.pose(pose_num+1).pose_matrix,mesh1.intrinsics,[ 1280;1024;]);
% % rays_directions(2)=1-2*rays_directions(2);
% circle_center_point=mesh1.campos(pose_num+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
% % figure,plot_CAD(mesh1.f, mesh1.v, '');
%
% wide_range=1/4;
% [x,y,z]=sphere(10);
% x=x*wide_range;
% y=y*wide_range;
% z=z*wide_range;
% [rays_directions,~]=get_ray_direction(mesh1.pose(pose_num+1).pose_matrix,mesh1.intrinsics,[1280; 1;]);
% % rays_directions(2)=1-2*rays_directions(2);
% circle_center_point=mesh1.campos(pose_num+1,:)+4*rays_directions';
% fvc=surf2patch(x,y,z,'triangles');
% % change the direction of faces
% fvc.faces=flip_direction_of_faces(fvc.faces);
% mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
% fvc.vertices=[fvc.vertices+circle_center_point];
% mesh1.v=[mesh1.v;fvc.vertices];
%
% figure,plot_CAD(mesh1.f, mesh1.v, '');
 regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
        faces_count_per_regions=table2array(readtable(regions_info_path));
        if (region_number==0);start_of_faces_indexing=0;
        else ;start_of_faces_indexing=faces_count_per_regions(region_number); end
        if region_number==length(faces_count_per_regions)
            end_of_faces_indexing=faces_count_per_regions(region_number)+size(mesh.f,1);
        else
            end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;
        end
number_of_faces=length(mesh.normals)-1;%33,67,
region15_frames=[138,139,140,141,142,143,148,222,223,224,225,226,227,336,337,338,339,340,341,373,408,415,416,469,470,479,501,537,600,601,605,631,632,636,637,638,639,640,641,642,657,682,721];
t = opcodemesh((mesh.v)',(mesh.f)');
faces_regions_mapping=zeros([size(mesh.f,1) 30]);
valid_region_counter=0;
max_face_area=0.0005;
% [mesh.f,mesh.v]=refine_mesh(mesh.f,mesh.v,max_face_area);
% mesh.normals = meshFaceNormals(mesh.v,mesh.f);
% mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
try
    delete('meshplus_lum.mat');
    load('meshplus_lum.mat');
catch
    mesh.f_lum=zeros([size(mesh.f,1) 1]);
    tic
    for i=region15_frames
        
        image_name=sprintf('frame-%06d.color.jpg',i);
        image_path=['1LXtFkjw3qL_1/frame/',image_name];
        objects_mask_path=['1LXtFkjw3qL_1/masks/',image_name(1:end-3),'png'];
        faces_mask_path=['1LXtFkjw3qL_1/faces_masks/',image_name(1:end-3),'png'];
        objects_numbers_path=['1LXtFkjw3qL_1/masks/',image_name(1:end-3),'txt'];
        %%
        [faces_image,~,trans]=imread(faces_mask_path);
        r=faces_image(:,:,1);
        g=faces_image(:,:,2);
        b=faces_image(:,:,3);
        A=double([trans(:),r(:),g(:),b(:)]);
        faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
        faces_numbers=faces_numbers+1;
        faces_numbers(faces_numbers>(end_of_faces_indexing-1))=-1;
        faces_numbers=faces_numbers-start_of_faces_indexing;
        faces_numbers(faces_numbers<1)=1;
        % faces_numbers(faces_numbers>number_of_faces)=number_of_faces+1;
        image_normals=reshape(mesh.normals(faces_numbers,:),[1024,1280,3]);
        [azimuth,elevation,~]=cart2sph(image_normals(:,:,1),image_normals(:,:,2),image_normals(:,:,3));
        
        fileID = fopen(objects_numbers_path,'r');
        existed_objects = fscanf(fileID,'%i');
        image=imread(image_path);
        
%         Red=image(:,:,1);
%         Green=image(:,:,2);
%         Blue=image(:,:,3);
        % filtered_image = imbilatfilt(image);% I do not have bilateral filtering
        % in this version of matlab so I will skip it for now
        % filtered_image = image;
        % imYCBCR = rgb2ycbcr(filtered_image);
        % Y=imYCBCR(:,:,1);
        M1=max(image,[],3);
        Y = imbilatfilt(M1);
        M1=Y;
        % I = im2double(M1);
        
        % Set patch size and number of iterations (listed in the image name)
        k = 7;
        iter = 5;
        
        % Apply the bilateral texture filter
        % M11 = bilateralTextureFilter(I, k, iter);
        
        
        % multi-thresh way of segmentation
        threshRGB = multithresh(Y,20);
        quantRGB = imquantize(Y, threshRGB);
        Y_eq=histeq(uint8(quantRGB));
        levels=unique(Y_eq);
        regions_image=double(zeros(size(Y)));
        total_num_objects=0;
        for level_ind=1:length(levels)
            [labels,num_obj]=bwlabel(Y_eq==levels(level_ind));
            labels(labels>0)=labels(labels>0)+total_num_objects;
            regions_image(labels>0)=labels(labels>0);
            total_num_objects=total_num_objects+num_obj;
        end
        % imshow(histeq(uint8(quantRGB)))
        
        %  superpixel way of segmentation
        % [L,N] = superpixels(Y,100,'Compactness',1);
        % figure
        % BW = boundarymask(L);
        % imshow(imoverlay(Y,BW,'cyan'),'InitialMagnification',67)
        % figure;imshow(Y>0.89*255);
        [GmagY, GdirY] = imgradient(M1,'roberts');
        % figure;subplot(1,3,1);imshow((GmagY>7));
        norm_GmagY=GmagY/max(max(GmagY));
        norm_azimuth=(azimuth+3.14)/(2*3.14);
        % figure;imshow(uint8(norm_azimuth*255))
        [Gmagaz, Gdiraz] = imgradient(norm_azimuth,'roberts');
        % norm_Gmagaz=Gmagaz/max(max(Gmagaz));
        % figure;imshow(uint8(norm_Gmagaz*255))
        % figure;imshow(Gmagaz)
        % subplot(1,3,2);imshow(Gmagaz>0.01)
        norm_Gmagaz=Gmagaz/max(max(Gmagaz));
        norm_elevation=(elevation+3.14)/(2*3.14);
        % figure;imshow(uint8(norm_elevation*255))
        [Gmagev, Gdirev] = imgradient(norm_elevation,'roberts');
        norm_Gmagev=Gmagev/max(max(Gmagev));
        % figure;imshow(uint8(norm_Gmagev*255))
        % subplot(1,3,3);imshow(Gmagev>0.01);
        merged_borders=GmagY>7|Gmagaz>0.02|Gmagev>0.02;
        imwrite([merged_borders],['output_figures/',image_name]);
        
        hitted_mesh_pixels=[];
        [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(merged_borders));
        [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
        temp_index=ones([size(rays_directions,2),1])*i+1;
        [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
        border_faces=unique(idxx);
        
        label_image =~merged_borders;
        hitted_mesh_pixels=[];
        %             hitted_mesh_pixels_indexed=[];
        hitted_mesh_pixels_indexed=find(label_image);
        [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(label_image));
        [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
        temp_index=ones([size(rays_directions,2),1])*i+1;
        [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
        hitted_mesh_pixels_indexed(idxx==0)=[];
        idxx(idxx==0)=[];
         ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(idxx, :), mesh.normals(idxx, :));
         sum(ind22)
        hitted_mesh_pixels_indexed(ind22)=[];
        idxx(ind22)=[];
        % and remove them since they do not face each other

        %             idxx=unique(idxx);
        %             hitted_mesh_pixels(idxx==0,:)=[];
        
        while(1)
            [~,temp_inds]=intersect(idxx,border_faces,'stable');
            if(isempty(temp_inds))
                break;
            end
            idxx(temp_inds)=[];
            %                 hitted_mesh_pixels(temp_inds,:)=[];
            hitted_mesh_pixels_indexed(temp_inds,:)=[];
        end
        unique_of_repeated_faces=unique(idxx);
        average_color=[];
        for rep_f_index=1:length(unique_of_repeated_faces)
            average_color(rep_f_index)=mean(M1(hitted_mesh_pixels_indexed(idxx==unique_of_repeated_faces(rep_f_index))));
        end
        mesh.f_lum(unique_of_repeated_faces)=max(mesh.f_lum(unique_of_repeated_faces),average_color');
        
        
        
        
        
%         [L,n]=bwlabel(~merged_borders);
%         counter=0;
%         label_image_final=[];
        
%         for j=1:n
%             label_image=L==j;
%             region_faces=unique(faces_numbers(label_image(:)));
%             if(length(region_faces)<10)
%                 continue;
%             else
%                 %          if(~isempty(missing_mesh_indexes))
%                 % mesh1=mesh;
%                 % wide_range=1/4;
%                 % [x,y,z]=sphere(10);
%                 % x=x*wide_range;
%                 % y=y*wide_range;
%                 % z=z*wide_range;
%                 %
%                 % hitted_mesh_pixels=[];
%                 %             [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],[1024*1280-1023]);
%                 %  [rays_directions,~]=get_ray_direction(mesh1.pose(i+1).pose_matrix,mesh1.intrinsics,hitted_mesh_pixels);
%                 % circle_center_point=mesh1.campos(i+1,:)+4*rays_directions';
%                 % fvc=surf2patch(x,y,z,'triangles');
%                 % % % change the direction of faces
%                 % fvc.faces=flip_direction_of_faces(fvc.faces);
%                 % mesh1.f=[mesh1.f;(fvc.faces+length(mesh1.v))];
%                 % fvc.vertices=[fvc.vertices+circle_center_point];
%                 % mesh1.v=[mesh1.v;fvc.vertices];
%                 % figure,plot_CAD(mesh1.f, mesh1.v, '');
%                 
%                 hitted_mesh_pixels=[];
%                 hitted_mesh_pixels_indexed=[];
%                 hitted_mesh_pixels_indexed=find(label_image);
%                 [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(label_image));
%                 [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
%                 temp_index=ones([size(rays_directions,2),1])*i+1;
%                 [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
%                 %             idxx=unique(idxx);
%                 %             hitted_mesh_pixels(idxx==0,:)=[];
%                 hitted_mesh_pixels_indexed(idxx==0,:)=[];
%                 idxx(idxx==0)=[];
%                 while(1)
%                     [~,temp_inds]=intersect(idxx,border_faces,'stable');
%                     if(isempty(temp_inds))
%                         break;
%                     end
%                     idxx(temp_inds)=[];
%                     %                 hitted_mesh_pixels(temp_inds,:)=[];
%                     hitted_mesh_pixels_indexed(temp_inds,:)=[];
%                 end
%                 unique_of_repeated_faces=unique(idxx);
%                 average_color=[];
%                 for rep_f_index=1:length(unique_of_repeated_faces)
%                     average_color(rep_f_index)=mean(M1(hitted_mesh_pixels_indexed(idxx==unique_of_repeated_faces(rep_f_index))));
%                 end
%                 mesh.f_lum(unique_of_repeated_faces)=max(mesh.f_lum(unique_of_repeated_faces),average_color');
%                 %             if(~isempty(idxx))
%                 %                 valid_region_counter=valid_region_counter+1;
%                 %                 required_indexes=sub2ind([size(mesh.f,1) (max(faces_regions_mapping(:,1))+2)],idxx,(faces_regions_mapping(idxx,1)+2));
%                 %                 faces_regions_mapping(required_indexes)=valid_region_counter;
%                 %
%                 %                 faces_regions_mapping(idxx,1)=faces_regions_mapping(idxx,1)+1;
%                 %                 if(max(faces_regions_mapping(:,1))==size(faces_regions_mapping,2))
%                 %                     faces_regions_mapping=[faces_regions_mapping,zeros([size(faces_regions_mapping,1) 2])];
%                 %                 end
%                 %             end
%                 %             d=[];
%                 %             [valll,iddd]=intersect(idxx,region_faces,'stable');
%                 %             qqq=faces_numbers;
%                 %             for e=1:length(valll)
%                 %                 ee=find(faces_numbers==valll(e));
%                 %                 rr(e,1:length(ee))=ee;
%                 %             end
%                 %             rr=rr(:);
%                 %             rr(rr==0)=[];
%                 %             qqq(:)=0;
%                 %             qqq(rr)=255;
%                 %             qqq=reshape(qqq,[1024 1280]);
%                 %             figure
%                 %             imshow(uint8(qqq))
%                 %             %
%                 %             if (isempty(label_image_final))
%                 %                 label_image_final=label_image;
%                 %             else
%                 %                 label_image_final=label_image_final|label_image;
%                 %             end
%                 %             counter=counter+1;
%             end
%             d=[];
%         end
        %     imwrite(label_image_final,['output_groups/',image_name])
    end
    save('meshplus_lum.mat');
end
figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
toc
all_appeared_faces=find(sum(faces_regions_mapping,2));
final_grouped_regions=[];
grouped_regions_index=1;
tic
while(~isempty(all_appeared_faces))
    current_face=all_appeared_faces(1);
    excluded_faces=current_face;
    current_regions=faces_regions_mapping(current_face,2:end);
    current_regions(current_regions==0)=[];
    excluded_regions=current_regions;
    
    grouped_faces=get_faces_from_regions(current_regions,faces_regions_mapping,excluded_faces,excluded_regions);
    final_grouped_regions(grouped_regions_index,1:length(grouped_faces))=grouped_faces;
    [~,indexes]=intersect(all_appeared_faces,grouped_faces,'stable');
    all_appeared_faces(indexes)=[];
end
toc
diff_Y=double(get_diff(Y))/(235*2);
diff_azimuth=get_diff(azimuth)/(3.14*4);
diff_elevation=get_diff(elevation)/(3.14*4);

% diff_Y=double(get_diff(Y));
% diff_azimuth=get_diff(azimuth);
% diff_elevation=get_diff(elevation);

Ratio_azimuth=diff_azimuth./diff_Y;
Ratio_elevation=diff_elevation./diff_Y;
H = [0 0 1 0 0; 0 0 1 0 0;1 1 1 1 1; 0 0 1 0 0;0 0 1 0 0];
H = [ 0 1 0 ;  1 1 1 ;  0 1  0];
average_Ratio_azimuth = filter2(ones(5),Ratio_azimuth,'same');
average_Ratio_elevation = filter2(ones(5),Ratio_elevation,'same');
greater_ratio=0.15;
greater_than_average_Ratio_azimuth=abs(Ratio_azimuth-greater_ratio*average_Ratio_azimuth)>0;
greater_than_average_Ratio_elevation=abs(Ratio_elevation-greater_ratio*average_Ratio_elevation)>0;
imshow(greater_than_average_Ratio_azimuth)
figure;imshow(greater_than_average_Ratio_elevation)

% [sel c]= max( x~=0, [], 2 )
% l_avg_Y=[Y(1,:);Y(1,:);Y];
% [~ ,c]= max( l_avg_Y'~=0, [], 2 );
% start_rows=(size(l_avg_Y,2)-c)';
% l_avg_Y=imfilter([Y(1,:);Y(1,:);Y],[1;1;1;1;1]);
% imLAB = rgb2lab(image);
% patchSq = imLAB.^2;
% edist = sqrt(sum(patchSq,3));
% patchVar = std2(edist).^2;
% DoS = 1*patchVar;
% filtered_image = imbilatfilt(image,DoS);
% filtered_image = imbilatfilt(image);
% imshow(filtered_image)
mask_image=imread(objects_mask_path);
for i =1:length(existed_objects)
    bits = reshape(bitget(existed_objects(i),32:-1:1),8,[]); %// num is the input number
    weights2 = 2.^([7:-1:0]);
    temp=weights2*bits;
    new_existed_objects(i,:) = temp(2:end);
    current_object_mask=mask_image(:,:,1)==temp(4)&mask_image(:,:,2)==temp(3)&mask_image(:,:,3)==temp(2);
    
    curr_object_regions=zeros(size(Y));
    curr_object_regions(current_object_mask)=regions_image(current_object_mask);
    nnn=unique(curr_object_regions);
    regions=histeq(uint8(curr_object_regions-min(nnn)+1));
    imshow(regions)
    %     [row,col]=find(current_object_mask);
    %     cropped_object_mask=current_object_mask(min(row):max(row),min(col):max(col));
    %     imshow(current_object_mask)
end
new_existed_objects(:,1)=[];

d=[];



d=[];

