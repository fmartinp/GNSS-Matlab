function output = computeIPP(rnx,sp3leo,sp3igs,altitude)
%COMPIPP Computation of the IPP for a RINEX file
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later

%get times from rinex
t         = rnx.dates;

t_ind     = find(t>=min(sp3leo.pos.epoch) & t>=min(sp3igs.pos.epoch) & ...
                 t<=max(sp3leo.pos.epoch) & t<=max(sp3igs.pos.epoch));

t_compute = t(t_ind);
idgnss    = rnx.satId(t_ind);
ugnss     = unique(idgnss);
[ut,it,iut]  = unique(t_compute);
toc      
leo_t  = interpSp3(sp3leo,ut);
%gnss_t = interpSp3(sp3igs,ut);
toc
ipp  = zeros(length(t_ind),3);
xleo = leo_t.pos.x(iut);
yleo = leo_t.pos.y(iut);
zleo = leo_t.pos.z(iut);
toc

idgnss    = rnx.satId(t_ind);
posleo    = [xleo yleo zleo]*1000;

n =zeros(1,length(t_ind));

output.obs = rnx.obs(t_ind,:);
output.flags = rnx.flags(t_ind,:);
output.snr = rnx.snr(t_ind,:);
output.dates = t_compute;
output.satId = idgnss;
output.constellations = rnx.constellations;
output.obslist = rnx.obslist;
output.epochflag = rnx.epochflag(t_ind);
output.time_system = rnx.time_system;
output.leo_pos.x = posleo(:,1)/1000;
output.leo_pos.y = posleo(:,2)/1000;
output.leo_pos.z = posleo(:,3)/1000;
output.sat_pos.x = zeros(length(t_ind),1);
output.sat_pos.y = output.sat_pos.x;
output.sat_pos.z = output.sat_pos.x;
output.sat_pos.elev = output.sat_pos.x;
output.sat_pos.tx = repmat(NaT,length(t_ind),1);
output.ipp_pos.x = output.sat_pos.x;
output.ipp_pos.y = output.sat_pos.x;
output.ipp_pos.z = output.sat_pos.x;

for k=1:length(ugnss)
    ii_gnss = find(idgnss==ugnss(k));
    posleo_s = posleo(ii_gnss,:);
    [posgnss,tx] = computeSp3SatTx(sp3igs,ugnss(k),t_compute(ii_gnss),posleo_s);
    posleo_s = posleo(ii_gnss,:);
    llaIPP = solveIPPv(posleo_s,posgnss,repmat(altitude,length(ii_gnss),1));
    xyzIPP = lla2ecef(llaIPP)/1000;
    output.sat_pos.x(ii_gnss) = posgnss(:,1);
    output.sat_pos.y(ii_gnss) = posgnss(:,2);
    output.sat_pos.z(ii_gnss) = posgnss(:,3);
    output.sat_pos.tx(ii_gnss) = tx;
    output.sat_pos.elev(ii_gnss) = acosd(sum(posleo_s.*posgnss,2)./(vecnorm(posleo_s,2,2).*vecnorm(posgnss,2,2)));
    output.ipp_pos.x(ii_gnss) = xyzIPP(:,1);
    output.ipp_pos.y(ii_gnss) = xyzIPP(:,2);
    output.ipp_pos.z(ii_gnss) = xyzIPP(:,3);
end

end
