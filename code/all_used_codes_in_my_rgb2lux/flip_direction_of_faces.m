function faces=flip_direction_of_faces(faces)
temp=faces(:,1);
faces(:,1)=faces(:,3);
faces(:,3)=temp;