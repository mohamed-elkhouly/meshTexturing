function remove_texture()
clear all
image_height=1024;
image_width=1280;
% load('1LXtFkjw3qL_1.ply.mat');
% mesh=convert_python_generated_mat_to_similar_to_ours(dahy);
addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
scene_path='D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux/dataset/';

region_number=15;

scene_name='1LXtFkjw3qL_1'; %2,15,17,21,26,29
%   scene_name='82sE5b5pLXE_1'; %0,1,3
use_simplified=0;
smooth=0;
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
%             delete([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    load([scene_path,scene_name,'/created_mesh_regions/',mesh_file])
    
catch
    load([scene_path,scene_name,'/original_regions/',insider_directory,region_file_all])
    tic
    mesh=convert_python_generated_mat_to_similar_to_ours_v_0_6(dahy,region_file_no_simplification_path,use_simplified,folder_path,region_number,scene_name,smooth);
    toc
    save([scene_path,scene_name,'/created_mesh_regions/',mesh_file],'mesh');
end


regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end
if region_number==length(faces_count_per_regions)
    end_of_faces_indexing=faces_count_per_regions(region_number)+size(mesh.f,1);
else
    end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;
end
number_of_faces=length(mesh.normals)-1;%33,67,138,139,140,141,
region15_frames=[33,67,138,139,140,141,142,143,148,222,223,224,225,226,227,336,337,338,339,340,341,373,408,415,416,469,470,479,501,537,600,601,605,631,632,636,637,638,639,640,641,642,657,682,721];
region2_frames=[12,38,48,49,62,75,97,109,134,161,166,172,178,188,199,208,212,213,214,250,251,275,282,294,295,296,297,298,299,300,304,305,385,403,404,457,484,485,486,487,489,490,491,510,558,559,565,583,588,589,730];
region17_frames=[12,34,67,68,102,103,104,105,106,107,123,124,141,148,149,173,255,338,339,417,418,419,446,474,475,476,479,501,516,517,518,519,520,521,602,603,632,633,634,642,665,682,684,685,686,687,702,707,762];
region29_frames=[15,30,59,69,70,79,84,113,118,141,145,170,186,289,320,334,353,392,408,409,410,419,434,447,482,501,522,523,524,525,526,527,528,529,530,531,532,533,538,548,549,568,569,573,576,577,578,579,587,603,635,645,648,649,650,651,652,653,662,679,701,715,716,763,764,771];
region0_82se_frames=[4,5,24,25,26,27,28,29,43,44,63,75,76,102,133,134,144,192,193,194,195,196,197,228,229,240,241,258,303,304,318,319,330,331,347,348,349,378,384,393,394,407,435,436,456,457,464,471,475,489,490,514,515,559,560,566,567,568,588,589,590,591,592,593,619,654,655,656,657,658,659,660,661,662,663,664,665,699,700,703,704,708,709,710,711,712,713,715,716,742,792,793,809];
region3_82se_frames=[10,20,52,76,77,83,97,113,120,121,122,123,124,125,135,168,169,170,171,172,173,187,204,209,222,223,224,226,227,234,235,236,237,238,239,250,256,257,267,273,304,305,312,368,420,436,470,476,481,482,507,520,532,544,561,562,570,571,572,573,574,575,595,596,609,620,633,652,672,677,684,685,686,687,688,689,693,694,704,729,737,750,760,761,785,810];

faces_regions_mapping=zeros([size(mesh.f,1) 30]);
valid_region_counter=0;
max_face_area=0.0005;


% x=mesh.v(:,1);
% y=mesh.v(:,2);
% z=mesh.v(:,3);
% TR = triangulation(double(mesh.f),x,y,z);
% % each value from TR corresponds to a triangle
% required_edges_lines = featureEdges(TR,pi/11)';
% required_edges_vertices=unique(required_edges_lines(:));
% required_edges_faces=logical(zeros([size(mesh.f,1) 1]));
% tic
% for i=1:length(required_edges_vertices)
%     founded_faces=find(sum(mesh.f==required_edges_vertices(i),2));
%     required_edges_faces(founded_faces)=1;
% end
% required_edges_faces=find(required_edges_faces);
% toc
[required_edges_faces,required_edges_vertices]=get_faces_on_hard_edges(mesh.f,mesh.v,15);
mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
% [mesh.f,mesh.v,num_new_faces,required_edges_vertices,max_face_area]=refine_mesh(mesh.f, mesh.v,-1,required_edges_faces,0.5,required_edges_vertices);
% 
% mesh.f_lum=zeros([size(mesh.f,1) 1]);
% mesh.f_lum((end-num_new_faces+1):end)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
% 
% num_faces=size(mesh.f,1);
% required_edges_faces=false([num_faces 1]);
% mesh_faces=mesh.f;
% while(1)
%     [~,ind]=intersect(mesh_faces,required_edges_vertices);
%     if(isempty(ind))
%         break;
%     end    
% ind1=rem(ind,num_faces);
% ind1(ind==num_faces)=num_faces;
% mesh_faces(ind1,:)=0;
% required_edges_faces(ind1)=1;
% end
% required_edges_faces=find(required_edges_faces);
% mesh.f_lum=zeros([size(mesh.f,1) 1]);
% mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
d=[];
% required_edges_faces=false([size(mesh.f,1) 1]);
% for i=1:length(required_edges_vertices)
%     founded_faces=find(sum(mesh.f==required_edges_vertices(i),2));
%     required_edges_faces(founded_faces)=1;
% end
% required_edges_faces=find(required_edges_faces);

% required_edges_faces=get_faces_on_hard_edges(mesh.f,mesh.v,4);


% [mesh.f,mesh.v]=refine_mesh(mesh.f,mesh.v,max_face_area);
% mesh.normals = meshFaceNormals(mesh.v,mesh.f);
% mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
t = opcodemesh((mesh.v)',(mesh.f)');
mesh.centroids = meshFaceCentroids(mesh.v,mesh.f);
mesh.normals = meshFaceNormals(mesh.v,mesh.f);
region_frames=mesh.region_frames;
try
    delete('meshplus_lum.mat');
    load('meshplus_lum.mat');
catch
    mesh.f_lum=zeros([size(mesh.f,1) 1]);
    tic
    for fff=1:length(region_frames)
        i=region_frames(fff);
        image_name=sprintf('frame-%06d.color.jpg',i);
        image_path=[scene_name,'/frame/',image_name];
        objects_mask_path=[scene_name,'/masks/',image_name(1:end-3),'png'];
        faces_mask_path=[scene_name,'/faces_masks/',image_name(1:end-3),'png'];
        objects_numbers_path=[scene_name,'/masks/',image_name(1:end-3),'txt'];
        %%
%         [faces_image,~,trans]=imread(faces_mask_path);
%         r=faces_image(:,:,1);
%         g=faces_image(:,:,2);
%         b=faces_image(:,:,3);
%         A=double([trans(:),r(:),g(:),b(:)]);
%         faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
%         faces_numbers=faces_numbers+1;
%         faces_numbers(faces_numbers>(end_of_faces_indexing-1))=-1;
%         faces_numbers=faces_numbers-start_of_faces_indexing;
%         faces_numbers(faces_numbers<1)=1;
%         % faces_numbers(faces_numbers>number_of_faces)=number_of_faces+1;
%         image_normals=reshape(mesh.normals(faces_numbers,:),[1024,1280,3]);
%         [azimuth,elevation,~]=cart2sph(image_normals(:,:,1),image_normals(:,:,2),image_normals(:,:,3));
        
%         fileID = fopen(objects_numbers_path,'r');
%         existed_objects = fscanf(fileID,'%i');
        image=imread(image_path);
        
        
        M1=max(image,[],3);
        M1 = imbilatfilt(M1);
%         M1=Y;
        % I = im2double(M1);
        
        % Set patch size and number of iterations (listed in the image name)
        k = 7;
        iter = 5;
        
        % Apply the bilateral texture filter
        % M11 = bilateralTextureFilter(I, k, iter);
        
        
        % multi-thresh way of segmentation
%         threshRGB = multithresh(Y,20);
%         quantRGB = imquantize(Y, threshRGB);
%         Y_eq=histeq(uint8(quantRGB));
%         levels=unique(Y_eq);
%         regions_image=double(zeros(size(Y)));
%         total_num_objects=0;
%         for level_ind=1:length(levels)
%             [labels,num_obj]=bwlabel(Y_eq==levels(level_ind));
%             labels(labels>0)=labels(labels>0)+total_num_objects;
%             regions_image(labels>0)=labels(labels>0);
%             total_num_objects=total_num_objects+num_obj;
%         end
        
        [GmagY, ~] = imgradient(M1,'roberts');
%         figure;subplot(1,3,1);imshow((GmagY>7));
%         norm_GmagY=GmagY/max(max(GmagY));
%         norm_azimuth=(azimuth+3.14)/(2*3.14);
        % figure;imshow(uint8(norm_azimuth*255))
%         [Gmagaz, ~] = imgradient(norm_azimuth,'roberts');
        % norm_Gmagaz=Gmagaz/max(max(Gmagaz));
        % figure;imshow(uint8(norm_Gmagaz*255))
        % figure;imshow(Gmagaz)
%         subplot(1,3,2);imshow(Gmagaz>0.2)
%         norm_Gmagaz=Gmagaz/max(max(Gmagaz));
%         norm_elevation=(elevation+1.5707)/(2*1.5707);
        % figure;imshow(uint8(norm_elevation*255))
%         [Gmagev, ~] = imgradient(norm_elevation,'roberts');
%         norm_Gmagev=Gmagev/max(max(Gmagev));
        % figure;imshow(uint8(norm_Gmagev*255))
%         subplot(1,3,3);imshow(Gmagev>0.02);
%         figure;imshow(GmagY>7|Gmagev>0.02|Gmagaz>0.2)
%         figure;imshow(uint8(GmagY)>10)
%         figure;imshow(uint8(GmagY))
%         merged_borders=GmagY>7|Gmagaz>0.02|Gmagev>0.02;
%         merged_borders=uint8(GmagY)>10|Gmagaz>0.2|Gmagev>0.02;
        merged_borders=uint8(GmagY)>10;
        merged_borders(:,[1:5,end-4:end])=0;
        merged_borders([1:5,end-4:end],:)=0;
        imwrite([merged_borders],['output_figures/',image_name]);
        
        hitted_mesh_pixels=[];
        [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(merged_borders));
        [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
        temp_index=ones([size(rays_directions,2),1])*i+1;
        [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
        border_faces=unique(idxx);
        border_faces(border_faces==0)=[];
        ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(border_faces, :), mesh.normals(border_faces, :));
        border_faces(ind22)=[];
        distance_to_camera=vecnorm((mesh.centroids(border_faces, :)-mesh.campos(i+1, :))',1);
        border_faces(distance_to_camera>5)=[];
        mesh.f_lum(border_faces)=255;
%         label_image =~merged_borders;
%         hitted_mesh_pixels=[];
%         %             hitted_mesh_pixels_indexed=[];
%         hitted_mesh_pixels_indexed=find(label_image);
%         [hitted_mesh_pixels(2,:), hitted_mesh_pixels(1,:)]=ind2sub([image_height image_width],find(label_image));
%         [rays_directions,~]=get_ray_direction(mesh.pose(i+1).pose_matrix,mesh.intrinsics,hitted_mesh_pixels);
%         temp_index=ones([size(rays_directions,2),1])*i+1;
%         [~,~,idxx,~,~] = t.intersect(mesh.campos(temp_index,:)',rays_directions);
%         hitted_mesh_pixels_indexed(idxx==0)=[];
%         idxx(idxx==0)=[];
%         ind22 = ~isFacing(mesh.campos(i+1, :), mesh.camdir(i+1, :), mesh.centroids(idxx, :), mesh.normals(idxx, :));
%         hitted_mesh_pixels_indexed(ind22)=[];
%         idxx(ind22)=[];
%         unique_of_repeated_faces=unique(idxx);
%         average_color=[];
%         parfor rep_f_index=1:length(unique_of_repeated_faces)
%             average_color(rep_f_index)=mean(M1(hitted_mesh_pixels_indexed(idxx==unique_of_repeated_faces(rep_f_index))));
%         end
%         mesh.f_lum(unique_of_repeated_faces)=max(mesh.f_lum(unique_of_repeated_faces),average_color');
%         mesh.f_lum(border_faces)=0;
        
        
    end
%     save('meshplus_lum_smoothed.mat');
end

% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
mesh.f_lum(required_edges_faces)=255;
% figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);

% next three lines we remove faces corresponding to edges
detected_edge_faces_using_images=sum((mesh.f_lum>0),2)>0;
mesh.v=[mesh.v;min(mesh.v)-0.00001];
mesh.f(detected_edge_faces_using_images,:)=size( mesh.v,1);

fullpatch.vertices=mesh.v;
fullpatch.faces=mesh.f;
[~,fSets] = splitFV(fullpatch);

color_val = distinguishable_colors(max(fSets));
% color_val=histeq(color_val);
mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.f_lum=[mesh.f_lum(:),mesh.f_lum(:),mesh.f_lum(:)];
regions_edge_faces={};
region_index=1;
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
    for j = 1:nFaces
        f = faces(j, :);
        edges(((j-1)*nVF+1):j*nVF, :) = [f' f([2:end 1])'];
        edge_face_index(((j-1)*nVF+1):j*nVF)=faces_indexes(j);
    end
    [sorted_edges,~]=sort(edges, 2);
    [~,~,index_of_sorted_edges_in_uniques]=unique(sorted_edges,'rows','stable');
%     try
%         occurence_of_edges=sum(index_of_sorted_edges_in_uniques==index_of_sorted_edges_in_uniques');
%     catch
        occurence_of_edges = zeros(size(index_of_sorted_edges_in_uniques));
        for k = 1:length(index_of_sorted_edges_in_uniques)
            occurence_of_edges(k) = sum(index_of_sorted_edges_in_uniques==index_of_sorted_edges_in_uniques(k));
        end
%     end

    single_occured_edges=occurence_of_edges==1;
    edge_face_index=unique(edge_face_index(single_occured_edges));
    if(length(edge_face_index)>1)
    regions_edge_faces(region_index)={edge_face_index};
    region_index=region_index+1;
    C = repmat([ 255 255 0],[length(edge_face_index) 1]);
    mesh.f_lum(edge_face_index,:)=C;
    end
    
end
time_to_find_border_faces=toc

figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
figure,plot_CAD(mesh.f, mesh.v, '',mesh.f_lum);
tic
other_regions_faces_back=cell2mat(regions_edge_faces(:));
for i=1:length(regions_edge_faces)
    other_regions_faces=other_regions_faces_back;
    others_indexes=1:length(regions_edge_faces);
    current_region_faces=cell2mat(regions_edge_faces(i));
    others_indexes(i)=[];
    [~,idxs]=intersect(other_regions_faces,current_region_faces,'stable');
    other_regions_faces(idxs)=[];
    current_region_faces_centers=mesh.centroids(current_region_faces,:);
    other_region_faces_centers=mesh.centroids(other_regions_faces,:);
    for j=1:length(current_region_faces)
        distances=sum((current_region_faces_centers(j,:)-other_region_faces_centers).^2,2);
        ind22 = ~isFacing(current_region_faces_centers(j,:), mesh.normals(current_region_faces(j),:), other_region_faces_centers, mesh.normals(other_regions_faces, :));
%         I want to add a condition here to skip these faces which is falling on the same plane with current vertex from excluding
        distances(ind22)=max(distances)+1;
        [dist,other_face_index_in_distances]=min(distances);
        if(dist<0.03)
        other_face_index_in_mesh=other_regions_faces(other_face_index_in_distances);
        temp=([current_region_faces_centers(j,:);mesh.centroids(other_face_index_in_mesh,:)]);
        plot3(temp(:,1),temp(:,2),temp(:,3),'y')
        end
    end
end
time_to_plot_lines=toc

    colours = lines(length(splitpatch));
    subplot(2,1,2), hold on, title('Split mesh');
    for i=1:length(splitpatch)
        patch(splitpatch(i),'facecolor',colours(i,:));
    end
    
    

    
    
% detected_edge_faces_using_images=sum((mesh.f_lum>0),2)>0;
% [mesh.f,mesh.v,num_new_faces_using_images,~,~]=refine_mesh(mesh.f, mesh.v,max_face_area,detected_edge_faces_using_images);

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

