function F = F_enter(mesh, xA, xB, xC, xD, xE, pathA, pathB, pathC, pathD, pathE)

% For each path:
%   - the road incident to its src port must be 1
%   - the road incident to its dst port must be 1
%   - all OTHER port-roads must be 0
%
% Penalty:
%   sum over all port-roads r of (x_r - t_r)^2 , where t_r in {0,1}
%
% INPUT:
%   xA, xB, xC, xD, xE:
%       length-N 0/1 road occupancies for paths A/B/C/D/E
% =========================================================

    N = numel(mesh.roads);

    % --- precompute target vectors tA, tB, tC, tD, tE on PORT-ROADS only ---
    tA = zeros(N,1);
    tB = zeros(N,1);
    tC = zeros(N,1);
    tD = zeros(N,1);
    tE = zeros(N,1);

    % find the unique road id connected to each src/dst port
    ridA_src = portRoadId(mesh, pathA.src);
    ridA_dst = portRoadId(mesh, pathA.dst);

    ridB_src = portRoadId(mesh, pathB.src);
    ridB_dst = portRoadId(mesh, pathB.dst);

    ridC_src = portRoadId(mesh, pathC.src);
    ridC_dst = portRoadId(mesh, pathC.dst);

    ridD_src = portRoadId(mesh, pathD.src);
    ridD_dst = portRoadId(mesh, pathD.dst);

    ridE_src = portRoadId(mesh, pathE.src);
    ridE_dst = portRoadId(mesh, pathE.dst);

    tA([ridA_src, ridA_dst]) = 1;
    tB([ridB_src, ridB_dst]) = 1;
    tC([ridC_src, ridC_dst]) = 1;
    tD([ridD_src, ridD_dst]) = 1;
    tE([ridE_src, ridE_dst]) = 1;

    F = 0;

    % ---- Only iterate PORT-ROADS (roads touching any IN* or OUT*) ----
    for i = 1:N
        r = mesh.roads(i);

        isPortRoad = startsWith(r.n1,'IN')  || startsWith(r.n2,'IN') || ...
                     startsWith(r.n1,'OUT') || startsWith(r.n2,'OUT');

        if ~isPortRoad
            continue;
        end

        % Path A contribution (NO simplification)
        F = F + (xA(i) - tA(i))^2;

        % Path B contribution (NO simplification)
        F = F + (xB(i) - tB(i))^2;

        % Path C contribution (NO simplification)
        F = F + (xC(i) - tC(i))^2;

        % Path D contribution (NO simplification)
        F = F + (xD(i) - tD(i))^2;

        % Path E contribution (NO simplification)
        F = F + (xE(i) - tE(i))^2;
    end
end

function rid = portRoadId(mesh, portName)
% =========================================================
% Return the unique road index connected to a given port node.
% Works for 'IN#' or 'OUT#' in the mesh.
% =========================================================
    rid = [];
    for i = 1:numel(mesh.roads)
        r = mesh.roads(i);
        if strcmp(r.n1, portName) || strcmp(r.n2, portName)
            rid(end+1) = i; %#ok<AGROW>
        end
    end
    if isempty(rid)
        error('Port %s not found in any road.', portName);
    end
    if numel(rid) ~= 1
        error('Port %s connects to %d roads (expected 1).', portName, numel(rid));
    end
    rid = rid(1);
end