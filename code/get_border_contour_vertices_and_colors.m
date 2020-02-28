function [vertices_on_border_new, vertices_colors_new,groups_of_vertices,vertices_coordinates_on_border]=get_border_contour_vertices_and_colors(border_line_of_texture,current_frame,vertices_frame)
vertices_on_border_new=[];
vertices_coordinates_on_border=[];
vertices_colors_new=[];
groups_of_vertices=0;
while(1)
    [rb,cb]=find(border_line_of_texture,1);
    if isempty(rb)
        break;
    end
    try
    border_contour = bwtraceboundary(border_line_of_texture,[rb cb],'E');
    catch
        border_line_of_texture(rb,cb)=0;
%         a='continue'
        continue;
        
    end
    [height,width,~]=size(current_frame);
    border_indexes=sub2ind([height,width],border_contour(:,1),border_contour(:,2));
    vertices_on_border=vertices_frame(border_indexes);
    border_line_of_texture(border_indexes)=0;
    existed_vertices_flag=vertices_on_border>0;
    border_contour=border_contour(existed_vertices_flag,:);
    existed_vertices_value=vertices_on_border(existed_vertices_flag);
    existed_vertices_indexes=find(existed_vertices_flag);
    start=1;
    if(length(existed_vertices_value)<2)
        continue;
    end
    vertex(length(existed_vertices_value)).value=[];
    vertex(length(existed_vertices_value)).pre=[];
    vertex(length(existed_vertices_value)).post=[];
    for i=1:length(existed_vertices_value)-1
        vertex(i).value=existed_vertices_value(i);
        vertex(i).pre=[start:existed_vertices_indexes(i)];
        vertex(i).post=[existed_vertices_indexes(i):existed_vertices_indexes(i+1)];
        start=existed_vertices_indexes(i);
    end
    %% last element;
    i=i+1;
    vertex(i).value=existed_vertices_value(i);
    vertex(i).pre=[start:existed_vertices_indexes(i)];
    vertex(i).post=[existed_vertices_indexes(i):length(existed_vertices_flag), 1:existed_vertices_indexes(1)];
    vertex(1).pre=[existed_vertices_indexes(end):length(existed_vertices_flag),vertex(1).pre];
    
    current_red=current_frame(:,:,1);current_green=current_frame(:,:,2);current_blue=current_frame(:,:,3);
    vertices_colors=zeros(length(existed_vertices_value),3);
    for i=1:length(existed_vertices_value)
%         if i==25
%             d=[];
%         end
        vertex(i).pre=border_indexes(vertex(i).pre);
        vertex(i).post=border_indexes(vertex(i).post);
        vertex(i).pre_weights=(0:(length(vertex(i).pre)-1))/(length(vertex(i).pre)-1);
        vertex(i).post_weights=(0:(length(vertex(i).post)-1))/(length(vertex(i).post)-1);
        % next two lines to not repeat our vertex main value twice in pre and post,
        % so we removed it from pre.
        vertex(i).pre(end)=[];
        vertex(i).pre_weights(end)=[];
        
        red_pre=sum(double(current_red(vertex(i).pre)).*(vertex(i).pre_weights)');
        green_pre=sum(double(current_green(vertex(i).pre)).*(vertex(i).pre_weights)');
        blue_pre=sum(double(current_blue(vertex(i).pre)).*(vertex(i).pre_weights)');
        
        red_post=sum(double(current_red(vertex(i).post)).*(vertex(i).post_weights)');
        green_post=sum(double(current_green(vertex(i).post)).*(vertex(i).post_weights)');
        blue_post=sum(double(current_blue(vertex(i).post)).*(vertex(i).post_weights)');
        
        red=(red_pre+red_post)/sum([vertex(i).pre_weights,vertex(i).post_weights]);
        green=(green_pre+green_post)/sum([vertex(i).pre_weights,vertex(i).post_weights]);
        blue=(blue_pre+blue_post)/sum([vertex(i).pre_weights,vertex(i).post_weights]);
        vertices_colors(i,[1,2,3])=[red,green,blue];
    end
    groups_of_vertices=[groups_of_vertices;(groups_of_vertices(end)+length(existed_vertices_value))];
    vertices_on_border_new=[vertices_on_border_new;existed_vertices_value];
    vertices_coordinates_on_border=[vertices_coordinates_on_border;border_contour];
    vertices_colors_new=[vertices_colors_new;vertices_colors];
   
end