fileList = dir(strcat('C:\Users\t.tsesmelis.LIGHT\Desktop\sync\rgbd2lux\dataset\room3a\radiosities\','*.mat'));
files = {fileList.name}';
files = natsortfiles(files);

load('C:\Users\t.tsesmelis.LIGHT\Desktop\sync\rgbd2lux\dataset\room3a\lsc_pasco.mat')
lsc = struct('lsc', lsc_pasco, 'ldcSymetric', cat(2, lsc_pasco, fliplr(lsc_pasco(:,1:end-1))), 'ldcZ', (0:10:180)', 'ldcX', (0:10:180));

E = [];
% hp = [];
for i = 1:length(fileList)
    load(files{i}, 'r', 'mesh');
    thisFile=strsplit(files{i},'_');
    corrMatName=strcat(thisFile{end-2},'_',thisFile{end-1},'.mat');
    load(strcat('C:\Users\t.tsesmelis.LIGHT\Desktop\sync\rgbd2lux\dataset\room3a\head_estimations\',corrMatName));
    mesh.lsc = lsc;
    
    % room3a (because Irtiza got the orientation vector from destination to the head)
    meshStruct(1).norm = meshStruct(1).norm*-1;
    meshStruct(2).norm = meshStruct(2).norm*-1;
    
    % room4a
%     meshStruct(1).norm = meshStruct(1).norm;
%     meshStruct(2).norm = meshStruct(2).norm*-1;
    
    for j = 1:2
        E(j,i) = lightPerceptionTest(mesh, meshStruct(j), r, lsc);
    end
    
end

clearvars -except E lsc;