function mesh=readPoses_Intrinsics_FrameNumbers(mesh,folder_path)
% folder_path='D:\1LXtFkjw3qL_1\camera\'
intrinsics_find=dir([folder_path,'/*_1_intrinsics.txt']);
file_path=[intrinsics_find.folder,'/',intrinsics_find.name];
fileID = fopen(file_path,'r');
    formatSpec = '%f';
    A = fscanf(fileID,formatSpec);
    A=reshape(A,[4 4])';
    mesh.intrinsics=A;
    fclose('all');
numfiles_in_folder=dir([folder_path,'/camera/*.txt']);
for i=1:length(numfiles_in_folder)
    pose_name= numfiles_in_folder(i).name;
    pose_number(i,1)=str2num(pose_name(7:12));
    file_path=[folder_path,'/camera/', pose_name];
    fileID = fopen(file_path,'r');
    formatSpec = '%f';
    A = fscanf(fileID,formatSpec);
    A=reshape(A,[4 4])';
    mesh.pose(i).pose_matrix=A;
    mesh.campos(i,:)=A(1:3,4);
    mesh.camdir(i,:)=A(1:3,3);% which is the forward direction which is the third column
    fclose('all');
end
mesh.frame_number=pose_number;
d=[];