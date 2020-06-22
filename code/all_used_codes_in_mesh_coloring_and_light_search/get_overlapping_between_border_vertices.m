function final_mat=get_overlapping_between_border_vertices(vertices_on_border_info)
% here we first get overlapping between all textures border vertices, then
% we try to sort the textures based on the higest dependency to the first
% one, as the first one is the biggest texture. 
% in other words, we want to have a list of the textures based on their
% higer dependency on 1, e.g. if the textures 1,2,3,4 overlapp with each
% other as following: 
%    1  2    3    4
%1  -  20  10   50
%2 20  -   5    10
%3 10  5   -    40
%4 50  10 40   -
% 
% the best way for textures 2, and 4  to 1 will be direcctly through 1, but
% for 3 the best way to 1 will be through 4 as they have overlapping by 40
% while 4 has overlapping by 50 with 1, so the minimum overlapping will be
% 40 , while the direct way from 3 to 1 is only 10 points.

for i=1:size(vertices_on_border_info,1)
    current_vertices=cell2mat(vertices_on_border_info(i,1));
    for j=1:size(vertices_on_border_info,1)
        other_vertices=cell2mat(vertices_on_border_info(j,1));
        [common_vertices]=intersect(current_vertices,other_vertices);
        overlapping_mat(i,j)=length(common_vertices);
        if(i==j)
            overlapping_mat(i,j)=0;
        end
    end
end
available_indexes=(2:size(vertices_on_border_info,1))';
final_mat=[];
for i=2:size(vertices_on_border_info,1)
    overlap_with_1=overlapping_mat(i,1);
    to_be_excluded=[1,i];
    to_be_excluded_2=[i];
    overlapps=overlapping_mat(i,:);
    overlapps(to_be_excluded)=0;
    [ind]=find(overlapps>overlap_with_1);
    if (~isempty(ind))
         [result,val]=get_max(ind,overlapps,to_be_excluded_2,overlapping_mat,overlap_with_1);
          founded_zeros=find(result==0);
        result(founded_zeros)=[];
        val(founded_zeros)=[];
         [max_val,max_val_ind]=max(val);
         result=result(max_val_ind);
         if(isempty(result))
             final_mat(i)=1;
         else
             final_mat(i)=result;
         end
    else
        final_mat(i)=1;
    end
    if(sum(overlapps)==0)
        final_mat(i)=0;
    end
    
end

function [out_ind,out_val]=get_max(ind,overlapps,to_be_excluded_2,overlapping_mat,overlap_with_1)
out_ind=[];
out_val=[];
for j=1:length(ind)
        if(ind(j)==1)
            out_ind(j)=1;
            out_val(j)=overlapps(1);
          continue;
        end
        to_be_excluded_2=[to_be_excluded_2,ind(j)];
        level2_overlapps=overlapping_mat(ind(j),:);
        level2_overlapps(to_be_excluded_2)=0;
        [ind2]=find(level2_overlapps>overlap_with_1);
        if(isempty(ind2))
            out_ind(j)=0;
            out_val(j)=0;
           continue;
        end
        [out_ind2,out_val2]=get_max(ind2,level2_overlapps,to_be_excluded_2,overlapping_mat,overlap_with_1);
        founded_zeros=find(out_ind2==0);
        to_compare=[];
%           to_compare=level2_overlapps(out_ind2);
        to_compare=[to_compare;out_val2;ones(size(out_val2))*overlapps(ind(j));level2_overlapps(ind2)];
        out_val2=min(to_compare);
        out_ind2(founded_zeros)=[];
        out_val2(founded_zeros)=[];
        if(~isempty(out_ind2))
             [val,~]=max(out_val2);
             out_ind(j)=ind(j);
             out_val(j)=val;
        else
            out_ind(j)=0;
            out_val(j)=0;
        end
end
%  founded_zeros=find(out_ind==0);
%         out_ind(founded_zeros)=[];
%         out_val(founded_zeros)=[];
% curr_index=1;
% final_mat=[1];
% for i=1:length(available_indexes)
%
%     [~,ind]=max(overlapping_mat(curr_index,:));
%     final_mat=[final_mat;ind];
%     curr_index=ind;
%     overlapping_mat(curr_index,final_mat)=0;
%     if(isempty(available_indexes))
%         break;
%     end
% end
% s=[];
% t=[];
% weights =[];
% [~,ind]=max(overlapping_mat(1,:));
% overlapping_mat(ind,1)=0;
% for i=1:size(vertices_on_border_info,1)
% for j=1:size(vertices_on_border_info,1)
%     if(overlapping_mat(i,j)==0)
%         continue;
%     end
%  s=[s,i];
%  t=[t,j];
%  weights=[weights, overlapping_mat(i,j)];
% end
% end
% G = digraph(s,t,weights);
% H = plot(G,'EdgeLabel',G.Edges.Weight);
% [mf,GF] = maxflow(G,1,j);
% d=[];