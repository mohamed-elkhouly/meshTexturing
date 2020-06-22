function [drays] = geod2cart(colo)
    la = colo(:,1);lo=colo(:,2);
    drays = [sin(la).*cos(lo), sin(la).*sin(lo), cos(la)];
end