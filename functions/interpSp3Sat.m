function output = interpSp3Sat(sp3struct, satID, int_epoch)
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

Nterms = 9;

list_sats = satID;

output.reference_frame = sp3struct.reference_frame;
output.orbit_type      = sp3struct.orbit_type;
output.time_system     = sp3struct.time_system;


len_iepochs            = length(int_epoch);
len_list_sats          = length(list_sats);
trec                   = len_iepochs * len_list_sats;
output.pos.epoch       = repelem(NaT,trec)';
output.pos.id          = repelem(NaN,trec)';
output.pos.x           = repelem(NaN,trec)';
output.pos.y           = repelem(NaN,trec)';
output.pos.z           = repelem(NaN,trec)';
output.pos.clock       = repelem(NaN,trec)';


for k = 1:len_list_sats
    idsat     = startsWith(sp3struct.pos.id,list_sats{k});
    sat_epoch = sp3struct.pos.epoch(idsat);
    sat_pos   = [sp3struct.pos.x(idsat) sp3struct.pos.y(idsat) sp3struct.pos.z(idsat)];

    [sat_epoch,ii] = sort(sat_epoch);
    sat_pos        = sat_pos(ii,:);
    
    offsat        = (k-1)*len_iepochs;
    last_complete_interval_start = length(sat_epoch) - (Nterms-1);
    for t = 1:(Nterms-3):length(sat_epoch)
        if t > last_complete_interval_start
            t = last_complete_interval_start;
        end
        
        tt  = [t:(t+Nterms-1)];

        if t == 1
            xi = find((int_epoch>=sat_epoch(tt(1))) & (int_epoch<=sat_epoch(tt(end-1))));
        elseif t == last_complete_interval_start
            xi = find((int_epoch>=sat_epoch(tt(2))) & (int_epoch<=sat_epoch(tt(end))));
        else
            xi = find((int_epoch>=sat_epoch(tt(2))) & (int_epoch<=sat_epoch(tt(end-1))));
        end

        if ~isempty(xi)             
            x   = seconds(sat_epoch(tt)-sat_epoch(tt(1)));
            y   = sat_pos(tt,:);
            ipx = seconds(int_epoch(xi)-sat_epoch(tt(1)));
            output.pos.epoch(offsat+xi) = int_epoch(xi);
            output.pos.x(offsat+xi)     = iinterpLagr(x,y(:,1),ipx);
            output.pos.y(offsat+xi)     = iinterpLagr(x,y(:,2),ipx);
            output.pos.z(offsat+xi)     = iinterpLagr(x,y(:,3),ipx);
        end
    end
    output.pos.id(offsat+[1:(len_iepochs)]) = repelem(k,len_iepochs)';
end
    output.pos.id = list_sats(output.pos.id);
end


function sum = iinterpLagr(x,y,xi)

    sum = 0;
    
    if size(xi,2) > 1
        xi = xi';
    end
    
    if size(x,1) > 1
        x = x';
    end
    
    xi_x    = repmat(xi,1,length(x)) - repmat(x,length(xi),1);
    
    for k=1:length(x)
        id       = true(length(x),1);
        id(k)    = false;
        den      = prod(x(k)-x(id));
        num      = prod(xi_x(:,id),2);
        sum      = sum + y(k) * num/den;
    end
    
end




% % Compute Trig matrix
% 
% T = 86164.0905; % seconds
% Nterms = 9; % terms
% 
% dates = unique(sp3struct.pos.epoch);
% dt    = seconds(dates(2)-dates(1));
% 
% trigmat = trig_int_matrix(Nterms, Nterms, T, dt);
% 
% % Compute coefficient
% 
% id = startsWith(sp3struct.pos.id,"G26");
% x  = sp3struct.pos.x(id);
% pinv_trigmat = pinv(trigmat);
% coeff = pinv_trigmat*x(1:9);
% 
% output = trig_int_matrix(7200, Nterms, T, 1)*coeff;
% 
% % Select interp points per ti
% 
% % Interpolate
% 
% function trigmat = trig_int_matrix(Ndata, Nterms, T, dt)
% 
%     w = 2 * pi / T;
%     trigmat = zeros(Ndata,Nterms);
%     
%     nw  = [ 1 : (Nterms-1)/2 ];
%     nt = [ 0 : (Ndata-1) ]';  %[-(N-1)/2 : (N-1)/2]';
%     
%     trigmat(:,1)     = 1;
%     trigmat(:,2:2:Nterms) = cos((nt * dt) * (nw * w));
%     trigmat(:,3:2:Nterms) = sin((nt * dt) * (nw * w));
% end
    