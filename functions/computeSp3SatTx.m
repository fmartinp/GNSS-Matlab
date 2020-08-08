function [output,tx] = computeSp3SatTx(sp3igs,satid,rx_epoch,pos_leo)
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
% 9th degree Lagrange interpolation of a sp3struct
% Input:
% - sp3struct: Sp3 structure variable
% - int_epoch: array of interpolated times (datetime format)
% Output:
% - output: Sp3 structure variable with the interpolated positions
%


c = 299792458;
tx = rx_epoch;
n =1;

while (n < 30)
    gnss_ref = interpSp3Sat(sp3igs,satid,tx);
    pos_gnss = [gnss_ref.pos.x gnss_ref.pos.y gnss_ref.pos.z] * 1000;
    f = vecnorm(pos_leo - pos_gnss,2,2) - c*seconds(rx_epoch - tx);
    if max(abs(f)) < 0.1
        output = pos_gnss;
        break;
    else
        tx = tx - seconds(f/c);
        n = n+1;
    end
end
