% cleaned_radiant_temperature_simulation.m
% This script computes and visualizes Mean Radiant Temperature (MRT)
% in a modeled environment with varying numbers of reflective walls.
% Dependencies: experiment_model_metric.mat, rays.m, propagateRay_V1.m

clear; close all;

%-------------------------------
% Setup and Load Data
%-------------------------------
figNum     = 40;                 % Base figure number
fontsize   = 18;                 % Font size for plots

figure(figNum); clf;

data             = load('experiment_model_metric.mat');
planeNormal      = data.planeNormal;      % Normals of each plane
planePoint       = data.planePoint;       % Points on each plane
planeTemp        = data.planeTemp;        % Temperatures of each plane (ºC)
planeReflectance = data.planeReflectance; % Reflectance coefficients (0–1)

% Normalize plane normals once
magnitudes = vecnorm(planeNormal, 2, 2);
planeNormal = planeNormal ./ magnitudes;

% Experimental configurations
walls            = [1, 3];         % Number of reflective walls in each scenario
reflectanceArray = [0.58, 0.90];    % Reflectance values to test
numScenarios     = numel(walls);
numReflectances  = numel(reflectanceArray);

% Preallocate result arrays
averageMRT     = NaN(numScenarios, numReflectances);
centerPointMRT = NaN(numScenarios, numReflectances);

% Sampling grid definition
oz           = 1;   % Height of measurement plane (m)
surfX        = 1;   % Surface X dimension (m)
surfY        = 1;   % Surface Y dimension (m)
PPF          = 50; %100; % Points per meter (linear resolution)
surface_x    = linspace(0, surfX, PPF * surfX);
surface_y    = linspace(0, surfY, PPF * surfY);

% Hemisphere ray sampling
rayRes  = 300; %3800;         % Total number of rays per point
[x, y, z] = rays(rayRes);
numRays  = numel(x);

%-------------------------------
% Main computation loops
%-------------------------------
for rIdx = 1:numReflectances
    R = reflectanceArray(rIdx);
    fprintf('Reflectance R = %.2f: %.1f%% complete\n', R, rIdx/numReflectances*100);

    for sIdx = 1:numScenarios
        % Reset reflectance and temperature for all planes
        currentReflectance = zeros(size(planeReflectance));
        ambientTemp        = 22.5;                  % Ambient temperature (ºC)
        currentTemp        = ambientTemp * ones(size(planeTemp));

        % Active cooled panel at index 2 (north wall)
        cooledPanelTemp = 12; 
        currentTemp(2)  = cooledPanelTemp;

        % Assign reflectance to first N walls (east, south, west)
        numWalls = walls(sIdx);
        for w = 1:numWalls
            assert(w <= 3, 'Max 3 reflective walls allowed');
            currentReflectance(w + 2) = R;
        end

        % Precompute plane irradiance via Stefan–Boltzmann (T + 273 K)^4
        planeIrradiance = (currentTemp + 273).^4;

        % Prepare storage for surface temperatures
        temp2D = NaN(numel(surface_x), numel(surface_y));

        % Trace rays from each surface point
        for ix = 1:numel(surface_x)
            for iy = 1:numel(surface_y)
                origin = [surface_x(ix), surface_y(iy), oz];
                rayIrr = NaN(numRays, 1);

                for rr = 1:numRays
                    dir = [x(rr), y(rr), z(rr)];
                    rayIrr(rr) = propagateRay_V1(origin, dir, 1, ...
                        planeNormal, planePoint, planeIrradiance, currentReflectance);
                end

                % Convert mean irradiance back to temperature (ºC)
                temp2D(ix, iy) = mean(rayIrr)^(1/4) - 273;
            end
        end

        % Compute metrics
        averageMRT(sIdx, rIdx)     = mean(temp2D, 'all');
        midIdx                     = ceil(numel(surface_x)/2);
        centerPointMRT(sIdx, rIdx) = temp2D(midIdx, midIdx);

        %-------------------------------
        % Visualization (low-res)
        %-------------------------------
        subplot(2, 2, sIdx + (rIdx-1)*numScenarios);
        imagesc(surface_x, surface_y, temp2D');
        set(gca, 'YDir', 'normal', 'FontSize', fontsize, 'PlotBoxAspectRatio', [1 1 1]);
        xlabel('X (m)'); ylabel('Y (m)');
        title(sprintf('Walls: %d, R=%.2f', numWalls, R));
        cbar = colorbar;
        cbar.Label.String = 'MRT (ºC)';
        hold on;

        % Mark and annotate center point
        cx = surface_x(midIdx);
        cy = surface_y(midIdx);
        scatter(cx, cy, fontsize*3, 'filled', 'MarkerFaceColor', 'k');
        text(cx, cy+0.05, sprintf('%.1fºC', centerPointMRT(sIdx,rIdx)), ...
            'FontSize', fontsize, 'HorizontalAlignment', 'center');
    end
end

% Save the figure
saveas(gcf, sprintf('MRT_simulation_R%.2f_PPF%d_rays%d.png', R, PPF, rayRes));
