function process_groups_faces_from_different_images(mesh,faces_correspondences,region_faces,regions_edge_faces,all_used_groups_faces,region_frames,scene_name,folder_path,region_number)
% in this function we want to find the color for each face from all images.
% clear all
% addpath(genpath('D:/rgbd2lux_linux_19-7-2019/rgbd2lux_linux'));
save('required_for_process_groups_faces_from_different_images_region_21.mat');
% save('required_for_process_groups_faces_from_different_images_region_0_82se.mat');
% save('required_for_process_groups_faces_from_different_images_region_17.mat');
% save('required_for_process_groups_faces_from_different_images_region_26.mat');
% save('required_for_process_groups_faces_from_different_images_region_15.mat');
% save('required_for_process_groups_faces_from_different_images_region_0.mat');
% save('required_for_process_groups_faces_from_different_images_region_2.mat');
% load('required_for_process_groups_faces_from_different_images_region_21.mat');

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end

end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;% -1 to go down to the last face number in the last region,+1 to use faces numbers as indexes in matlab

visible_pixels_for_faces=zeros(size(all_used_groups_faces,1),150);
distance_visible_pixels_for_faces_from_camera=zeros(size(all_used_groups_faces,1),150);
groups_struct=[];
frames_groups_tracker=zeros(max(region_frames(:,1))+1,length(region_faces)+1);
for group_index=1:length(region_faces)
    groups(group_index).frames_index=[];
end
% bb=[];
% all_faces_numbers=[];
% all_faces_values=[];
% h = fspecial('average', 3);
tic
for index=1:size(region_frames,1)
    i=region_frames(index);
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
    back_back_idxx=[idxx,(1:length(idxx))'];
    back_idxx(idxx>end_of_faces_indexing,:)=[];
    idxx(idxx>end_of_faces_indexing)=[];
    
    back_idxx(idxx<=0,:)=[];
    idxx(idxx<=0)=[];
    [hitted_faces,~,indexes_of_faces_in_originals]=unique(idxx);
    [sorted_f,index_f]=sort(indexes_of_faces_in_originals);
    
    [~,faces_places_in_image,~]=unique(sorted_f);
    faces_places_in_image(length(hitted_faces)+1)=length(sorted_f)+1;
    
    [~,index_in_all_used_group_faces_1,index_in_hitted_faces_1]=intersect(all_used_groups_faces(:,1),hitted_faces);
    if(isempty(index_in_all_used_group_faces_1))
        continue;
    end
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
    if(isempty(index_in_all_used_group_faces_1))
        continue;
    end
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
    % tic
    values_from_face_pixels=zeros(size(hitted_faces_2));
    parfor ui=1:length(hitted_faces_2)
        m=index_in_hitted_faces_1(ui);
        if ui==length(hitted_faces_2)
            required_indexes_for_access_image=index_f(faces_places_in_image(m):end);
        else
            required_indexes_for_access_image=index_f(faces_places_in_image(m):faces_places_in_image(m+1)-1);
        end
        values_from_face_pixels(ui)=median(M1(all_indexes_in_idxx(required_indexes_for_access_image)));
    end
    %     toc
    visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=values_from_face_pixels;
    
    %      visible_pixels_for_faces(indexes_for_visible_pixels_for_faces)=M1(centers_indexes);
    visible_pixels_for_faces(index_in_all_used_group_faces_1,1)=visible_pixels_for_faces(index_in_all_used_group_faces_1,1)+1;
    %         aa=double(back_back_idxx(:,1));
    %         for oo=1:length(hitted_faces_2)
    %             aa(aa==hitted_faces_2(oo))=-1;
    %         end
    %         aa(aa~=-1)=0;
    %         aa(aa==-1)=255;
    %         aa=reshape(aa,[1024 1280]);
    %         imshow(uint8(aa))
    %         sum(sum(aa>0))
    %         figure;imshow(aa);
    
    % here I have to search for the groups of these faces and set the group
    % index for each set.
    for group_index=1:length(region_faces)
        current_group_faces=cell2mat(region_faces(group_index));
        [~,intersect_inds]=intersect(hitted_faces_2,current_group_faces);
        if(~isempty(intersect_inds))
            %             if(group_index==1)
            %                 bb=[bb;hitted_faces_2(intersect_inds);];
            %             end
            %             all_faces_numbers=[all_faces_numbers;hitted_faces_2(intersect_inds)];
            % all_faces_values=[all_faces_values;values_from_face_pixels(intersect_inds)];
            groups(group_index).frame(i+1).faces=hitted_faces_2(intersect_inds);
%             if(sum(hitted_faces_2(intersect_inds)==25522)>0)
%                 d=[];
%             end
            groups(group_index).frame(i+1).values=values_from_face_pixels(intersect_inds);
            groups(group_index).frames_index=[groups(group_index).frames_index;(i+1)];
            frames_groups_tracker(i+1,frames_groups_tracker(i+1,1)+2)=group_index;
            frames_groups_tracker(i+1,1)=frames_groups_tracker(i+1,1)+1;
        end
    end
end
time_to_get_faces_colors=toc

% for show only
% group_index=1;
% all_faces=[];
% fff=groups(group_index).frames_index;
% for qq=1:length(fff)
%     all_faces=[all_faces;groups(group_index).frame(fff(qq)).faces];
% end
% ss 

clear groups2;
for group_index=1:length(region_faces)
    
    groups2(group_index)=estimate_un_appeared_faces_values(groups(group_index),cell2mat(region_faces(group_index)),mesh);
%     next two lines for view purpose only 
    groups2(group_index).frame(888).faces=[];
    groups2(group_index).frame(888).values=[];
end

groups=groups2;
clear groups2;
%% here I will iterate through each frame alone to transfer the luminance between activated groups only in this frame.
for index=1:size(region_frames,1)
    i=region_frames(index);
    appeared_groups=frames_groups_tracker(i+1,2:frames_groups_tracker(i+1,1)+1);
    all_edge_faces=regions_edge_faces(appeared_groups);
    all_edge_faces=cell2mat(all_edge_faces(:));
    all_groups_faces=[];
    for k=1:length(appeared_groups)
        all_groups_faces=[all_groups_faces;groups(appeared_groups(k)).frame(i+1).faces];
    end
    [vals]=intersect(all_groups_faces,all_edge_faces);
    all_correspondences=[];
    for k=1:length(appeared_groups)
        group_correspondences=cell2mat(faces_correspondences(appeared_groups(k)));
        group_correspondences(:,3)=[];
        sss=logical(zeros(size(group_correspondences)));
        [~,inds]=intersect(group_correspondences,vals);
        sss(inds)=1;
        group_correspondences(sum(sss,2)<2,:)=[];
        all_correspondences=[all_correspondences;group_correspondences];
    end
    
    
    if(~isempty(all_correspondences))
        
        all_faces_numbers=[];
        all_faces_values=[];
        for group_index=1:length(appeared_groups)
            all_faces_numbers=[all_faces_numbers;groups(appeared_groups(group_index)).frame(i+1).faces];
            all_faces_values=[all_faces_values;groups(appeared_groups(group_index)).frame(i+1).values];
        end
        aaa=zeros(length(mesh.f),1);
        aaa(all_faces_numbers)=all_faces_values;
        figure,plot_CAD(mesh.f, mesh.v, '',aaa);
        delete(findall(gcf,'Type','light'));
        view=1;
        new_groups(index).groups=propagate_and_distribute_illumination(groups,all_correspondences,appeared_groups,faces_correspondences,i+1,mesh,view);
        
    end
    
end




% for viewing purpose
frame_num=416;%32,469,648,664,665
all_faces_numbers=[];
all_faces_values=[];
for group_index=1:length(region_faces)
    all_faces_numbers=[all_faces_numbers;groups(group_index).frame(frame_num).faces];
    all_faces_values=[all_faces_values;groups(group_index).frame(frame_num).values];

end
aaa=zeros(length(mesh.f),1);
aaa(all_faces_numbers)=all_faces_values;
figure,plot_CAD(mesh.f, mesh.v, '',aaa);
delete(findall(gcf,'Type','light'));
d=[];



aaa=zeros(length(mesh.f),1);
aaa(current_frame_appeared_faces)=255;
figure,plot_CAD(mesh.f, mesh.v, '',aaa);
delete(findall(gcf,'Type','light'));
























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% savefig(['illumination change with the increasing of distance for faces_region',num2str(region_number),scene_name,'.fig']);
temp=temp(:);
temp(temp==0)=[];
% histogram(temp)
figure;histogram(temp)
% savefig(['appeared_colors_histogram_in_faces_region',num2str(region_number),scene_name,'.fig']);