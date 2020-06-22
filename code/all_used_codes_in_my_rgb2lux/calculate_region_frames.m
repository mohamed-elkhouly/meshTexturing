function [mesh,region_frames]=calculate_region_frames(mesh,folder_path,region_frames,region_number)
regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end

end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;% -1 to go down to the last face number in the last region,+1 to use faces numbers as indexes in matlab

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
    mesh.specularities_in_frame(:)=[];