function [vertices_on_border_new, vertices_colors_new,groups_of_vertices,vertices_coordinates_on_border,nearest_vertices]=get_border_contour_vertices_and_colors_v2(border_line_of_texture,current_frame,vertices_frame)
vertices_on_border_new=[];
vertices_coordinates_on_border=[];
vertices_colors_new=[];
groups_of_vertices=0;
[border_contour(:,1), border_contour(:,2)]=find(border_line_of_texture);
[height,width,~]=size(current_frame);
border_indexes=sub2ind([height,width],border_contour(:,1),border_contour(:,2));
vertices_on_border=vertices_frame(border_indexes);
existed_vertices_flag=vertices_on_border>0;
border_contour=border_contour(existed_vertices_flag,:);
existed_vertices_value=vertices_on_border(existed_vertices_flag);
final_border_indexes=border_indexes(existed_vertices_flag);
current_red=current_frame(:,:,1);current_green=current_frame(:,:,2);current_blue=current_frame(:,:,3);

current_red=current_red(final_border_indexes);
current_green=current_green(final_border_indexes);
current_blue=current_blue(final_border_indexes);
vertices_colors_new=[current_red,current_green,current_blue];
vertices_on_border_new=existed_vertices_value;
groups_of_vertices=[groups_of_vertices;(groups_of_vertices(end)+length(existed_vertices_value))];
vertices_coordinates_on_border=border_contour;
nearest=zeros(size(border_contour,1),1);
for i=1:size(border_contour,1)
    subtraction=abs(sum(abs(border_contour-border_contour(i,:)),2));
    subtraction(i)=inf;
    [~,nearest(i)]=min(subtraction);
end
nearest_vertices=vertices_on_border_new(nearest);