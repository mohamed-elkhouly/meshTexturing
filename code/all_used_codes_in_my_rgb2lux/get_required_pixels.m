function required_pixels=get_required_pixels(show_annotated_light_sources_flag,show_auto_detected_light_sources_from_my_method_flag,scene_from_json,region_number,scene_name)
[sunlight_pixels, artificial_pixels, specular_pixels, skylight_pixels, auto_detected_light]=show_region(scene_from_json,region_number,[],scene_name);

required_pixels=specular_pixels;

if (show_annotated_light_sources_flag)
    max_second_dimention=max(max(size(sunlight_pixels,2),size(artificial_pixels,2)),size(skylight_pixels,2));
    required_for_sunlight=max_second_dimention-size(sunlight_pixels,2);
    required_for_artificial=max_second_dimention-size(artificial_pixels,2);
    required_for_skylight=max_second_dimention-size(skylight_pixels,2);
    sunlight_pixels=[sunlight_pixels,zeros([size(sunlight_pixels,1),required_for_sunlight])];
    artificial_pixels=[artificial_pixels,zeros([size(artificial_pixels,1),required_for_artificial])];
    skylight_pixels=[skylight_pixels,zeros([size(skylight_pixels,1),required_for_skylight])];
    % the next line if you want to show all annotated light sources.
    required_pixels=[sunlight_pixels;artificial_pixels;skylight_pixels];
end
if(show_auto_detected_light_sources_from_my_method_flag)
    % the next line for my auto detected_light source.
    required_pixels=auto_detected_light;
end