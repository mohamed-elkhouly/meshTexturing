function mesh=get_specular_faces_v_0_1(mesh,folder_path,region_number)

write_flag=0;

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0)
    start_of_faces_indexing=0;
else
    start_of_faces_indexing=faces_count_per_regions(region_number);
end
end_of_faces_indexing=faces_count_per_regions(region_number+1)-1;
region_frames=[];
for i=1:size(mesh.campos,1)
    frame_number= sprintf( '%06d', i-1 ) ;
    file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
    [faces_image,~,trans]=imread(file_path);
    r=faces_image(:,:,1);
    g=faces_image(:,:,2);
    b=faces_image(:,:,3);
    A=double([trans(:),r(:),g(:),b(:)]);
    faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
    faces_numbers(faces_numbers>4294967294)=[];
    faces_numbers=unique(faces_numbers);
    faces_numbers(faces_numbers>end_of_faces_indexing)=[];% remove faces of the higher regions
    faces_numbers=faces_numbers-start_of_faces_indexing;
    faces_numbers(faces_numbers<0)=[];% remove faces of the lower regions
    mesh.specularities_in_frame(i).faces_numbers=faces_numbers;
    if(~isempty(faces_numbers))
        region_frames=[region_frames;[i-1, length(faces_numbers)]];
    end
end
mesh.region_frames=region_frames;



mesh.specularities_in_frame(:)=[];
mkdir([folder_path,'/regions'])
mkdir([folder_path,'/regions/region',num2str(region_number)])
region_specular_frames=[];
max_num_specular_faces=0;
for i=1:size(region_frames,1)
    if(region_frames(i,2)>1000)
        frame_number= sprintf( '%06d', region_frames(i,1)) ;
        file_path=[folder_path,'/frame/','frame-',frame_number,'.color.jpg'];
        image=imread(file_path);
        if(write_flag==1)
            imwrite(image,[folder_path,'/regions/region',num2str(region_number),'/frame-',frame_number,'.color.jpg']);
        else
            specular_image=imread([folder_path,'/regions/region',num2str(region_number),'/masks/frame-',frame_number,'.color_m.jpg']);
            if(sum(sum(specular_image))==0)
                continue
            else
                region_specular_frames=[region_specular_frames;region_frames(i,1)];
                file_path=[folder_path,'/frames_faces_mapping/','frame-',frame_number,'.color.png'];
                [faces_image,~,trans]=imread(file_path);
                r=faces_image(:,:,1);
                g=faces_image(:,:,2);
                b=faces_image(:,:,3);
                A=double([trans(:),r(:),g(:),b(:)]);
                faces_numbers=A(:,4)*(256^3) + A(:,3)*(256^2) + A(:,2)*256 + A(:,1);
                faces_numbers=faces_numbers(specular_image(:)>0);
                faces_numbers(faces_numbers>4294967294)=[];
                faces_numbers=unique(faces_numbers);
                faces_numbers(faces_numbers>end_of_faces_indexing)=[];% remove faces of the higher regions
                faces_numbers=faces_numbers-start_of_faces_indexing;
                faces_numbers(faces_numbers<0)=[];% remove faces of the lower regions
                mesh.specularities_in_frame(region_frames(i,1)).faces_numbers=faces_numbers+1;
                if (length(faces_numbers)>max_num_specular_faces)
                    max_num_specular_faces=length(faces_numbers);
                end
            end
        end
    end
end
mesh.region_specular_frames=region_specular_frames;
mesh.max_num_specular_faces=max_num_specular_faces;
d=[];