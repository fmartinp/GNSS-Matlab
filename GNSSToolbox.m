% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later

GNSSfolder = pwd;

if ismac || isunix
    delimiter = '/';
else ispc
    delimiter = '\';
end

addpath([pwd delimiter 'readers']);
addpath([pwd delimiter 'functions']);