function [cadModel_] = subdivideFaces2(cadModel)
        
    cadModel_.f = [];
    tmp_floor = cadModel.areas(cadModel.floorPatches) > 80000;
    tmp_floor2 = cadModel.floorPatches(tmp_floor);
    tmp_floor3 = cadModel.floorPatches(~tmp_floor);
    [cadModel_.v, floor] = subdivideFaces(cadModel.f(tmp_floor2,:), cadModel.v, 4);
    cadModel_.floorPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(floor)+length(tmp_floor3)))';
    cadModel_.f = [cadModel_.f; cadModel.f(tmp_floor3,:); floor];
    
    tmp_ceiling = cadModel.areas(cadModel.ceilingPatches) > 200000;
    tmp_ceiling2 = cadModel.ceilingPatches(tmp_ceiling);
    tmp_ceiling3 = cadModel.ceilingPatches(~tmp_ceiling);
    [cadModel_.v, ceiling] = subdivideFaces(cadModel.f(tmp_ceiling2,:), cadModel_.v, 4);
    cadModel_.ceilingPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(ceiling)+length(tmp_ceiling3)))';
    cadModel_.f = [cadModel_.f; cadModel.f(tmp_ceiling3,:); ceiling];
    
    tmp_wall1 = cadModel.areas(cadModel.wallPatches.wall1) > 100000;
    tmp_wall12 = cadModel.wallPatches.wall1(tmp_wall1);
    tmp_wall13 = cadModel.wallPatches.wall1(~tmp_wall1);
    [cadModel_.v, wall1] = subdivideFaces(cadModel.f(tmp_wall12,:), cadModel_.v, 10);
    cadModel_.wallPatches.wall1 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(wall1)+length(tmp_wall13)))';
    cadModel_.f = [cadModel_.f; cadModel.f(tmp_wall13,:); wall1];
    
    [cadModel_.v, wall2] = subdivideFaces(cadModel.f(cadModel.wallPatches.wall2,:), cadModel_.v, 4);
    cadModel_.wallPatches.wall2 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(wall2)))';
    cadModel_.f = [cadModel_.f; wall2];
    
    [cadModel_.v, wall3] = subdivideFaces(cadModel.f(cadModel.wallPatches.wall3,:), cadModel_.v, 4);
    cadModel_.wallPatches.wall3 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(wall3)))';
    cadModel_.f = [cadModel_.f; wall3];
    
    tmp_wall4 = cadModel.areas(cadModel.wallPatches.wall4) > 1000000;
    tmp_wall42 = cadModel.wallPatches.wall4(tmp_wall4);
    tmp_wall43 = cadModel.wallPatches.wall4(~tmp_wall4);
    [cadModel_.v, wall4] = subdivideFaces(cadModel.f(tmp_wall42,:), cadModel_.v, 4);
    cadModel_.wallPatches.wall4 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(wall4)+length(tmp_wall43)))';
    cadModel_.f = [cadModel_.f; cadModel.f(tmp_wall43,:); wall4];
    
    

    light1 = cadModel.f(cadModel.lightPatches.light1,:);
    cadModel_.lightPatches.light1 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light1];
    
    light2 = cadModel.f(cadModel.lightPatches.light2,:);
    cadModel_.lightPatches.light2 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light2];
    
    light3 = cadModel.f(cadModel.lightPatches.light3,:);
    cadModel_.lightPatches.light3 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light3];

    light4 = cadModel.f(cadModel.lightPatches.light4,:);
    cadModel_.lightPatches.light4 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light4];
    
    light5 = cadModel.f(cadModel.lightPatches.light5,:);
    cadModel_.lightPatches.light5 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light5];
    
    light6 = cadModel.f(cadModel.lightPatches.light6,:);
    cadModel_.lightPatches.light6 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light6];
    
    light7 = cadModel.f(cadModel.lightPatches.light7,:);
    cadModel_.lightPatches.light7 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light7];
    
    light8 = cadModel.f(cadModel.lightPatches.light8,:);
    cadModel_.lightPatches.light8 = ((length(cadModel_.f)+1):(length(cadModel_.f)+2))';
    cadModel_.f = [cadModel_.f; light8];



    
    [cadModel_.v, desk1] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk1,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk1 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk1)))';
    cadModel_.f = [cadModel_.f; desk1];

    [cadModel_.v, desk2] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk2,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk2 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk2)))';
    cadModel_.f = [cadModel_.f; desk2];
    

    [cadModel_.v, desk3] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk3,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk3 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk3)))';
    cadModel_.f = [cadModel_.f; desk3];


    [cadModel_.v, desk4] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk4,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk4 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk4)))';
    cadModel_.f = [cadModel_.f; desk4];

    [cadModel_.v, desk5] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk5,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk5 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk5)))';
    cadModel_.f = [cadModel_.f; desk5];

    [cadModel_.v, desk6] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk6,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk6 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk6)))';
    cadModel_.f = [cadModel_.f; desk6];

    [cadModel_.v, desk7] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk7,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk7 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk7)))';
    cadModel_.f = [cadModel_.f; desk7];

    [cadModel_.v, desk8] = subdivideFaces(cadModel.f(cadModel.deskPatches.desk8,:), cadModel_.v, 8);
    cadModel_.deskPatches.desk8 = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(desk8)))';
    cadModel_.f = [cadModel_.f; desk8];
    
    
    
    legDeskPatches = cadModel.f(cadModel.legDeskPatches,:);
    cadModel_.legDeskPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(legDeskPatches)))';
    cadModel_.f = [cadModel_.f; legDeskPatches];
    
%     panelPatches = cadModel.f(cadModel.panelPatches,:);
%     cadModel_.panelPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(panelPatches)))';
%     cadModel_.f = [cadModel_.f; panelPatches];
    
    [cadModel_.v, panelPatches] = subdivideFaces(cadModel.f(cadModel.panelPatches,:), cadModel_.v, 4);
    cadModel_.panelPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(panelPatches)))';
    cadModel_.f = [cadModel_.f; panelPatches];
    
    panelHandlesPatches = cadModel.f(cadModel.panelHandlesPatches,:);
    cadModel_.panelHandlesPatches = ((length(cadModel_.f)+1):(length(cadModel_.f)+length(panelHandlesPatches)))';
    cadModel_.f = [cadModel_.f; panelHandlesPatches];

    
    cadModel_.deskPatches.allDesks = [cadModel_.deskPatches.desk1; cadModel_.deskPatches.desk2; cadModel_.deskPatches.desk3; cadModel_.deskPatches.desk4; cadModel_.deskPatches.desk5; cadModel_.deskPatches.desk6; cadModel_.deskPatches.desk7; cadModel_.deskPatches.desk8];
    cadModel_.wallPatches.allWalls = [cadModel_.wallPatches.wall1; cadModel_.wallPatches.wall2; cadModel_.wallPatches.wall3; cadModel_.wallPatches.wall4];
    cadModel_.lightPatches.allLights = [cadModel_.lightPatches.light1; cadModel_.lightPatches.light2; cadModel_.lightPatches.light3; cadModel_.lightPatches.light4; cadModel_.lightPatches.light5; cadModel_.lightPatches.light6; cadModel_.lightPatches.light7; cadModel_.lightPatches.light8];

end