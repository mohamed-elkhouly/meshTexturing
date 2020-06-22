function combiner=find_related(intersected_holes,intersections,exclutions,intersections_threshold)
combiner=[];
for i=1:length(intersected_holes)
    new_intersected_holes=find(intersections(intersected_holes(i),:)>intersections_threshold);
    combiner=[combiner;new_intersected_holes(:)];
end
combiner=unique(combiner);
for i=1:length(exclutions)
    combiner(combiner==exclutions(i))=[];
end