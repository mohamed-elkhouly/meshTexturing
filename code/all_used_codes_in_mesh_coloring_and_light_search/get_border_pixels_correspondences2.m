function final_required_matrix=get_border_pixels_correspondences2(border_Labels,max_pix_distance)
% max_pix_distance=3;
% border_Labels=border_Labels(1:50,1:50);
temp_var=[(1:2:(max_pix_distance+1)*2).^2];
number_of_columns=temp_var(max_pix_distance+1)-temp_var(max_pix_distance);
max_dimention_index=ones(max_pix_distance,1);
dim_index=ones(max_pix_distance,1);
correspondences=zeros(size(border_Labels,1)*size(border_Labels,2),number_of_columns);
indexes_tracks=zeros(size(border_Labels,1)*size(border_Labels,2),number_of_columns);
indexes_matrix=reshape(1:size(border_Labels,1)*size(border_Labels,2),size(border_Labels));
right=max_pix_distance;
up=max_pix_distance;
down=max_pix_distance;
left=max_pix_distance;
for i=1:right
    TR=border_Labels;RI=indexes_matrix;
    TR=circshift(TR,i,2);RI=circshift(RI,i,2);
    TR(:,1:i)=0;RI(:,1:i)=0;
    if(i==max_pix_distance)
    [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,i,TR);
    [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,i,RI);
    end
    for j=1:up
        if(max(i,j)==max_pix_distance)
        TRU=TR;RUI=RI;
        TRU=circshift(TRU,-1*j,1);RUI=circshift(RUI,-1*j,1);
        TRU(end-j+1:end,:)=0;RUI(end-j+1:end,:)=0;
        [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,max(i,j),TRU);
        [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,max(i,j),RUI);
        end
    end
    for k=1:down
        if(max(i,k)==max_pix_distance)
        TRD=TR;RDI=RI;
        TRD=circshift(TRD,k,1);RDI=circshift(RDI,k,1);
        TRD(1:k,:)=0;RDI(1:k,:)=0;
        [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,max(i,k),TRD);
        [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,max(i,k),RDI);
        end
    end
end
for j=1:up
    if(j==max_pix_distance)
    TU=border_Labels;UI=indexes_matrix;
    TU=circshift(TU,-1*j,1);UI=circshift(UI,-1*j,1);
    TU(end-j+1:end,:)=0;UI(end-j+1:end,:)=0;
    [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,j,TU);
    [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,j,UI);
    end
end
for k=1:down
    if(k==max_pix_distance)
    TD=border_Labels;DI=indexes_matrix;
    TD=circshift(TD,k,1);DI=circshift(DI,k,1);
    TD(1:k,:)=0;DI(1:k,:)=0;
    [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,k,TD);
    [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,k,DI);
    end
end
for i=1:left
    TR=border_Labels;RI=indexes_matrix;
    TR=circshift(TR,-i,2);RI=circshift(RI,-i,2);
    TR(:,end-i+1:end)=0;RI(:,end-i+1:end)=0;  
    if(i==max_pix_distance)
    [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,i,TR);
    [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,i,RI);
    end
    for j=1:up
        if(max(i,j)==max_pix_distance)
        TRU=TR;RUI=RI;
        TRU=circshift(TRU,-1*j,1);RUI=circshift(RUI,-1*j,1);
        TRU(end-j+1:end,:)=0;RUI(end-j+1:end,:)=0;
        [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,max(i,j),TRU);
        [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,max(i,j),RUI);
        end
    end
    for k=1:down
        if(max(i,k)==max_pix_distance)
        TRD=TR;RDI=RI;
        TRD=circshift(TRD,k,1);RDI=circshift(RDI,k,1);
        TRD(1:k,:)=0;RDI(1:k,:)=0;
        [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,max(i,k),TRD);
        [indexes_tracks,dim_index]=add_to_big_matrix(indexes_tracks,dim_index,max(i,k),RDI);
        end
    end 
end
    
border_pixels_correspondences=correspondences;
border_pixels_indexes=indexes_tracks;
% for i=2:max_pix_distance
%     border_pixels_correspondences = [border_pixels_correspondences,correspondences(:,:,i)];
%     border_pixels_indexes = [border_pixels_indexes,indexes_tracks(:,:,i)];
% end
border_pixels_correspondences(border_pixels_correspondences==border_Labels(:))=0;
[~, B] = max(border_pixels_correspondences>0,[],2);
temp_inds=sub2ind(size(border_pixels_indexes),(1:length(B))',B);
other_group_pixel_index=border_pixels_indexes(temp_inds);
current_group_pixel_index=(1:size(other_group_pixel_index,1))';
other_group_number=zeros(size(other_group_pixel_index,1),1);
other_group_number(other_group_pixel_index>0)=border_Labels(other_group_pixel_index(other_group_pixel_index>0));
current_group_number=border_Labels(current_group_pixel_index);

final_required_matrix=[current_group_number,other_group_number,current_group_pixel_index,other_group_pixel_index];
to_be_removed=sum(final_required_matrix==0,2)>0;
final_required_matrix(to_be_removed,:)=[];

d=[];



function [correspondences,max_dimention_index]=add_to_big_matrix(correspondences,max_dimention_index,index,to_be_placed)

correspondences(:,max_dimention_index(index))=to_be_placed(:);
max_dimention_index(index)=max_dimention_index(index)+1;
d=[];