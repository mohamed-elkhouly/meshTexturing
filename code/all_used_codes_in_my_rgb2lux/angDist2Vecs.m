function thetaDEG = angDist2Vecs(u,v)

if length(u)==3
    %3D, can use cross to resolve sign
    uMod = sqrt(sum(u.^2));
    vMod = sqrt(sum(v.^2));
    uvPr = sum(u.*v);
    costheta = min(uvPr/uMod/vMod,1);

    thetaDEG = acos(costheta)*180/pi;

    %resolve sign
    cp=(cross(u,v));
    idxM=find(abs(cp)==max(abs(cp)));
    s=sign(cp(idxM(1)));
    if s < 0
        thetaDEG = -thetaDEG;
    end
elseif length(u)==2
    %2D use atan2
    thetaDEG = (atan2(v(2),v(1))-atan2(u(2),u(1)))*180/pi;
else
    error('u,v must be 2D or 3D vectors');
end