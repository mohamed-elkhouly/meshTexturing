function combiner=find_related2(intersected_holes,intersections,intersections1,intersections2,exclutions,intersections_threshold,angle_between_normals,angle_thrsh,intersect_thrsh2)
combiner=[];
for i=1:length(intersected_holes)
    intersected_holes1=find(intersections1(intersected_holes(1),:)>intersections_threshold);
intersected_holes2=find(intersections2(intersected_holes(1),:)>intersections_threshold);
 new_intersected_holes=intersect(intersected_holes1,intersected_holes2,'stable');
 new_intersected_holes=unique([new_intersected_holes,find(intersections1(intersected_holes(1),:)>intersect_thrsh2),find(intersections2(intersected_holes(1),:)>intersect_thrsh2)]);
 current_angles=angle_between_normals(intersected_holes1(1),new_intersected_holes);
 new_intersected_holes=new_intersected_holes(current_angles<angle_thrsh);
%     new_intersected_holes=find(intersections(intersected_holes(i),:)>intersections_threshold);
    combiner=[combiner;new_intersected_holes(:)];
end
combiner=unique(combiner);
for i=1:length(exclutions)
    combiner(combiner==exclutions(i))=[];
end