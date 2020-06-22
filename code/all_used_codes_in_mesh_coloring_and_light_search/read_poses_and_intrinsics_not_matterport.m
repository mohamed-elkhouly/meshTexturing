function mesh=read_poses_and_intrinsics_not_matterport(mesh,folder_path,scene_name)
% folder_path='D:\1LXtFkjw3qL_1\camera\'
mesh=mrLoadLog(mesh,[folder_path, '/',scene_name] );