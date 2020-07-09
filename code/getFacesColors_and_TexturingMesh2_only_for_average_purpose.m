function  [faces_colors]=getFacesColors_and_TexturingMesh2_only_for_average_purpose(mesh)
% if(using_different_mesh)
%     region_frames=region_frames(:);
% end
warning ('off','all');
[faces_colors]=computeForVisibleFaces2_only_for_average_purpose(mesh);% THIS ONE CALCULATE AVERAGE COLORS
