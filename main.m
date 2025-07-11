%% Plot PIVlab results and compute max velocity for each test
close all; clear all; clc;
f=1;

% switch case. Get initial frame, final frame, and test name
testID = 6;
switch testID
    case 1
        frame0 = 230;
        frame1 = 314;
        testName = 'test_1';
        shift = -0.0025;

    case 2
        frame0 = 202;
        frame1 = 279;
        testName = 'test_2';
        shift = -0.0025;

    case 3
        frame0 = 207;
        frame1 = 343;
        testName = 'test_3';
        shift = 0.005;

    case 4
        frame0 = 201;
        frame1 = 313;
        testName = 'test_4';
        shift = 0.005;

    case 5
        frame0 = 194;
        frame1 = 315;
        testName = 'test_5';
        shift = -0.001;

    case 6
        frame0 = 177;
        frame1 = 303;
        testName = 'test_6';
        shift = -0.001;

    otherwise
        sprintf("No Valid test_ID selected. You selected test_ID%i",testID)
end

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
umax = nan(nFrames,1);

% shift = 0.0;% 5e-3;
for i = 230:frame1

    % get the piv image and its roi
    rawImage = imread(sprintf('../%s/img_corrected/frame_%04d.png', testName, i)); 
    roiRect = [261 136 934 349]; % [x y width height] in pixels - adjust this
    roiImage = imcrop(rawImage, roiRect);
    
    % display piv image
    figure(f);
    imagesc([min(xVec) max(xVec)], [min(yVec) max(yVec)], flipud(roiImage)); 
    colormap gray; 
    set(gca, 'YDir', 'normal'); % Make Y axis increase upwards
    hold on;
    

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
    umax(i,1) = max(max(magFlipped));

    % Plot velocity vectors
    figure(f)
    quiver(X_fine, Y_fine+shift, U, V, 2, 'g'); hold on;
    % clf;

    % Plot velocity magnitude contours instead of streamlines
    % contourLevels = linspace(0.006, max(magFlipped(:)), 5);
    % contour(X_fine, Y_fine + shift, magFlipped, contourLevels, 'LineColor', 'y', 'LineWidth', 0.015);

    % axis options
    xlabel('x coordinate [m]'); ylabel('y coordinate [m]')
    axis equal;
    xlim([min(min(X_fine)) max(max(X_fine))]); ylim([min(min(Y_fine)) max(max(Y_fine))])
    title(sprintf('Test_%i, Velocity field - Frame %i',testID,i),interpreter="none");
    % pause(0.01);

end


