% model_setup_file_generator.m
% This script defines planar surfaces for multiple experimental scenarios
% and saves corresponding MATLAB .mat files for downstream use.
%
% Scenarios included:
%  1. Metric-scale test chamber (6 planes: floor, N-panel, E/S/W reflectors, roof)
%  2. UCLA demo CAD (multiple walls, panels, roof, aluminum reflectors)
%  3. UCLA shade-only model (floor + 4 walls + roof)
%  4. Supplementary figure configurations (various panel/HMM states)
%
% Output .mat variables (per scenario):
%   - planeNormal     (Nx3 array of outward-pointing plane normals)
%   - planePoint      (Nx3 array of a point on each plane)
%   - planeTemp       (1xN vector of plane temperatures in °C)
%   - planeReflectance (1xN vector of plane reflectances [0-1])
%
% Usage:
%   Simply run this script. It will generate and save the following files:
%     • experiment_model_metric.mat
%     • ucla_demo_cad_0p58.mat
%     • ucla_demo_cad_0p95.mat
%     • ucla_demo_cad_panelsOff.mat
%     • ucla_demo_SHADE.mat
%     • ucla_demo_cad_squared_*.mat (multiple supplementary configs)

%% Helper: add a plane from three points
%   [n, p] = plane(P1, P2, P3) returns the normalized normal vector n
%   and a point p (centroid) on the plane defined by P1,P2,P3.

%% 1) Metric-scale Test Chamber
clearvars planeNormal planePoint
% Floor (plane 1)
[p1,p2,p3] = deal([0,0,0],[0,1,0],[1,0,0]);
[n,p] = plane(p1,p2,p3);
planeNormal = n; planePoint = p;
% North panel (plane 2)
[p1,p2,p3] = deal([0,1,0],[1,1,0],[0,1,1]);
[ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% East, South, West reflectors (planes 3-5)
reflectorPts = {
    {[1,0,0],[1,1,0],[1,0,2]}, ... % East
    {[0,0,0],[1,0,0],[0,0,2]}, ... % South
    {[0,0,0],[0,1,0],[0,0,2]}      % West
};
for k = 1:numel(reflectorPts)
    pts = reflectorPts{k};
    [ni,pi] = plane(pts{:});
    planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
end
% Roof (plane 6)
[p1,p2,p3] = deal([0,0,2],[1,0,2],[0,1,2]);
[ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;

% Temperatures and reflectances
mylar_r = 0.58;
planeTemp       = [25, 13, 13, 13, 35, 35];
planeReflectance = [0, mylar_r, mylar_r, mylar_r, mylar_r, 0];

save('experiment_model_metric.mat', 'planeNormal','planePoint','planeTemp','planeReflectance');

%% 2) UCLA Demo CAD (with panels and aluminum reflectors)
clearvars planeNormal planePoint
% Define primary surfaces: floor, panels, roof
% Floor
[p1,p2,p3] = deal([0,0,0],[0,10,0],[10,0,0]); [n,p] = plane(p1,p2,p3);
planeNormal = n; planePoint = p;
% North panel
[p1,p2,p3] = deal([3.5,9,0],[5,9,0],[5,9,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% NW, NE panels
panelCoords = {
    {[0.812,5.038,0],[2.425,7.836,0],[2.425,7.836,10]}, ... % NW
    {[7.588,7.841,0],[9.220,4.995,0],[7.588,7.841,10]}        % NE
};
for k=1:2
    [ni,pi] = plane(panelCoords{k}{:});
    planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
end
% SW opening (unused)
% ... omitted for clarity ...
% South & East reflectors
reflectPts = {
    {[5,0,0],[4,0,0],[4,0,10]}, ... % South
    {[9.5,5.161,0],[9.5,0,0],[9.5,0,10]} % East
};
for k=1:2
    [ni,pi] = plane(reflectPts{k}{:});
    planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
end
% Roof
[p1,p2,p3] = deal([0,0,10],[0,10,10],[10,0,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% Aluminum reflectors (angled)
al_offset = 0.35;
alPts = {
    {[2.55+al_offset,8.27,0],[3.22+al_offset,8.92,0],[3.22+al_offset,8.92,10]}, ... % left
    {[7.04-al_offset,8.82,0],[7.80-al_offset,8.18,0],[7.80-al_offset,8.18,10]}      % right
};
for k=1:2
    [ni,pi] = plane(alPts{k}{:});
    planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
end
% Save two reflectance variants
baseTemp = 29;
planeTemp       = [baseTemp, 13,13,13,35,35, baseTemp, baseTemp];
planeReflectance = [0,0,0,0,0, mylar_r, 0,     .9,        .9];
mylar_r = 0.58; save('ucla_demo_cad_0p58.mat', 'planeNormal','planePoint','planeTemp','planeReflectance');
mylar_r = 0.95; planeReflectance(6) = mylar_r; save('ucla_demo_cad_0p95.mat','planeNormal','planePoint','planeTemp','planeReflectance');

%% 3) UCLA Shade-only Model (no panels)
clearvars planeNormal planePoint
planeNormal = []; planePoint=[];
% Floor and four ambient walls + roof
faces = {
    {[0,0,0],[0,10,0],[10,0,0]}, ... % floor
    {[0,10,0],[0,10,10],[5,10,0]}, ... % north
    {[0,0,0],[0,0,10],[5,0,0]}, ...    % south
    {[10,10,0],[10,10,10],[10,0,0]}, ...% east
    {[0,0,0],[0,10,0],[0,0,10]}, ...    % west
    {[0,0,10],[0,10,10],[10,0,10]}       % roof
};
for k=1:numel(faces)
    [ni,pi] = plane(faces{k}{:});
    planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
end
planeTemp       = repmat(29,1,6);
planeReflectance = zeros(1,6);
save('ucla_demo_SHADE.mat','planeNormal','planePoint','planeTemp','planeReflectance');

%% 4) Supplementary Figure Model Variants
% (a) Panels off, no HMM
% (b) Panels on, no HMM
% (c) Panels on, HMM 58%%
% (d) Panels on, HMM 95%%

% Reuse UCLA CAD updated model geometry
clearvars planeNormal planePoint
% Floor
[p1,p2,p3] = deal([0,0,0],[0,10,0],[10,0,0]); [n,p] = plane(p1,p2,p3);
planeNormal = n; planePoint = p;
% North panel
[p1,p2,p3] = deal([3.5,9,0],[5,9,0],[5,9,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% NW panel
[p1,p2,p3] = deal([0.812,5.038,0],[2.425,7.836,0],[2.425,7.836,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% NE panel
[p1,p2,p3] = deal([7.588,7.841,0],[9.220,4.995,0],[7.588,7.841,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% West entrance (squared corner)
[p1,p2,p3] = deal([0.812,5.038,0],[0.812,0,0],[0.812,0,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% South reflector
[p1,p2,p3] = deal([5,0,0],[4,0,0],[4,0,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% East reflector
[p1,p2,p3] = deal([9.5,5.161,0],[9.5,0,0],[9.5,0,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% Roof
[p1,p2,p3] = deal([0,0,10],[0,10,10],[10,0,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
% Angled aluminum reflectors
al_offset = 0.35;
[p1,p2,p3] = deal([2.55+al_offset,8.27,0],[3.22+al_offset,8.92,0],[3.22+al_offset,8.92,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;
[p1,p2,p3] = deal([7.04-al_offset,8.82,0],[7.80-al_offset,8.18,0],[7.80-al_offset,8.18,10]); [ni,pi] = plane(p1,p2,p3);
planeNormal(end+1,:) = ni; planePoint(end+1,:) = pi;

% Common parameters
Ta = 29;             % Ambient air temp (°C)
T_panel_nom = 13;    % Nominal panel temp (°C)
HMM_refs = [0, 0.58, 0.95];

% (a) Panels off, no HMM
planeTemp       = repmat([Ta],1,size(planeNormal,1));
planeReflectance= zeros(1,size(planeNormal,1));
save('ucla_demo_cad_squared_POff_NoHMM.mat','planeNormal','planePoint','planeTemp','planeReflectance');

% (b) Panels on, no HMM
planeTemp       = [Ta, T_panel_nom, T_panel_nom, T_panel_nom, 35,35,29,29];
planeReflectance= zeros(1,size(planeNormal,1));
save('ucla_demo_cad_squared_POn_NoHMM.mat','planeNormal','planePoint','planeTemp','planeReflectance');

% (c) Panels on, HMM 58%%
planeTemp       = [Ta, T_panel_nom, T_panel_nom, T_panel_nom, 35,35,29,29];
planeReflectance= [0, 0, 0, 0, 0, 0, HMM_refs(2), HMM_refs(2)];
save('ucla_demo_cad_squared_POn_HMM58.mat','planeNormal','planePoint','planeTemp','planeReflectance');

% (d) Panels on, HMM 95%%
planeReflectance= [0, 0, 0, 0, 0, 0, HMM_refs(3), HMM_refs(3)];
save('ucla_demo_cad_squared_POn_HMM95.mat','planeNormal','planePoint','planeTemp','planeReflectance');

