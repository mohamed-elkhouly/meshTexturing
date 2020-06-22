function luxMeter = readLuxmeterValues_dahy(filename)
warning('off')
    currentFolder = pwd;
    cd(filename);
    fileList = dir('*.csv');
    for i = 1:length(fileList)
        sorted_list{i}=fileList(i).name;
    end
    sorted_list=natsortfiles(sorted_list);
    luxMeter = [];
    for i = 1:length(sorted_list)
       table=readtable(cell2mat(sorted_list(i)));
       lux_values=table2array(table(2,[6:6:end]));
       for j=1:length(lux_values)
            luxMeter(j,i)=str2num(cell2mat(lux_values(j)));
       end
    end
      