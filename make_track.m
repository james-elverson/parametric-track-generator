function track = main(imgFile, ds_target, saveName)

% make_track_from_image  Click centerline points on an image, scale to meters,
% resample, and compute s + curvature.
%
% Usage:
%   track = make_track_from_image("silverstone.png", 1.0);

if nargin < 1 || isempty(imgFile)
    error("You must provide an image filename, e.g. make_track_from_image('silverstone.png').");
end

if nargin < 2 || isempty(ds_target)
    ds_target = 1.0;
end

if nargin < 3 || isempty(saveName)
    saveName = "";
end

% ---- Load image ----
I = imread(imgFile);
figure; imshow(I); hold on;
title("Click centerline points in order. Press Enter when done.");
axis on;
if nargin < 2 || isempty(ds_target)
    ds_target = 1.0;
end

if nargin < 3
    saveName = "";
end

% 1) Click raw centerline points (in pixels)
[xp, yp] = ginput();
plot(xp, yp, "r.-", "LineWidth", 1.5);

% 2) Close the loop (append start point at end)
xp(end+1) = xp(1);
yp(end+1) = yp(1);
plot(xp, yp, "r-");

% 3) Ask user to click two points that are a known distance apart
title("Now click TWO points with known real-world distance between them (e.g., start/finish straight ends).");
[xs, ys] = ginput(2);
plot(xs, ys, "go-", "LineWidth", 2);

prompt = "Enter the real-world distance between the two green points (meters): ";
d_m = input(prompt);

d_pix = hypot(xs(2)-xs(1), ys(2)-ys(1));
m_per_pix = d_m / d_pix;

% Convert pixels -> meters in an arbitrary local frame
x = (xp - xp(1)) * m_per_pix;
y = -(yp - yp(1)) * m_per_pix;   % minus because image y increases downward

% 4) Build arc length s (meters)
ds_raw = hypot(diff(x), diff(y));
s_raw  = [0; cumsum(ds_raw)];

% 5) Resample to uniform spacing (IMPORTANT for clean curvature)
s_u = (0:ds_target:s_raw(end)).';
x_u = interp1(s_raw, x, s_u, "pchip");
y_u = interp1(s_raw, y, s_u, "pchip");

% Optional smoothing (helps a lot)
x_u = smoothdata(x_u, "sgolay", 21);
y_u = smoothdata(y_u, "sgolay", 21);

% 6) Compute heading psi and curvature kappa = dpsi/ds
dx = gradient(x_u, ds_target);
dy = gradient(y_u, ds_target);
psi = unwrap(atan2(dy, dx));
kappa = gradient(psi, ds_target);

% 7) Package track struct
track.x = x_u;
track.y = y_u;
track.s = s_u;
track.psi = psi;
track.kappa = kappa;
track.L = s_u(end);

% Plot sanity checks
figure; plot(track.x, track.y, "LineWidth", 2); axis equal; grid on
title("Track centerline (meters)");

figure; plot(track.s, track.kappa, "LineWidth", 2); grid on
xlabel("s [m]"); ylabel("\kappa [1/m]");
title("Curvature vs distance");
end


if strlength(saveName) > 0
    if ~isfolder("tracks"), mkdir("tracks"); end
    filename = fullfile("tracks", saveName + "_track.mat");
    save(filename, "track");
    fprintf("Saved track to: %s\n", filename);
end