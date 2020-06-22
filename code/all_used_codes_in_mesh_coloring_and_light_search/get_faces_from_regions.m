function [excluded_faces,excluded_regions]=get_faces_from_regions(current_regions,faces_regions_mapping,excluded_faces,excluded_regions)

for i=1:length(current_regions)
    existed_in_faces=find(sum(faces_regions_mapping==current_regions(i),2));
%     for k=1:length(exclutions)
[~,inds]=intersect(existed_in_faces,excluded_faces,'stable');
        existed_in_faces(inds)=[];
%     end
    excluded_faces=[excluded_faces;existed_in_faces(:)];
    
    for j=1:length(existed_in_faces)
        current_face_regions=faces_regions_mapping(existed_in_faces(j),2:end);
     current_face_regions(current_face_regions==0)=[];
     [~,inds]=intersect(current_face_regions,excluded_regions(:),'stable');
        current_face_regions(inds)=[];
        if(~isempty(current_face_regions))
    excluded_regions=[excluded_regions;current_face_regions(:)];
     [current_face_faces,current_face_regions]=get_faces_from_regions(current_face_regions,faces_regions_mapping,excluded_faces,excluded_regions);
     excluded_regions=unique([excluded_regions;current_face_regions(:)]);
     excluded_faces=unique([excluded_faces;current_face_faces(:)]);
     excluded_faces=excluded_faces(:);
        end
    end
end



