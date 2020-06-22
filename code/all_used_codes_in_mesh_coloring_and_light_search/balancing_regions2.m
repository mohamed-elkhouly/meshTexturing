function [correspondences]=balancing_regions2(required_matrices)

% this code will work only in case that region 1 indexes and region2 2 indexes is not overlapping
% 
% % reg1inds>> indexes in region1
% % reg1vals>> values of region1 indexes
% 
% % reg2inds>> indexes in region1
% % reg2vals>> values of region1 indexes
% 
% % neiginds>> for each index in region1 or region2  what is the nearest
% % index to it from the other availables in its region. it is two  columns, the
% % first 1 is the indexes , the second is their nearest indices.
% reg1inds_in=([21 27 32 33 51 57 35 36 ])';
% reg2inds_in=([22 28 38 39 52 58 41 42 ])';
% reg1vals=([2 1 1 1 8 8 7 7 ])';
% reg2vals=([8 7 9 9 2 2 3 3 ])';
% neig1inds_in=([21 27 32 33 51 57 35 36 ; 27 21 33 32 57 51 36 35  ])';
% neig2inds_in=([22 28 38 39 52 58 41 42; 28 22 39 38 58 52 42 41])';
% 
% reg1_uniques=unique(reg1inds_in);
% for i=1:size(reg1inds_in,1)
%         reg1inds(i,1)=find(reg1_uniques==reg1inds_in(i));
% end
% 
% reg2_uniques=unique(reg2inds_in);
% for i=1:size(reg2inds_in,1)
%         reg2inds(i,1)=find(reg2_uniques==reg2inds_in(i));
% end
% reg2inds=reg2inds+  length(reg1inds);      
% % reg1inds=([1:length(reg1inds_in)])';
% % reg2inds=([length(reg1inds_in)+1:(length(reg1inds_in)+length(reg2inds_in))])';
% 
% 
% for i=1:size(neig1inds_in,1)
%     temp=reg1inds(reg1inds_in==neig1inds_in(i,1));
%     neig1inds(i,1)=temp(1);
%     temp=reg1inds(reg1inds_in==neig1inds_in(i,2));
%     neig1inds(i,2)=temp(1);
% end
% for i=1:size(neig2inds_in,1)
%     temp=reg2inds(reg2inds_in==neig2inds_in(i,1));
%     neig2inds(i,1)=temp(1);
%     temp=reg2inds(reg2inds_in==neig2inds_in(i,2));
%     neig2inds(i,2)=temp(1);
% end
reg1inds=required_matrices(:,1);
reg2inds=required_matrices(:,2);



[all_reg_inds,~,ind_b]=unique([reg1inds(:);reg2inds(:)]);
find_in_all_reg_inds(max(all_reg_inds))=0;
for i=1:length(all_reg_inds)
    find_in_all_reg_inds(all_reg_inds(i))=i;
end
ind_b_1=ind_b(1:length(ind_b)/2);
ind_b_2=ind_b((length(ind_b)/2+1):end);
n_g=length(all_reg_inds);
g=[1:n_g];

temp_index=(1:size(reg1inds,1))';
B=[temp_index,g(ind_b_1)',ones(size(reg1inds,1),1)];
C=[temp_index,g(ind_b_2)',-1*ones(size(reg1inds,1),1)];
A=[B;C];
A=sparse(A(:,1),A(:,2),A(:,3));

% for i=1:size(reg1inds,1)
%     A(i,g(all_reg_inds==reg1inds(i)))=1;
%     A(i,g(all_reg_inds==reg2inds(i)))=-1;
% end

neig1inds=[reg1inds,required_matrices(:,9)];
neig2inds=[reg2inds,required_matrices(:,10)];

neiginds=[neig1inds;neig2inds];
neiginds_sorted=sort(neiginds,2);
[neiginds,ia,ic]=unique(neiginds_sorted,'rows');

temp_index=(1:size(neiginds,1))';
B=[temp_index,g(find_in_all_reg_inds(neiginds(:,1)))',0.1*ones(size(neiginds,1),1)];
C=[temp_index,g(find_in_all_reg_inds(neiginds(:,2)))',-0.1*ones(size(neiginds,1),1)];
G=[B;C];
G=sparse(G(:,1),G(:,2),G(:,3));
% for i=1:size(neiginds,1)
%     G(i,g(all_reg_inds==neiginds(i,1)))=1;
%     G(i,g(all_reg_inds==neiginds(i,2)))=-1;
% end

LHS=A'*A+G'*G;
for i=1:3
reg1vals=required_matrices(:,(i*2+1));
reg2vals=required_matrices(:,(i*2+2));
F=reg1vals-reg2vals;
RHS=A'*F;
%     tic;estimated_g = conjgrad(LHS,RHS);toc
% tic;estimated_g =-1* linsolve(LHS,RHS);toc
estimated_g(:,i)=1*lsqminnorm(LHS,RHS);
estimated_g(:,i)=estimated_g(:,i)-mean(estimated_g(:,i));
end
temp_mat(reg1inds(:),1:3)=estimated_g(ind_b_1,:);
temp_mat(reg2inds(:),4:6)=-1*estimated_g(ind_b_2,:);
aa=find(sum(abs(temp_mat(:,[1,2,3])),2)==0);
bb=find(sum(abs(temp_mat(:,[4,5,6])),2)~=0);
common_indices=ismember(aa,bb);
temp_mat(aa(common_indices),1:3)=temp_mat(aa(common_indices),4:6);
dd=sum(abs(temp_mat(:,[1,2,3])),2)~=0;
correspondences=[all_reg_inds,(temp_mat(dd,1:3))];
% correspondences=[all_reg_inds,(estimated_g)-mean(estimated_g)];

% for i=1:size(reg1inds,1)
%     G_1(i,:)=correspondences(all_reg_inds==reg1inds(i),:);
% end
% for i=1:size(reg2inds,1)
%     G_2(i,:)=correspondences(all_reg_inds==reg2inds(i),:);
% end
% G_1(:,1)=reg1inds_in;
% G_2(:,1)=reg2inds_in;
d=[];