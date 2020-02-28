function [indices,BW,height_inds,width_inds]=get_face_indexes(face_heights,face_widths,already_modified_pt)
face_heights=face_heights(:);
face_widths=face_widths(:);
indexes_of_face=true(max(face_heights)-min(face_heights)+1,max(face_widths)-min(face_widths)+1);

face_heights=[face_heights;face_heights(1)];
face_widths=[face_widths;face_widths(1)];
% tic
colfrom=zeros(500,1);
rowfrom=zeros(500,1);
% colfrom_cell=cell(3,1);
% rowfrom_cell=cell(3,1);
ind=1;
for i=1:3
    [ rowfrom_t,colfrom_t, ~] = improfile(indexes_of_face, face_heights(i:i+1), face_widths(i:i+1));
    %     colfrom_cell(i)={colfrom_t(:)};
    %     rowfrom_cell(i)={rowfrom_t(:)};
    colfrom(ind:(ind+length(colfrom_t)-1))=colfrom_t;
    rowfrom(ind:(ind+length(colfrom_t)-1))=rowfrom_t;
    ind=ind+length(colfrom_t);
%     colfrom=[colfrom;colfrom_t];
%     rowfrom=[rowfrom;rowfrom_t];
end
colfrom(ind:end)=[];
rowfrom(ind:end)=[];
% colfrom=[cell2mat(colfrom_cell(1));cell2mat(colfrom_cell(2));cell2mat(colfrom_cell(3))];
% rowfrom=[cell2mat(rowfrom_cell(1));cell2mat(rowfrom_cell(2));cell2mat(rowfrom_cell(3))];
% toc
for i=1:length(colfrom)
    indexes_of_face(round(rowfrom(i)),round(colfrom(i)))=0;
end
BW=~indexes_of_face;
% tic
[l,n]=bwlabel(indexes_of_face,4);
objects=1:n;
to_be_excluded=[l(1,1),l(1,end),l(end,1),l(end,end)];
to_be_excluded(to_be_excluded==0)=[];
objects(to_be_excluded)=[];
if (~isempty(objects))
    BW(l==objects(1))=1;
    len_obj=length(objects);
    if (len_obj>1)
        BW(l==objects(2))=1;
        if (len_obj>2)
            BW(l==objects(3))=1;
            if (len_obj>3)
                BW(l==objects(4))=1;
                if (len_obj>4)
                    BW(l==objects(5))=1;
                    if (len_obj>5)
                        BW(l==objects(6))=1;
                    end
                end
            end
        end
    end
    
end
%     BW(:)=0;
%     indices=[];
%     height_inds=[];
%     width_inds=[];
if nargin>2
    BW(already_modified_pt)=0;
end
indices=find(BW);
[height_inds,width_inds]=ind2sub(size(BW),indices);
end

