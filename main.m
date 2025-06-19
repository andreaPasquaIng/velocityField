%% Plot PIVlab results and compute max velocity for each test
close all; clear; clc;

% Test settings
testName = 'test_2';
resultsFile = ['../', testName, '/results_', testName, '.mat'];
load(resultsFile);

% Number of frames
nFrames = size(u_original, 1);

% Grid setup (assumed constant across frames)
xSample = x{1,1};
ySample = y{1,1};
xVec = linspace(min(xSample(:)), max(xSample(:)), size(xSample,2));
yVec = linspace(min(ySample(:)), max(ySample(:)), size(ySample,1));
[X, Y] = meshgrid(xVec, yVec);

% Define finer grid (e.g., 2x finer)
scaleFactor = 1;
[X_fine, Y_fine] = meshgrid( ...
    linspace(min(xVec), max(xVec), scaleFactor * size(X,2)), ...
    linspace(min(yVec), max(yVec), scaleFactor * size(Y,1)) ...
);
interpolationMethod = 'linear';


% Preallocate
mag = cell(nFrames, 1);

figure(1)
for i = 1:nFrames
    clf;  % Clear figure

    % Extract original velocity components
    u = u_original{i,1};
    v = v_original{i,1};
    mag{i} = sqrt(u.^2 + v.^2);

    % Compute unit vectors
    u_unit = u ./ mag{i};
    v_unit = v ./ mag{i};
    u_unit(~isfinite(u_unit)) = 0;
    v_unit(~isfinite(v_unit)) = 0;

    % Scale by magnitude
    u_scaled = u_unit .* mag{i};
    v_scaled = v_unit .* mag{i};

    % Interpolate to finer grid
    U_fine = interp2(X, Y, u_scaled, X_fine, Y_fine, interpolationMethod);
    V_fine = interp2(X, Y, v_scaled, X_fine, Y_fine, interpolationMethod);
    magFine = interp2(X, Y, mag{i}, X_fine, Y_fine, interpolationMethod);

    % Flip for plotting
    U = flipud(-U_fine);
    V = flipud(-V_fine);
    magFlipped = flipud(magFine);

    % Plot interpolated magnitude as contour
    contourf(X_fine, Y_fine, magFlipped, 16, 'LineStyle', 'none');
    hold on;

    % Plot interpolated vectors
    quiver(X_fine, Y_fine, U, V, 1, 'k');

    colorbar;
    axis equal;
    title(['Interpolated velocity field - Frame ', num2str(i)]);
    pause(0.1);
end

