function [F, detail] = F_cost(xA, xB, xC, xD, xE)
% =========================================================
% F_cost: path length cost (0/1 occupancy)
%   F = sum(xA) + sum(xB) + sum(xC) + sum(xD) + sum(xE)
% =========================================================

    LA = sum(xA(:));
    LB = sum(xB(:));
    LC = sum(xC(:));
    LD = sum(xD(:));
    LE = sum(xE(:));

    F = LA + LB + LC + LD + LE;

    detail = struct();
    detail.LA = LA;
    detail.LB = LB;
    detail.LC = LC;
    detail.LD = LD;
    detail.LE = LE;
end