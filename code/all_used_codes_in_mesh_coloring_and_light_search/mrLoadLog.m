function mesh= mrLoadLog(mesh, scene_name )

% fx = 525.0; fy = 525.0; // default focal length
% cx = 319.5; cy = 239.5; // default optical center
% Eigen::Matrix4d Tk; // k-th transformation matrix from trajectory.log
%
% // translation from depth pixel (u,v,d) to a point (x,y,z)
% z = d / 1000.0;
% x = (u - cx) * z / fx;
% y = (v - cy) * z / fy;
%
% // transform (x,y,z) to (xw,yw,zw)
% Eigen::Vector4d w = Tk * Eigen::Vector4d(x, y, z, 1);
% xw = w(0); yw = w(1); zw = w(2);


% mesh=[];
% filename='lounge_trajectory.log';
filename=[scene_name,'_trajectory.log'];
fx = 525.0; fy = 525.0; %default focal length
cx = 319.5; cy = 239.5; % default optical center
A=[fx 0 cx 0;
    0  fy cy 0;
    0 0 1 0;
    0 0 0 1;
    ];
mesh.intrinsics=A;
fid = fopen( filename );
k = 1;
x = fscanf( fid, '%d', [1 3] );
while ( size( x, 2 ) == 3 )
    m = fscanf( fid, '%f', [4 4] );
    %         traj( k ) = struct( 'info', x, 'trans', m' );
    m=m';
    mesh.pose(k).pose_matrix=m;
    mesh.pose_matrix(k,:)=(m(:))';
    mesh.campos(k,:)=m(1:3,4);
    mesh.camdir(k,:)=m(1:3,3);
    k = k + 1;
    x = fscanf( fid, '%d', [1 3] );
end
fclose( fid );

%     disp( [ num2str( size( traj, 2 ) ), ' frames have been read.' ] );
end