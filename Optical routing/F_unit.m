function [F, detail] = F_unit(mesh, xA, xB, xC, xD, xE)

% =========================================================

    % ========= Basic check =========
    N = numel(mesh.roads);
    if numel(xA) ~= N || numel(xB) ~= N || numel(xC) ~= N || numel(xD) ~= N || numel(xE) ~= N
       error('F_unit: the lengths of xA, xB, xC, xD, and xE must equal numel(mesh.roads) = %d', N);
    end

  
    node_eq4 = build_node_eq4_table();

    nodeNames = fieldnames(node_eq4);
    M = numel(nodeNames);

    % ========= Accumulate node by node =========
    F = 0;

    resA = zeros(M,1);
    resB = zeros(M,1);
    resC = zeros(M,1);
    resD = zeros(M,1);
    resE = zeros(M,1);

    allOnA = false(M,1);
    allOnB = false(M,1);
    allOnC = false(M,1);
    allOnD = false(M,1);
    allOnE = false(M,1);

    for k = 1:M
        node = nodeNames{k};
        r = node_eq4.(node);

        % --- Extract the occupancy states (0/1) of the four roads ---
        x1A = xA(r(1)); x2A = xA(r(2)); x3A = xA(r(3)); x4A = xA(r(4));
        x1B = xB(r(1)); x2B = xB(r(2)); x3B = xB(r(3)); x4B = xB(r(4));
        x1C = xC(r(1)); x2C = xC(r(2)); x3C = xC(r(3)); x4C = xC(r(4));
        x1D = xD(r(1)); x2D = xD(r(2)); x3D = xD(r(3)); x4D = xD(r(4));
        x1E = xE(r(1)); x2E = xE(r(2)); x3E = xE(r(3)); x4E = xE(r(4));

        % =====================================================
        % H node: flow-conservation constraint
        % (A/B/C/D/E are treated independently)
        % =====================================================
        if startsWith(node, 'H')
            vA = (x1A + x2A - x3A - x4A);
            vB = (x1B + x2B - x3B - x4B);
            vC = (x1C + x2C - x3C - x4C);
            vD = (x1D + x2D - x3D - x4D);
            vE = (x1E + x2E - x3E - x4E);

            F = F + vA^2 + vB^2 + vC^2 + vD^2 + vE^2;

            resA(k) = vA;
            resB(k) = vB;
            resC(k) = vC;
            resD(k) = vD;
            resE(k) = vE;

        % =====================================================
        % V node: only cross state is allowed
        % (A/B/C/D/E are treated independently)
        % cross: (1↔4, 2↔3)
        % =====================================================
        elseif startsWith(node, 'V')
            F = F ...
                + (x1A - x4A)^2 + (x2A - x3A)^2 ...
                + (x1B - x4B)^2 + (x2B - x3B)^2 ...
                + (x1C - x4C)^2 + (x2C - x3C)^2 ...
                + (x1D - x4D)^2 + (x2D - x3D)^2 ...
                + (x1E - x4E)^2 + (x2E - x3E)^2;

            % Only recorded for debugging (not included in the penalty)
            resA(k) = (x1A + x2A - x3A - x4A);
            resB(k) = (x1B + x2B - x3B - x4B);
            resC(k) = (x1C + x2C - x3C - x4C);
            resD(k) = (x1D + x2D - x3D - x4D);
            resE(k) = (x1E + x2E - x3E - x4E);
        end

      
    end

    % ========= Output debug information =========
    if nargout > 1
        detail = struct();
        detail.nodeNames = nodeNames;
        detail.node_eq4  = node_eq4;

        detail.resA = resA;
        detail.resB = resB;
        detail.resC = resC;
        detail.resD = resD;
        detail.resE = resE;

        detail.badA = nodeNames(resA ~= 0);
        detail.badB = nodeNames(resB ~= 0);
        detail.badC = nodeNames(resC ~= 0);
        detail.badD = nodeNames(resD ~= 0);
        detail.badE = nodeNames(resE ~= 0);

        detail.allOnA = nodeNames(allOnA);
        detail.allOnB = nodeNames(allOnB);
        detail.allOnC = nodeNames(allOnC);
        detail.allOnD = nodeNames(allOnD);
        detail.allOnE = nodeNames(allOnE);

        detail.P_all = P_all;
        detail.numNodes = M;
    end
end

% =========================================================
% Subfunction: construct the manual mapping table
% node -> [r1 r2 r3 r4]
% =========================================================
function node_eq4 = build_node_eq4_table()
    node_eq4 = struct();

    % -------------------------
    % V nodes (20 total) — the pattern is highly regular:
    % V1 : (H1,H2) | (H7,H8)   -> [11 12 13 14]
    % V2 : (H2,H3) | (H8,H9)   -> [15 16 17 18]
    % ...
    % V20: (H23,H24)|(H29,H30) -> [87 88 89 90]
    % -------------------------
    node_eq4.V1  = [11 12 13 14];
    node_eq4.V2  = [15 16 17 18];
    node_eq4.V3  = [19 20 21 22];
    node_eq4.V4  = [23 24 25 26];
    node_eq4.V5  = [27 28 29 30];
    node_eq4.V6  = [31 32 33 34];
    node_eq4.V7  = [35 36 37 38];
    node_eq4.V8  = [39 40 41 42];
    node_eq4.V9  = [43 44 45 46];
    node_eq4.V10 = [47 48 49 50];

    node_eq4.V11 = [51 52 53 54];
    node_eq4.V12 = [55 56 57 58];
    node_eq4.V13 = [59 60 61 62];
    node_eq4.V14 = [63 64 65 66];
    node_eq4.V15 = [67 68 69 70];
    node_eq4.V16 = [71 72 73 74];
    node_eq4.V17 = [75 76 77 78];
    node_eq4.V18 = [79 80 81 82];
    node_eq4.V19 = [83 84 85 86];
    node_eq4.V20 = [87 88 89 90];

    % -------------------------
    % H nodes (30 total)
  
    node_eq4.H1  = [91 92 1 11];

    % H2: [1(H1),2(H3),12(V1),15(V2)] -> H-side pair (1,2), V-side pair (12,15)
    node_eq4.H2  = [1 12 2 15];

    % H3: [2(H2),3(H4),16(V2),19(V3)]
    node_eq4.H3  = [2 16 3 19];

    % H4: [3(H3),4(H5),20(V3),23(V4)]
    node_eq4.H4  = [3 20 4 23];

    % H5: [4(H4),5(H6),24(V4),27(V5)]
    node_eq4.H5  = [4 24 5 27];

    % H6: [5(H5),28(V5),101(OUT1),102(OUT2)] -> port-side pair (101,102), opposite side (5,28)
    node_eq4.H6  = [5 28 101 102];

    % H7: [13(V1),31(V6),93(IN3),94(IN4)] -> port-side pair (93,94), V-side pair (13,31)
    node_eq4.H7  = [93 94 13 31];

    % H8: [14(V1),17(V2),32(V6),35(V7)]
    node_eq4.H8  = [14 32 17 35];

    % H9: [18(V2),21(V3),36(V7),39(V8)]
    node_eq4.H9  = [18 36 21 39];

    % H10: [22(V3),25(V4),40(V8),43(V9)]
    node_eq4.H10 = [22 40 25 43];

    % H11: [26(V4),29(V5),44(V9),47(V10)]
    node_eq4.H11 = [26 44 29 47];

    % H12: [30(V5),48(V10),103(OUT3),104(OUT4)] -> port-side pair (103,104), V-side pair (30,48)
    node_eq4.H12 = [30 48 103 104];

    % H13: [33(V6),51(V11),95(IN5),96(IN6)] -> port-side pair (95,96), V-side pair (33,51)
    node_eq4.H13 = [95 96 33 51];

    % H14: [34(V6),37(V7),52(V11),55(V12)]
    node_eq4.H14 = [34 52 37 55];

    % H15: [38(V7),41(V8),56(V12),59(V13)]
    node_eq4.H15 = [38 56 41 59];

    % H16: [42(V8),45(V9),60(V13),63(V14)]
    node_eq4.H16 = [42 60 45 63];

    % H17: [46(V9),49(V10),64(V14),67(V15)]
    node_eq4.H17 = [46 64 49 67];

    % H18: [50(V10),68(V15),105(OUT5),106(OUT6)] -> port-side pair (105,106), V-side pair (50,68)
    node_eq4.H18 = [50 68 105 106];

    % H19: [53(V11),71(V16),97(IN7),98(IN8)] -> port-side pair (97,98), V-side pair (53,71)
    node_eq4.H19 = [97 98 53 71];

    % H20: [54(V11),57(V12),72(V16),75(V17)]
    node_eq4.H20 = [54 72 57 75];

    % H21: [58(V12),61(V13),76(V17),79(V18)]
    node_eq4.H21 = [58 76 61 79];

    % H22: [62(V13),65(V14),80(V18),83(V19)]
    node_eq4.H22 = [62 80 65 83];

    % H23: [66(V14),69(V15),84(V19),87(V20)]
    node_eq4.H23 = [66 84 69 87];

    % H24: [70(V15),88(V20),107(OUT7),108(OUT8)] -> port-side pair (107,108), V-side pair (70,88)
    node_eq4.H24 = [70 88 107 108];

    % H25: [6(H26),73(V16),99(IN9),100(IN10)] -> port-side pair (99,100), opposite side (6,73)
    node_eq4.H25 = [99 100 6 73];

    % H26: [6(H25),7(H27),74(V16),77(V17)] -> H-side pair (6,7), V-side pair (74,77)
    node_eq4.H26 = [6 74 7 77];

    % H27: [7(H26),8(H28),78(V17),81(V18)]
    node_eq4.H27 = [7 78 8 81];

    % H28: [8(H27),9(H29),82(V18),85(V19)]
    node_eq4.H28 = [8 82 9 85];

    % H29: [9(H28),10(H30),86(V19),89(V20)]
    node_eq4.H29 = [9 86 10 89];

    % H30: [10(H29),90(V20),109(OUT9),110(OUT10)] -> port-side pair (109,110), opposite side (10,90)
    node_eq4.H30 = [10 90 109 110];
end