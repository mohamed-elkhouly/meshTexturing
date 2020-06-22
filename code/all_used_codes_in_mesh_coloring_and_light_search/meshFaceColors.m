function colors = meshFaceColors(nodes, faces)


v1 = nodes(faces(:,1),1:3);
v2 = nodes(faces(:,2),1:3);
v3 = nodes(faces(:,3),1:3);
colors=(v1+v2+v3)/3;