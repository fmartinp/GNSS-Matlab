function sum = interpLagr(x,y,xi)
% Copyright 2020 Fernando Martin <fmartinp@protonmail.com>
%
% This file is part of GNSS-Matlab Toolbox
%
% SPDX-License-Identifier: GPL-3.0-or-later

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