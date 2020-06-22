function [mesh,region_faces,all_used_groups_faces,regions_edge_faces,num_faces_in_region]=find_border_faces_of_mesh(mesh,fSets)

color_val = distinguishable_colors(max(fSets));
% color_val=histeq(color_val);
mesh.f_lum=zeros([size(mesh.f,1) 1]);
mesh.f_lum=[mesh.f_lum(:),mesh.f_lum(:),mesh.f_lum(:)];
regions_edge_faces={};
region_faces={};
region_index=1;
all_used_groups_faces=[];
tic
for i=1:max(fSets)
    %     faces=
%     if(sum(fSets==i)<50)
%         continue
%     end
    C = repmat(color_val(i,:),[sum(fSets==i) 1]);
    mesh.f_lum(fSets==i,:)=C;
    
    faces_indexes=find(fSets==i);
    faces=mesh.f(faces_indexes,:);
    % compute total number of edges
    nFaces  = size(faces, 1);
    nVF     = size(faces, 2);
    nEdges  = nFaces * nVF;
    
    % create all edges (with double ones)
    edges = zeros(nEdges, 2);
    edge_face_index=zeros([nEdges,1]);
    j=(1:nFaces)';
    ff=faces(j, :);
    ff2=([ff(:,2),ff(:,3),ff(:,1)])';
    ff=ff';
    edges=[ff(:), ff2(:)];
    edge_face_index=([j,j,j])';
    edge_face_index=faces_indexes(edge_face_index(:));
    [sorted_edges,~]=sort(edges, 2);
    [~,~,index_of_sorted_edges_in_uniques]=unique(sorted_edges,'rows','stable');
    div_val=1;
    %     tic
    while(1)
        try
            occurence_of_edges=sum(index_of_sorted_edges_in_uniques(1:ceil(length(index_of_sorted_edges_in_uniques)/div_val))==index_of_sorted_edges_in_uniques');
            break;
        catch
            div_val=div_val+2;
        end
    end
    if (sum(occurence_of_edges<2)<1)
        continue;
    end
    len_val=ceil(length(index_of_sorted_edges_in_uniques)/div_val);
    for k=2:div_val-1
        occurence_of_edges=occurence_of_edges+sum(index_of_sorted_edges_in_uniques((k-1)*len_val+1:(k)*len_val)==index_of_sorted_edges_in_uniques');
        if (sum(occurence_of_edges<2)<1)
            continue;
        end
    end
    if(div_val>1)
        occurence_of_edges=occurence_of_edges+sum(index_of_sorted_edges_in_uniques((div_val-1)*len_val+1:end)==index_of_sorted_edges_in_uniques');
    end
    
    single_occured_edges=occurence_of_edges==1;
    edge_face_index=unique(edge_face_index(single_occured_edges));
    if(length(edge_face_index)>1)
        region_faces(region_index)={faces_indexes};
        num_faces_in_region(region_index)=length(faces_indexes);
        temp_appeared_group_faces=[faces_indexes,ones([size(faces_indexes,1),1])*region_index];
    all_used_groups_faces=[all_used_groups_faces;temp_appeared_group_faces];
        regions_edge_faces(region_index)={edge_face_index};
        region_index=region_index+1;
        C = repmat([ 255 255 0],[length(edge_face_index) 1]);
        mesh.f_lum(edge_face_index,:)=C;
        % filling the tempmesh_faces indexer
        detected_edge_faces_using_images1(edge_face_index)=1;
    end
end
time_to_find_border_faces=toc