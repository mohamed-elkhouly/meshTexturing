function [G_1,G_2]=balancing_regions(reg1inds_in,reg2inds_in,reg1vals,reg2vals,neig1inds_in,neig2inds_in)

this code will work only in case that region 1 indexes and region2 2 indexes is not overlapping

% reg1inds>> indexes in region1
% reg1vals>> values of region1 indexes

% reg2inds>> indexes in region1
% reg2vals>> values of region1 indexes

% neiginds>> for each index in region1 or region2  what is the nearest
% index to it from the other availables in its region. it is two  columns, the
% first 1 is the indexes , the second is their nearest indices.
reg1inds_in=([21 27 32 33 51 57 35 36 37])';
reg2inds_in=([22 28 38 39 52 58 41 42  22])';
reg1vals=([2 1 1 1 8 8 7 7 2])';
reg2vals=([8 7 9 9 2 2 3 3 8])';
neig1inds_in=([21 27 32 33 51 57 35 36 37; 27 21 33 32 57 51 36 35  21])';
neig2inds_in=([22 28 38 39 52 58 41 42; 28 22 39 38 58 52 42 41])';

reg1_uniques=unique(reg1inds_in);
for i=1:size(reg1inds_in,1)
        reg1inds(i,1)=find(reg1_uniques==reg1inds_in(i));
end

reg2_uniques=unique(reg2inds_in);
for i=1:size(reg2inds_in,1)
        reg2inds(i,1)=find(reg2_uniques==reg2inds_in(i));
end
reg2inds=reg2inds+  length(reg1inds);      
% reg1inds=([1:length(reg1inds_in)])';
% reg2inds=([length(reg1inds_in)+1:(length(reg1inds_in)+length(reg2inds_in))])';


for i=1:size(neig1inds_in,1)
    temp=reg1inds(reg1inds_in==neig1inds_in(i,1));
    neig1inds(i,1)=temp(1);
    temp=reg1inds(reg1inds_in==neig1inds_in(i,2));
    neig1inds(i,2)=temp(1);
end
for i=1:size(neig2inds_in,1)
    temp=reg2inds(reg2inds_in==neig2inds_in(i,1));
    neig2inds(i,1)=temp(1);
    temp=reg2inds(reg2inds_in==neig2inds_in(i,2));
    neig2inds(i,2)=temp(1);
end

neiginds=[neig1inds;neig2inds];
neiginds=sort(neiginds,2);
neiginds=unique(neiginds,'rows');

all_reg_inds=unique([reg1inds(:);reg2inds(:)]);
n_g=length(all_reg_inds);
g=[1:n_g];
F=reg1vals-reg2vals;
num_pairs=length(reg1inds);

A=[];

for i=1:size(reg1inds,1)
    A(i,g(all_reg_inds==reg1inds(i)))=1;
    A(i,g(all_reg_inds==reg2inds(i)))=-1;
end
G=[];
for i=1:size(neiginds,1)
    G(i,g(all_reg_inds==neiginds(i,1)))=1;
    G(i,g(all_reg_inds==neiginds(i,2)))=-1;
end

LHS=A'*A+G'*G;
RHS=A'*F;
%     tic;estimated_g = conjgrad(LHS,RHS);toc
tic;estimated_g =-1* linsolve(LHS,RHS);toc
correspondences=[all_reg_inds,(estimated_g)];
% correspondences=[all_reg_inds,(estimated_g)-mean(estimated_g)];

for i=1:size(reg1inds,1)
    G_1(i,:)=correspondences(all_reg_inds==reg1inds(i),:);
end
for i=1:size(reg2inds,1)
    G_2(i,:)=correspondences(all_reg_inds==reg2inds(i),:);
end
G_1(:,1)=reg1inds_in;
G_2(:,1)=reg2inds_in;
d=[];