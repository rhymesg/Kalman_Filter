function verify_examples
% Check example packaging and outputs; this does not validate the filter theory.
% Scenarios and execution: tests/integration/examples/README.md.
root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
original_folder = pwd;
original_path = path;
original_rng = rng;
original_visibility = get(groot, 'defaultFigureVisible');
cleanup = onCleanup(@() restore_environment(original_folder, original_path, ...
    original_rng, original_visibility)); %#ok<NASGU>
set(groot, 'defaultFigureVisible', 'off');
addpath(fullfile(root, 'examples'));
cd(tempdir);

kf = execute_script(fullfile(root, 'examples', 'KF.m'));
check_output(kf, [6, 21, 100], [100; 100; 0; 5; 5; 0], 'KF');

assert(norm(kf.Q(1:3,4:6)-eye(3)*0.045, 'fro') < 1e-12, ...
    'Shared acceleration must correlate position and velocity errors.');

entry = execute_script(fullfile(root, 'main.m'));
assert(isequal(entry.estimates, kf.estimates), ...
    'main must reproduce the directly seeded KF estimates.');

tracking = execute_script(fullfile(root, 'examples', 'EKF_1.m'));
check_output(tracking, [6, 21, 100], [-10; -50; 0; -1; -2; 0], 'EKF_1');

p = tracking.relative_position;
h = 1e-5;
Hfd = zeros(3,3);
for j = 1:3
    d = zeros(3,1); d(j) = h;
    Hfd(:,j) = (observation(p+d)-observation(p-d))/(2*h);
end
assert(norm(tracking.H(:,1:3)-Hfd, 'fro') < 1e-7, ...
    'Tracking Jacobian must differentiate the implemented observation.');

terrain = execute_terrain;
check_output(terrain, [2, 101, 100], [2400; 400], 'EKF_2');
fprintf('All example integration checks passed.\n');
end

function result = execute_script(script_file)
% Isolate scripts that clear their calling workspace from the test driver.
rng(0, 'twister');
run(script_file);
result = struct('estimates', res_x_est, 'truth', x_true, ...
    'rmse', x_RMSE, 'covariance', P_diag, 'Q', Q, 'H', H);
if exist('pp', 'var')
    result.relative_position = pp;
end
end

function result = execute_terrain
% Invoke from outside examples/ to exercise script-relative terrain loading.
rng(0, 'twister');
EKF_2;
result = struct('estimates', res_x_est, 'truth', x_true, ...
    'rmse', x_RMSE, 'covariance', P_diag);
end

function check_output(result, expected_size, expected_endpoint, name)
assert(isequal(size(result.estimates), expected_size), ...
    '%s estimate dimensions do not match the documented simulation.', name);
assert(all(isfinite(result.estimates(:))), '%s produced nonfinite estimates.', name);
assert(all(isfinite(result.rmse(:))) && all(result.rmse(:) >= 0), ...
    '%s produced invalid RMSE values.', name);
assert(all(isfinite(result.covariance(:))) && all(result.covariance(:) >= -1e-12), ...
    '%s produced invalid covariance diagonals.', name);
assert(max(abs(result.truth(:,end) - expected_endpoint)) < 1e-10, ...
    '%s truth endpoint disagrees with its initial state and motion.', name);
end

function restore_environment(folder, original_path, original_rng, visibility)
close all;
cd(folder);
path(original_path);
rng(original_rng);
set(groot, 'defaultFigureVisible', visibility);
end

function z = observation(p)
z = [atan2(p(1),p(2)); atan2(p(3),hypot(p(1),p(2))); norm(p)];
end
