function satID = computeSatID(list_text_ids)
%COMPUTESATID Converts the satellite code to a numerical ID
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
% Input: Array of strings with the satellite code
% Output: String Array with satellite IDs after standarising the format

gblank = startsWith(list_text_ids," ");
list_text_ids(gblank) = "G" + extractAfter(list_text_ids(gblank),1);
pos = regexp(list_text_ids,repmat("G [0-9]",length(list_text_ids),1));

gblank = false(length(pos),1);

for k=1:length(pos)
    gblank(k) = ~isempty(pos{k});
end
list_text_ids(gblank) = "G0" + extractAfter(list_text_ids(gblank),2);


satID = list_text_ids;



% Output: Numeric array with the Sat ID code following the convention:
%         The ID is constructed as the sum of the PRN (or ID code) and 
%                           GPS (G)     = 1000
%                           GLONASS (R) = 2000
%                           GALILEO (E) = 3000
%                           QZSS (J)    = 4000
%                           BeiDou (C)  = 5000
%                           IRNSS (I)   = 6000
%                           SBAS (S)    = 7000
%                           LEO (L)     = 9000

% tt = strjoin(list_text_ids,' ');
% pos = find(tt{1}(1:4:end)==' ');
% if ~isempty(pos)
%     tt{1}(1+4*(pos-1)) = 'G';
% end
% 
% data = textscan(tt,'%c%d');
% satIDn  = zeros(length(data{1}),1);
% 
% satIDn(data{1} == ' ' ) = 1000;
% satIDn(data{1} == 'G' ) = 1000;
% satIDn(data{1} == 'R' ) = 2000;
% satIDn(data{1} == 'E' ) = 3000;
% satIDn(data{1} == 'J' ) = 4000;
% satIDn(data{1} == 'C' ) = 5000;
% satIDn(data{1} == 'I' ) = 6000;
% satIDn(data{1} == 'S' ) = 7000;
% satIDn(data{1} == 'L' ) = 9000;
% 
% satID = int32(satIDn) + data{2};

end

