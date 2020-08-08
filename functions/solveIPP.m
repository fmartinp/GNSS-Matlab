function [lla_IPP,n] = solveIPP(posleo,posgnss,altitude)
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later

if size(posleo,2) ~= 3 
    posleo = posleo';
end

if size(posgnss,2) ~= 3 
    posgnss = posgnss';
end

if size(altitude,2) > 1 
    altitude = altitude';
end

num_eq = length(altitude);

vec   = posgnss-posleo;
vec   = vec./repmat(vecnorm(vec,2,2),1,3);


d = repmat(1000,num_eq,1);

lla_IPP = repmat([NaN NaN NaN],num_eq,1);
ixf = [1:num_eq];
ixd = num_eq + ixf;

n = 0;
while (n < 100)
    
    lla  = ecef2lla([posleo; posleo] + [d;d+1].*[vec;vec]);
    f    = lla(ixf,3) - altitude;
    fd   = (lla(ixd,3)-lla(ixf,3));
    if max(abs(f)) < 50
        valid_roots = find(d>=0);
        lla_IPP(valid_roots,:) = lla(valid_roots,:);
        break;
    else
        d = d - f./fd;
    end
    n=n+1;
end

end

% toc    
% 
% tic
% while (n < 100)
%     lla=ecef2lla(guess);
%     %lla1=ecef2lla(guess+1)
%     error = lla(3)-altitude;
%     if abs(error) < 100
%         lla_IPP = lla
%         break;
%     else
%         d = d - sqrt_2*error;
%         guess = posleo + d*vec;
%     end
%     n=n+1;
% end
% n
% toc
% end
