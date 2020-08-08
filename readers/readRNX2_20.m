function output = readRNX2_20(filePath)
%READRNX3 RINEX 2.20 reader
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
%   The function returns a struct with the data from a RINEX 2.20 file
%   The output structure is composed by:
%    output.obs   -> A matrix with the observation values every column is a
%                    a different observable type
%    output.flags -> A matrix with the flags related to each observation of
%                    the obs matrix
%    output.snr   -> A matrix with the signal strength of each observation
%                    in the obs matrix
%    output.dates -> An array with the epoch time corresponding to each row
%                    of the obs matrix
%    output.satId -> An array with the Sat ID
%    output.constellations -> Cell array with the list of constellations
%                           available in the file
%    output.obslist -> Cell array with the list of observations for each
%                      constellation
%    output.offset_clock -> Array of bias clock


ff = fileread(filePath);
filebyline = regexp(ff, '\n', 'split');

numLine = 0;

while (true)
    numLine = numLine + 1;
    line = filebyline{numLine};
    splitLine = strsplit(line);
    
    if contains(line,'END OF HEADER')
        break;
    elseif contains(line,'# / TYPES OF OBSERV')
        constellations = 'G';
        
        constellationNumObs = str2double(line(1:6));
        constellationObs = splitLine(3:end - 6);
        
        if constellationNumObs > 9 %Two line case
            numLine = numLine + 1;
            line2 = filebyline{numLine};
            splitLine2 = strsplit(line2);
            constellationObs = [constellationObs, splitLine2(2:end - 6) ];
        end
    elseif contains(line,'TIME OF FIRST OBS')
        time_system = line(49:51);
    end
end

if isempty(filebyline{end})
    body = filebyline(numLine+1:end-1);
else
    body = filebyline(numLine+1:end);
end

numBodyLines = length(body);

line = 1;
linedates  = false(length(body),1);
recdatestr = cell(length(linedates),1);
recsats    = cell(length(linedates),1);
recflag    = cell(length(linedates),1);
recclockoffset = cell(length(linedates),1);

if constellationNumObs > 5
    obslines = 2;
else
    obslines = 1;
end

while (line < numBodyLines)
    numsats = str2double(body{line}(30:32));
    recdatestr{line} = body{line}(2:26);
    recflag{line} = body{line}(29);
    linedates(line) = true;
    recsats{line} = body{line}(33:68);
    recclockoffset{line} = body{line}(69:80);
    if numsats > 12
        line = line + 1;
        recsats{line} = [recsats{line} body{line}(33:68)];
    end
    line = line + numsats*obslines + 1;
end

recdatestr = recdatestr(linedates);
recflag = recflag(linedates);
recsats = recsats(linedates);
recclockoffset = recclockoffset(linedates);
numdates = sum(linedates);

recsats  = vertcat(recsats{:});
recsats  = reshape(recsats',3,numdates*12)';
recsats  = recsats(recsats(:,3)~=' ',:);
satIDn   = computeSatID(string(recsats));
numRec  = length(satIDn);

dates = datetime(recdatestr,'InputFormat','yy MM dd HH mm ss.SSSSSSS');

tt = cumsum(linedates);
ii = tt(~linedates);
ii = ii(1:obslines:end);
recdatestr = dates(ii);
recflag = recflag(ii);
recclockoffset = recclockoffset(ii);




obsdata = body(~linedates);
for k=1:length(obsdata)
    obsdata{k}(81) = ' ';
end
obsmat  = vertcat(obsdata{:});
obsmat(obsmat == 0) = ' ';
obsmat = [obsmat(1:2:end-1,:) obsmat(2:2:end,:)];

obsmat2 = repmat( ' ', [numRec,19*constellationNumObs] );

for k =1:constellationNumObs
    offset1 = (k-1)*16;
    offset2 = (k-1)*19;
    obsmat2(:,offset2+(1:14)) = obsmat(:,offset1+(1:14));
    obsmat2(:,offset2+15)  = ',';
    obsmat2(:,offset2+16) = obsmat(:,offset1+15);
    obsmat2(:,offset2+17)  = ',';
    obsmat2(:,offset2+18) = obsmat(:,offset1+16);
    obsmat2(:,offset2+19)  = ',';
end

obslist = obsmat2';
obslist = obslist(:)';

vals=textscan(obslist,'%f %1d %1d','Delimiter',',','EmptyValue',0);

valobs  = reshape(vals{1},constellationNumObs,numRec)';
valflag = reshape(vals{2},constellationNumObs,numRec)';
valsnr  = reshape(vals{3},constellationNumObs,numRec)';

output.obs   = valobs;
output.flags = valflag;
output.snr   = valsnr;
output.dates = recdatestr;
output.satId = satIDn;
output.constellations = constellations;
output.obslist = constellationObs;
output.epochflag = recflag;
output.time_system = time_system;
output.offset_clock = recclockoffset;

