function output = readDCB(filePath)

% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later


ff = fileread(filePath);
filebyline = regexp(ff, '\n', 'split');

bl = find(contains(filebyline,'BIAS/SOLUTION'));
body = filebyline(bl(1)+2:bl(2)-1);

body  = vertcat(body{:});

bias  = deblank(string(body(:,2:5)));

body(body(:,13)==' ',13)='0';
body(body(:,14)==' ',14)='0';
prn   = string(body(:,12:14));
station = deblank(string(body(:,16:24)));
obs1 = deblank(string(body(:,26:29)));
obs2 = deblank(string(body(:,31:34)));
bias_start = datetime(string(body(:,36:43)),'InputFormat','uuuu:DDD') + seconds(cell2mat(textscan(strjoin(string(body(:,45:49)),' '),'%u')));
bias_end   = datetime(string(body(:,51:58)),'InputFormat','uuuu:DDD') + seconds(cell2mat(textscan(strjoin(string(body(:,60:64)),' '),'%u')));
unit = deblank(string(body(:,66:69)));
estimated_value = cell2mat(textscan(strjoin(string(body(:,71:91)),' '),'%f'));
std_dev         = cell2mat(textscan(strjoin(string(body(:,93:103)),' '),'%f'));


output.bias       = bias;
output.prn        = computeSatID(prn);
output.station    = station;
output.obs1       = obs1;
output.obs2       = obs2;
output.bias_start = bias_start;
output.bias_end   = bias_end;
output.unit       = unit;
output.est_value  = estimated_value;
output.std_dev    = std_dev;

end

