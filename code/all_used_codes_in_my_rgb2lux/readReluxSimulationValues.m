function reluxLux = readReluxSimulationValues(filename)

    currentFolder = pwd;
    cd(filename);
    fileList = dir('*.xls');
    
    reluxLux = [];
    for i = 1:length(fileList)
        
        luxmeter1 = xlsread(fileList(i).name,'M 9 E');
        luxmeter1 = luxmeter1(2:end, 2:end);

        luxmeter2 = xlsread(fileList(i).name,'M 10 E');
        luxmeter2 = luxmeter2(2:end, 2:end);

        luxmeter3 = xlsread(fileList(i).name,'M 11 E');
        luxmeter3 = luxmeter3(2:end, 2:end);

        luxmeter4 = xlsread(fileList(i).name,'M 12 E');
        luxmeter4 = luxmeter4(2:end, 2:end);

        luxmeter5 = xlsread(fileList(i).name,'M 13 E');
        luxmeter5 = luxmeter5(2:end, 2:end);

        luxmeter6 = xlsread(fileList(i).name,'M 14 E');
        luxmeter6 = luxmeter6(2:end, 2:end);

        luxmeter7 = xlsread(fileList(i).name,'M 15 E');
        luxmeter7 = luxmeter7(2:end, 2:end);

        luxmeter8 = xlsread(fileList(i).name,'M 16 E');
        luxmeter8 = luxmeter8(2:end, 2:end);

        reluxmeter = [mean2(luxmeter1); mean2(luxmeter2); mean2(luxmeter3); mean2(luxmeter4); mean2(luxmeter5); mean2(luxmeter6); mean2(luxmeter7); mean2(luxmeter8)];

        reluxLux = [reluxLux reluxmeter];
    end
        
    cd(currentFolder);

end