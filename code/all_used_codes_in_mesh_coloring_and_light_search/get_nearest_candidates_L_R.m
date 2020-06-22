function [nearest_vertex_to_L,nearest_vertex_to_R]=get_nearest_candidates_L_R(ind_L,ind_R,current_vertices_groups,other_vertices_groups)

        if(ind_L==1)
            nearest_vertex_to_L=ind_L+1;
        elseif(ind_L==length(current_vertices_groups))
            nearest_vertex_to_L=ind_L-1;
        else
            nearest_vertex_to_L=[ind_L+1,ind_L-1];
        end
        candidates_L=current_vertices_groups(nearest_vertex_to_L);
        candidates_L=candidates_L==current_vertices_groups(ind_L);
        nearest_vertex_to_L=nearest_vertex_to_L(candidates_L);
        nearest_vertex_to_L=nearest_vertex_to_L(1);
        if(ind_R==1)
            nearest_vertex_to_R=ind_R+1;
        elseif(ind_R==length(other_vertices_groups))
            nearest_vertex_to_R=ind_R-1;
        else
            nearest_vertex_to_R=[ind_R+1,ind_R-1];
        end
        candidates_R=other_vertices_groups(nearest_vertex_to_R);
        candidates_R=candidates_R==other_vertices_groups(ind_R);
        nearest_vertex_to_R=nearest_vertex_to_R(candidates_R);
        nearest_vertex_to_R=nearest_vertex_to_R(1);