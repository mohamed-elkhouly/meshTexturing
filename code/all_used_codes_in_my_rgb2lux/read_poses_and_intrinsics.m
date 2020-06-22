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
    pose_number= sprintf( '%06d', i-1 ) ;
    file_path=[folder_path,'/camera/frame-', pose_number,'.pose.txt'];
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