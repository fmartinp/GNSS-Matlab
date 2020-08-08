function output = readRNX3(filePath)
%READRNX3 RINEX 3 reader
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
%   The function returns a struct with the data from a RINEX 3 file
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
%    output.time_system -> Time system of the dates


ff = fileread(filePath);
filebyline = regexp(ff, '\n', 'split');

numLine = 0;
nconstellation=0;

while (true)
    numLine = numLine + 1;
    line = filebyline{numLine};
    splitLine = strsplit(line);
    
    if contains(line,'END OF HEADER')
        break;
    elseif contains(line,'SYS / # / OBS TYPES')
        nconstellation = nconstellation + 1;
        constellations(nconstellation) = line(1);
        
        constellationNumObs(nconstellation) = str2double(line(2:7));
        constellationObs{nconstellation} = splitLine(3:end - 7);
        
        if constellationNumObs(nconstellation) >13 %Two line case
            numLine = numLine + 1;
            line2 = filebyline{numLine};
            splitLine2 = strsplit(line2);
            constellationObs{nconstellation} = [constellationObs{nconstellation}, splitLine2(2:end - 7) ];
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

pat(1:length(body)) = {'>'};
iDate = cellfun(@contains,body,pat);

%% Read Date

recdates = body(iDate);

recdatestr = cell(length(recdates),1);
recnumsats = cell(length(recdates),1);
recflag    = cell(length(recdates),1);

for k=1:length(recdates)
    recdatestr{k} = recdates{k}(3:29);
    recflag{k}     = recdates{k}(32);
    recnumsats{k} = recdates{k}(33:35);
end

dates = datetime(recdatestr,'InputFormat','yyyy MM dd HH mm ss.SSSSSSS');

numSatRec         = textscan(strjoin(recnumsats,' '),'%d');
numSatRec         = numSatRec{1};
numRec            = sum(numSatRec);

iDateRec          = zeros(1,numRec);
posIncD           = cumsum(numSatRec(1:end-1))+1;

iDateRec(posIncD) = 1;
iDateRec(1)       = 1;
iDateRec          = cumsum(iDateRec);
dateRec           = dates(iDateRec);

recflag         = textscan(strjoin(recflag,' '),'%d');
recflag         = recflag{1};
recflag         = recflag(iDateRec);


%% Read observations

maxNumObsPerRecord = max(constellationNumObs);
obsdata = body(~iDate);

for k=1:length(obsdata)
    obsdata{k}(16*maxNumObsPerRecord+4) = ' ';
end
obsmat  = vertcat(obsdata{:});
obsmat(obsmat == 0) = ' ';

satIDn = computeSatID(string(obsmat(:,1:3)));

obsmat2 = repmat( ' ', [numRec,19*maxNumObsPerRecord] );

for k =1:maxNumObsPerRecord
    offset1 = (k-1)*16 + 3;
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

valobs  = reshape(vals{1},maxNumObsPerRecord,numRec)';
valflag = reshape(vals{2},maxNumObsPerRecord,numRec)';
valsnr  = reshape(vals{3},maxNumObsPerRecord,numRec)';


output.obs   = valobs;
output.flags = valflag;
output.snr   = valsnr;
output.dates = dateRec;
output.satId = satIDn;
output.constellations = constellations;
output.obslist = constellationObs;
output.epochflag = recflag;
output.time_system = time_system;
end