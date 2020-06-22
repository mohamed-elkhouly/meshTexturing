function founded_faces=find_connected_faces(mesh,b,max_num_faces_for_groups,all_vertices_in_all_faces,founded_before,i,current_face_vertices)
                 faces_groups=[];
                 faces_groups_index=1;
                     
%                      all_vertices_in_all_faces(i,:)=0;
                        all_found=zeros([length(all_vertices_in_all_faces),1]);
                     for kkk=1:length(current_face_vertices)
                          all_found = sum([all_found,sum(all_vertices_in_all_faces==current_face_vertices(kkk),2)],2);
                     end
%                      all_found = sum([sum(all_vertices_in_all_faces==current_face_vertices(1),2),sum(all_vertices_in_all_faces==current_face_vertices(2),2),sum(all_vertices_in_all_faces==current_face_vertices(3),2)],2);
                     founded_faces=find(all_found>0);
                     for j=1:length(founded_faces)
                         if(sum(founded_before==founded_faces(j))>0)
                           founded_faces(j)=0  ;
                         end
                        
                     end
                     founded_faces(founded_faces==0)=[]  ;
%                      if (~isempty(founded_before))
%                         founded_faces=[i;founded_faces];
%                      end
%                      current_vertices=all_vertices_in_all_faces(i,:);
                     if(length(founded_faces)>0)
%                          founded_faces(1)=[];
                         founded_faces2=[];
                         next_faces_vertices=all_vertices_in_all_faces(founded_faces,:);
                         next_faces_vertices=next_faces_vertices(:);
                         all_vertices_in_all_faces(i,:)=0;
                         all_vertices_in_all_faces(founded_faces,:)=0;
                         founded_faces2=[founded_faces2;find_connected_faces(mesh,b,max_num_faces_for_groups,all_vertices_in_all_faces,[founded_faces;founded_before;i],founded_faces,next_faces_vertices)];
                        founded_faces=[founded_faces;founded_faces2];
                        d=[];
                     else
                         d=[];
%                          founded_faces=[]
%                          faces_groups(faces_groups_index).faces=b(i);
%                          faces_groups(faces_groups_index).faces_number=1;
%                          faces_groups(faces_groups_index).faces_area=mesh.areas(b(i));
                     end