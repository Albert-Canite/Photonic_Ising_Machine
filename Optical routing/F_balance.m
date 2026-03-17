function [F, detail] = F_balance(xA, xB, xC, xD, xE)
% =========================================================
% K=5 paths:
%   LA = sum(xA), ..., LE = sum(xE)
%   S  = LA + LB + LC + LD + LE
%   F  = sum_p (K*Lp - S)^2
% =========================================================

    K  = 5;

    LA = sum(xA(:));
    LB = sum(xB(:));
    LC = sum(xC(:));
    LD = sum(xD(:));
    LE = sum(xE(:));

    S = LA + LB + LC + LD + LE;

    termA = (K*LA - S)^2;
    termB = (K*LB - S)^2;
    termC = (K*LC - S)^2;
    termD = (K*LD - S)^2;
    termE = (K*LE - S)^2;

    F = termA + termB + termC + termD + termE;

    detail = struct();
    detail.K = K;

    detail.LA = LA;
    detail.LB = LB;
    detail.LC = LC;
    detail.LD = LD;
    detail.LE = LE;

    detail.S = S;

    detail.termA = termA;
    detail.termB = termB;
    detail.termC = termC;
    detail.termD = termD;
    detail.termE = termE;
end