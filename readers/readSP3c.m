function output = readSP3c(filePath)
%READSP3C SP3c reader
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
%   The function returns a struct with the data from a SP3c file
%   The output structure is composed by:
%   output.reference_frame -> reference frame of the data
%   output.orbit_type -> orbit type
%   output.time_system -> time system
%   output.pos.epoch -> epochs corresponding to the positions (array of datetimes)
%   output.pos.id -> satellited ID (array of strings)
%   output.pos.x -> array of x coordinate of the satellites;
%   output.pos.y -> array of y coordinate of the satellites;
%   output.pos.z -> array of x coordinate of the satellites;
%   output.pos.clock -> array of clock biases of the satellites;
%   output.vel.epoch = -> epochs corresponding to the velocities (array of datetimes)
%   output.vel.id -> satellited ID (array of strings)
%   output.vel.vx -> array of x-velocity of the satellites;
%   output.vel.vy -> array of y-velocity of the satellites;
%   output.vel.vz -> array of z-velocity of the satellites;
%   output.vel.clock_rate_chg -> array of clock rate changes of the satellites;



ff = fileread(filePath);
filebyline = regexp(ff, '\n', 'split');

reference_frame = filebyline{1}(47:51);
orbit_type = filebyline{1}(53:55);
num_sats = str2num(filebyline{3}(5:6));
num_epochs = str2num(filebyline{1}(33:39));
time_system = filebyline{13}(10:12);


if isempty(filebyline{end})
    body = filebyline(1:end-2);
else
    body = filebyline(1:end-1);
end
pat(1:length(body)) = {'* '};
iDate = cellfun(@startsWith,body,pat);

firstDate = find(iDate);
firstDate = firstDate(1);

body = body(firstDate:end);
iDate = iDate(firstDate:end);

recdates = body(iDate);
dates = datetime(recdates,'InputFormat','*  yyyy MM dd HH mm ss.SSSSSSSS');

tt = cumsum(iDate);
ii = tt(~iDate);
datesRec = dates(ii);

obsdata = body(~iDate);
for k=1:length(obsdata)
    obsdata{k}(81) = ' ';
end
obsmat  = vertcat(obsdata{:});
obsmat(obsmat == 0) = ' ';
parsed_data = textscan(obsmat(:,1:60)','%c%3c%f%f%f%f');

satID = computeSatID(string(parsed_data{2}));

ipos = find(parsed_data{1}=='P');
ivel = find(parsed_data{1}=='V');
output.reference_frame = reference_frame;
output.orbit_type = orbit_type;
output.time_system = time_system;
output.pos.epoch = datesRec(ipos)';
output.pos.id = satID(ipos);
output.pos.x = parsed_data{3}(ipos);
output.pos.y = parsed_data{4}(ipos);
output.pos.z = parsed_data{5}(ipos);
output.pos.clock = parsed_data{6}(ipos);
output.vel.epoch = datesRec(ivel)';
output.vel.id = satID(ivel);
output.vel.vx = parsed_data{3}(ivel);
output.vel.vy = parsed_data{4}(ivel);
output.vel.vz = parsed_data{5}(ivel);
output.vel.clock_rate_chg = parsed_data{6}(ivel);

end


