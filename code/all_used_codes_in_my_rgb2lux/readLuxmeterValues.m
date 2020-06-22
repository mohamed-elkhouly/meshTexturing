function luxMeter = readLuxmeterValues(filename)
    currentFolder = pwd;
    cd(filename);
    fileList = dir('*.txt');
    
    luxMeter = [];
    for i = 1:length(fileList)
        fileID = fopen(fileList(i).name, 'r');
        C = textscan(fileID,'%*s %*s %*s %f %*[^\n]','HeaderLines',1);
        fclose(fileID);
        luxMeter = [luxMeter C{1}];
    end
        
    cd(currentFolder);
end