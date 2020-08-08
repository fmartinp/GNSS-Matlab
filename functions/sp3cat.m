function output = sp3cat(struct1,struct2)
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later
%
%   Detailed explanation goes here

    output.reference_frame = struct1.reference_frame;
    output.orbit_type      = struct1.orbit_type;
    output.time_system     = struct1.time_system;
    
    fields = fieldnames(output.pos);
    
    for k=1:length(fields)
        output.pos.(fields{k}) = [struct1.pos.(fields{k}); struct2.pos.(fields{k})];
    end
    
    fields = fieldnames(output.vel);
    
    for k=1:length(fields)
        output.vel.(fields{k}) = [struct1.vel.(fields{k}); struct2.vel.(fields{k})];
    end
end

