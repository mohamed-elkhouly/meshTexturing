function mesh=get_specular_faces_v_0_3(mesh,folder_path,region_number,scene_name) 

calculate_region_frames=0;
image_width=1280;image_height=1024;
write_flag=0;
%% if we want to have only the specularities make the next 3 flags zeros.
show_annotated_light_sources_flag=0;% if you activated this you have to deactivate the next flag they can not work together
show_auto_detected_light_sources_from_my_method_flag=0;% if you activated this you have to deactivate the last flag they can not work together
project_annotated_faces_to_image_again=0;

regions_info_path=[folder_path,'/regions_faces_numbers.csv'];%note that I padded 0 in the first cell of the csv file because the reader neglect the first cell
faces_count_per_regions=table2array(readtable(regions_info_path));
if (region_number==0);start_of_faces_indexing=0;
else ;start_of_faces_indexing=faces_count_per_regions(region_number); end

end_of_faces_indexing=faces_count_per_regions(region_number+1)-1+1;% -1 to go down to the last face number in the last region,+1 to use faces numbers as indexes in matlab
region_frames=[];

if(calculate_region_frames); [mesh,region_frames]=calculate_region_frames(mesh,folder_path,region_frames); end

mesh.region_frames=region_frames;

mkdir([folder_path,'/regions']); mkdir([folder_path,'/regions/region',num2str(region_number)]);

scene_from_json=read_annotated_json(scene_name);
%%
required_pixels=get_required_pixels(show_annotated_light_sources_flag,show_auto_detected_light_sources_from_my_method_flag,scene_from_json,region_number,scene_name);

%%
[mesh,global_hitted_faces,region_specular_frames,max_num_specular_faces,temp_faces_array]=get_required_faces(mesh,...
    required_pixels,folder_path,write_flag,region_number,end_of_faces_indexing,start_of_faces_indexing,image_width,...
    image_height,project_annotated_faces_to_image_again);
%%
if(project_annotated_faces_to_image_again)
    project_annotated_faces_to_image(mesh,project_annotated_faces_to_image_again,global_hitted_faces,required_pixels,folder_path,temp_faces_array,image_width,image_height);
end
%%
mesh.region_specular_frames=region_specular_frames;
mesh.max_num_specular_faces=max_num_specular_faces;
d=[];