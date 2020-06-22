function mesh=read_poses_and_intrinsics(mesh,folder_path)
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
    pose_number= numfiles_in_folder(i).name;
    pose_number=pose_number(7:12);
    mesh.original_frame_number(i)=str2num(pose_number);
    file_path=[numfiles_in_folder(i).folder,'/' ,numfiles_in_folder(i).name];
    fileID = fopen(file_path,'r');
    formatSpec = '%f';
    A = fscanf(fileID,formatSpec);
    A=reshape(A,[4 4])';
    mesh.pose(i).pose_matrix=A;
    mesh.campos(i,:)=A(1:3,4);
    mesh.camdir(i,:)=A(1:3,3);% which is the forward direction which is the third column
    fclose('all');
end
d=[];