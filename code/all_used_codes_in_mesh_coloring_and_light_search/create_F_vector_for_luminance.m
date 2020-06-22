function [F,luminance]=create_F_vector_for_luminance(faces_correspondences1,faces_colors)

luminance=max(faces_colors,[],2);
F=double(luminance(faces_correspondences1(:,1)))-double(luminance(faces_correspondences1(:,2)));
