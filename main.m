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

% Preallocate
mag = cell(nFrames, 1);

% Plot loop
figure(1)
for i = 1:nFrames
    clf  % Clear figure

    % Extract velocity components
    u = u_original{i,1};
    v = v_original{i,1};

    % Compute magnitude
    mag{i} = sqrt(u.^2 + v.^2);

    % Compute direction unit vectors
    u_unit = u ./ mag{i};
    v_unit = v ./ mag{i};

    % Handle division by zero (avoid NaNs/Infs)
    u_unit(~isfinite(u_unit)) = 0;
    v_unit(~isfinite(v_unit)) = 0;

    % Scale unit vectors by magnitude again (effectively same as u, v, but explicit)
    u_scaled = u_unit .* mag{i};
    v_scaled = v_unit .* mag{i};

    % Flip for plotting
    magFlipped = flipud(mag{i});
    U = flipud(-u_scaled);
    V = flipud(-v_scaled);

    % Plot magnitude as contour
    contourf(X, Y, magFlipped, 16, 'LineStyle', 'none');
    hold on

    % Plot vectors: direction + magnitude
    quiver(X, Y, U, V, 'k')  % 0 = no auto-scaling

    colorbar
    axis equal
    title(['Velocity magnitude and direction - Frame ', num2str(i)])
    pause(0.1)
end
