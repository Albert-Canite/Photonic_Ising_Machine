function [F, detail] = F_road(xA, xB, xC, xD, xE)
% =========================================================
% Road conflict constraint for five paths:
%   F_road = sum_i sum_{p<q} x_p(i)*x_q(i)
% Each road can be used by at most one path
% xA, xB, xC, xD, xE in {0,1}, length Nroads
% =========================================================

    % ========= Basic check =========
    N = numel(xA);
    if numel(xB) ~= N || numel(xC) ~= N || numel(xD) ~= N || numel(xE) ~= N
        error('F_road: all input vectors must have the same length.');
    end

    % ========= Pairwise conflict =========
    AB = xA(:).*xB(:);
    AC = xA(:).*xC(:);
    AD = xA(:).*xD(:);
    AE = xA(:).*xE(:);

    BC = xB(:).*xC(:);
    BD = xB(:).*xD(:);
    BE = xB(:).*xE(:);

    CD = xC(:).*xD(:);
    CE = xC(:).*xE(:);

    DE = xD(:).*xE(:);

    % ========= Total penalty =========
    prod_all = AB + AC + AD + AE + BC + BD + BE + CD + CE + DE;
    F = sum(prod_all);

    % ========= Debug info =========
    detail = struct();
    detail.conflict_idx = find(prod_all > 0.5);
    detail.num_conflict = numel(detail.conflict_idx);

end