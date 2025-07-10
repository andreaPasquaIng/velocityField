%% Plot PIVlab results and compute max velocity for each test
close all; clear all; clc;
f=1;

% Test name and directory
testName = 'test_6';
resultsFile = ['../', testName, '/results_', testName, '.mat'];
load(resultsFile);

% cylinder coordinate (initial)
cylinderCenter = [0.07 0.084];
cylinderRadius = 14/1000;  % 28 mm diameter
theta = linspace(0, 2*pi, 100);
xc = (cylinderCenter(1) + cylinderRadius * cos(theta));
yc = (cylinderCenter(2) + cylinderRadius * sin(theta));


% Number of frames
nFrames = size(u_original, 1);

% Grid setup (assumed constant across frames)
xSample = x{1,1};
ySample = y{1,1};
xVec = linspace(min(xSample(:)), max(xSample(:)), size(xSample,2));
yVec = linspace(min(ySample(:)), max(ySample(:)), size(ySample,1));
[X, Y] = meshgrid(xVec, yVec);

% Define finer grid (e.g., 2x finer)
scaleFactor = 2;
[X_fine, Y_fine] = meshgrid( ...
    linspace(min(xVec), max(xVec), scaleFactor * size(X,2)), ...
    linspace(min(yVec), max(yVec), scaleFactor * size(Y,1)) ...
);
interpolationMethod = 'linear';


% Preallocate
mag = cell(nFrames, 1);
umax = nan(nFrames,1);

shift = 5e-3;
for i = 240:nFrames

    % get the piv image and its roi
    rawImage = imread(sprintf('../%s/img_corrected/frame_%04d.png', testName, i)); 
    roiRect = [261 136 934 349]; % [x y width height] in pixels - adjust this
    roiImage = imcrop(rawImage, roiRect);
    
    % display piv image
    figure(f); clf;
    imagesc([min(xVec) max(xVec)], [min(yVec)-shift max(yVec)-shift], flipud(roiImage)); 
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
    quiver(X_fine, Y_fine, U, V, 5, 'g'); hold on;
    xlabel('x coordinate [m]'); ylabel('y coordinate [m]')
    axis equal;
    xlim([0.0264 0.2184]); ylim([0.0589 0.1229-shift])
    title(['Velocity field - Frame ', num2str(i)]);
    pause(0.2);

end

fprintf('Max velocity = %.5f m/s\n', max(umax));

time=linspace(0,nFrames/25,nFrames)';

% figure
% subplot(3,2,f)
plot(time,umax); hold on;
xlabel('Time [s]'); ylabel('Max velocity [m/s]')
% title(sprintf('Test %i',f))
f=f+1;
% end

