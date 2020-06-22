[A0,Xr,Yr,Xc,Yc]=isocell_distribution(1000,5,0);
% figure
% plot(Xc,Yc,'b')
% hold on
% plot(Xr,Yr,'.r')
% axis equal
dirk = [Xr; Yr; sqrt(1-Xr.^2-Yr.^2)];
points = dirk;
figure, plot_vertices(points); % or figure, plot3(points(1,:),points(2,:),points(3,:),'b.','MarkerSize', 2);
xlabel('x'); ylabel('y'); zlabel('z');

% Adjust settings
set(gcf,'PaperPosition',[0.6345175 6.34517 20.30456 15.22842]);
set(gcf,'PaperSize',[20.984 29.677]);
set(gcf,'Position',[1 1 959 725]);
set(gca,'Position',[0.13 0.11 0.775 0.815])
axis equal
set(gcf,'Color','White')

hold on

ldc = [426.0060  426.0060  426.0060  426.0060  426.0060  426.0060  426.0060
       424.7540  425.0980  425.5810  425.9940  425.6490  425.1670  424.7540
       421.8600  422.2040  422.7550  423.1690  422.6860  422.2040  421.8600
       415.5200  416.0020  416.1400  416.8980  416.6910  416.2780  415.7960
       408.6290  406.9060  407.0440  408.0090  409.0420  407.3890  406.5620
       394.1580  394.2960  394.5030  395.1920  395.0540  394.5720  394.5720
       374.5880  375.8290  376.9310  376.6550  374.6570  376.3800  377.4820
       349.7810  351.3660  352.8130  351.9170  350.7460  352.1930  353.9150
       317.8070  316.2910  318.2210  316.2910  316.8420  317.1870  319.8750
       267.2280  269.4330  264.4720  267.9170  267.9170  269.6400  266.1260
       200.4280  162.1010  174.1260  163.2380  199.5320  163.8650  174.8770
       111.4940  118.7160  150.0280  118.3780  112.6450  116.1870  151.6540
        73.5810   78.4390   99.5180   80.3960   75.7450   78.4250  100.4280
        49.7660   69.2120   54.2240   71.2930   52.1980   71.8860   56.8360
        35.5290   49.5180   46.4930   48.3810   35.8390   47.2780   48.2220
        34.3720   37.9410   35.3290   38.5750   33.9930   39.9950   35.4050
        24.1730   24.9380   28.9690   25.8750   24.7800   24.6350   28.5140
        14.3050   15.9870   19.6670   16.4830   15.1460   15.9450   19.7770
         6.0920    6.5390    7.0420    7.2350    6.9940    6.8220    6.6840
         4.7550    4.9550    5.2780    5.2160    5.2090    5.4780    5.6640
         3.8590    3.8520    3.8930    3.9000    3.8870    4.3210    4.4380
         3.1150    3.1420    2.9350    2.8530    3.0870    3.4660    3.5970
         2.8670    2.6670    2.4740    2.3500    2.5700    2.9290    3.1700
         2.4120    2.4050    2.3360    2.0330    2.3500    2.6050    2.7840
         1.6540    1.6670    1.9090    1.8880    1.7300    1.5920    1.6810
         1.1300    1.1990    1.2680    1.4880    1.2270    1.1580    1.1300
         1.0470    1.0400    1.0400    1.1440    1.0750    1.0540    1.0470
         1.1300    1.1640    1.2060    1.1850    1.2130    1.1850    1.1710
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0
              0         0         0         0         0         0         0];
          
lsc = [     1       1       1       1       1       1       1       1       1       1
        0.984	0.984	0.984	0.984	0.984	0.984	0.984	0.984	0.984	0.984
        0.936	0.936	0.936	0.936	0.936	0.936	0.936	0.936	0.936	0.936
        0.854	0.854	0.854	0.854	0.854	0.854	0.854	0.854	0.854	0.854
        0.736	 0.736	 0.736	 0.736	 0.736	 0.736	 0.736	 0.736	 0.736	 0.736
        0.572	0.572	0.572	0.572	0.572	0.572	0.572	0.572	0.572	0.572
        0.313	0.313	0.313	0.313	0.313	0.313	0.313	0.313	0.313	0.313
        0.0770	0.0770	0.0770	0.0770	0.0770	0.0770	0.0770	0.0770	0.0770	0.0770
        0.0164	 0.0164	 0.0164	 0.0164	 0.0164	 0.0164	 0.0164	 0.0164	 0.0164	 0.0164
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
        0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00
];
          
plot2Dldc(ldc)
hold on;
plot2Dlsc(lsc)
     
%      ldc_norm = normalizeLDC(ldc, 0, 1);
ldc = struct('ldc', ldc, 'ldcNorm', normalizeLDC(ldc, 0, 1), 'ldcSymetric', cat(2, ldc, fliplr(ldc(:,1:end-1))), 'ldcZ', (0:5:180)', 'ldcX', (0:15:180));

init_pos = [0; 0; 0];

plot3DLdc(ldc.ldcNorm, init_pos);

quiver3(0,0,0,1*0,1*0,1*1,0,'b', 'LineWidth', 2); 
quiver3(0,0,0,1*1,1*0,1*0,0,'g', 'LineWidth', 2);
quiver3(0,0,0,1*0,1*1,1*0,0,'r', 'LineWidth', 2);

hold on

n_vis = size(points,2);
% Compute the relative position of each point with respect to the camera center
v_points = points - repmat(init_pos,[1,n_vis]);

% Compute the distance between each point and the center of the camera
norms = sqrt(sum(v_points .* v_points));

v_center = [0; 0; 1];
% Compute the angle between the principal axis (Z-axis) and the ray connecting the light source to each point
vcenter_to_vpoint_angle = acosd(sum(repmat(v_center,[1,n_vis]) .* v_points) ./ norms);

% Compute the angle between the principal axis (X-axis) and the ray connecting the light source to each point
v_centerX = [1; 0; 0;];
vcenter_to_vpoint_angle_X_axis = acosd(sum(repmat(v_centerX,[1,n_vis]) .* v_points) ./ norms);

descriptor = struct('initialPosition',  init_pos, 'pointsPosition', points, ...
            'angleZ', vcenter_to_vpoint_angle, 'angleX', vcenter_to_vpoint_angle_X_axis, 'distance', norms, 'v_center', v_center);
        
descriptor.candelas = interp2(ldc.ldcZ, ldc.ldcX, ldc.ldcSymetric', descriptor.angleZ, descriptor.angleX);

scatter3(descriptor.pointsPosition(1,:), descriptor.pointsPosition(2,:), descriptor.pointsPosition(3,:), 15, descriptor.candelas, 'filled');

function normalized = normalizeLDC(array, x, y)

     % Normalize to [0, 1]:
     m = min(array(:));
     range = max(array(:)) - m;
     array = (array - m) ./ range;

     % Then scale to [x,y]:
     range2 = y - x;
     normalized = (array*range2) + x;
end

function plot3DLdc (ldc, pos)

    figure
    if nargin < 2
        posX = 0;
        posY = 0;
        posZ = 0;
    else
        posX = pos(1);
        posY = pos(2);
        posZ = pos(3);
    end

% angles around x-axis, need to turn by 90 degree right pol2cart output
anglesX = (0:5:360)/180*pi+pi/2;

% angles around z-axis
anglesZ = 0:15:90;

% data = flipud(ldc_norm);
% step = size(ldc,2) - 1;
step = 1;
% loop over columns
for i = 1:step:size(ldc,2)
    % you need to create a closed contour for fill3
    ldcJoined = [ldc(:,i);ldc((end-1):-1:1,i)];
    % plot for positive and negative angle around z, i as color-index
    plotLdcCurve(anglesX, ldcJoined, anglesZ(i), i, posX, posY, posZ)
    hold on
    plotLdcCurve(anglesX, ldcJoined, -anglesZ(i), i, posX, posY, posZ)
end

% Adjust settings
set(gcf,'PaperPosition',[0.6345175 6.34517 20.30456 15.22842]);
set(gcf,'PaperSize',[20.984 29.677]);
set(gcf,'Position',[1 1 959 725]);
set(gca,'Position',[0.13 0.11 0.775 0.815])
axis equal
set(gcf,'Color','White')
end

function [] = plotLdcCurve(anglesX, r, angleZ, c, posX, posY, posZ)

    % convert to cartesian coordinates
    [p1, p2] = pol2cart(anglesX, r');

    % plot on x-axis (x=0)
    X = ones(size(p1))*posX;
    Y = p1+posY;
    Z = p2+posZ;
%     C = ones(size(Z)) .* c; % color input needed, you could e.g. C=sin(angles);
    
    % plot contours
    h = plot3(X,Y,Z,'r');
    
    origin = [posX posY 0];
    rotate(h, [0,0,1], angleZ, origin);
    
    xlabel('x'); ylabel('y'); zlabel('z');
end