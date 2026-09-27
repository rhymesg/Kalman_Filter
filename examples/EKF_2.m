% Extended Kalman filter: terrain navigation; DOI: 10.5772/intechopen.80600.
% Reference and citation: https://github.com/rhymesg/Kalman_Filter/blob/master/docs/terrain-referenced-navigation.md


% Please cite the following book chapter if you find this code helpful.
%%% Y. Kim and H. Bang, Introduction to Kalman Filter and Its Applications, InTechOpen, 2018

% Example 3.3.2 - Terrain-referenced navigation

close all
clc
clear

%% settings

load(fullfile(fileparts(mfilename('fullpath')), 'DEM.mat'), 'DEM'); % load terrain database

N = 100; % number of time steps
dt = 1; % time between time steps
M = 100; % number of Monte-Carlo runs

sig_pro_true = [0.5; 0.5]; % true value of standard deviation of process noise
sig_mea_true = 3; % true value of standard deviation of measurement noise

sig_pro = [0.5; 0.5]; % user input of standard deviation of process noise
sig_mea = 3; % user input of standard deviation of measurement noise

sig_init = [20; 20]; % standard deviation of initial guess

Q = diag(sig_pro.^2); % process noise covariance matrix
R = diag(sig_mea.^2); % measurement noise covariance matrix

F = eye(2); % state transition matrix
B = eye(2); % control-input matrix

u = zeros(2,1); % control vector - to be determined
H = zeros(3,6); % measurement matrix - to be determined

%% true trajectory

% aircraft trajectory
x_true = zeros(2,N+1); 
x_true(:,1) = [400; 400]; % initial true state
u = [20; 0];
for k = 2:1:N+1
    x_true(:,k) = F*x_true(:,k-1) + B*u;
end

%% extended Kalman filter simulation

res_x_est = zeros(2,N+1,M); % Monte-Carlo estimates
res_x_err = zeros(2,N+1,M); % Monte-Carlo estimate errors
P_diag = zeros(2,N+1); % diagonal term of error covariance matrix

% filtering
for m = 1:1:M
    % initial guess
    x_est(:,1) = x_true(:,1) + normrnd(0, sig_init);
    P = diag(sig_init.^2);
    P_diag(:,1) = diag(P);
    for k = 2:1:N+1
        
        %%% Prediction
        
        % translation
        u_p = u + normrnd(0, sig_pro_true);
        
        % predicted state estimate
        x_est(:,k) = F*x_est(:,k-1) + B*u_p;
        
        % predicted error covariance
        P = F*P*F' + Q;
        
        %%% Update
        % obtain measurement
        z = DEM_height(x_true(:,k), DEM) + normrnd(0, sig_mea_true);
        
        % predicted meausrement
        z_p = DEM_height(x_est(:,k), DEM);
        
        % measurement residual
        y = z - z_p;
        
        % measurement matrix
        [grad_x, grad_y] = DEM_grad(x_est(:,k), DEM);
        H = [grad_x, grad_y];
                
        % Kalman gain
        K = P*H'/(R+H*P*H');
        
        % updated state estimate
        x_est(:,k) = x_est(:,k) + K*y;
        
        % updated error covariance
        P = (eye(2) - K*H)*P;
        
        P_diag(:,k) = diag(P);
        
        res_d_err(k,m) = norm(x_est(:,k) - x_true(:,k));
    end
    
    res_x_est(:,:,m) = x_est;
    res_x_err(:,:,m) = x_est - x_true;
end

%% get result statistics

x_est_avg = mean(res_x_est,3);
x_err_avg = mean(res_x_err,3);
x_RMSE = zeros(2,N+1); % root mean square error
for k = 1:1:N+1
    x_RMSE(1,k) = sqrt(mean(res_x_err(1,k,:).^2,3));
    x_RMSE(2,k) = sqrt(mean(res_x_err(2,k,:).^2,3));
end

%% plot

% plot terrain
y_max = 100;
y_min = 1;
x_max = 100;
x_min = 1;
resolution = 30;

x_mesh              = x_min:4:x_max;
y_mesh              = y_min:4:y_max;
[X_mesh, Y_mesh]    = meshgrid(x_mesh, y_mesh);
z_mesh              = DEM(x_mesh, y_mesh)';

z_mesh(1,1) = min(min(z_mesh));
z_mesh(1,2) = max(max(z_mesh));

[xi, yi] = meshgrid(x_min:1:x_max, y_min:1:y_max);

zi = interp2(X_mesh, Y_mesh, z_mesh, xi, yi, 'spline');

figure('Name', 'Figure 8: Terrain contours', 'NumberTitle', 'off', 'Tag', 'chapter-figure-08');
contourf(xi,yi,zi, 8)
colormap('gray');
hold on;
axis ([x_min x_max y_min y_max]);
axis equal;

%%
% estimation result
time = (0:1:N)*dt;

figure('Name', 'Figure 9: Terrain navigation RMSE', 'NumberTitle', 'off', 'Tag', 'chapter-figure-09');
subplot(2,1,1); hold on;
plot(time, x_RMSE(1,:), 'linewidth', 2);
legend({'RMSE'}, 'fontsize', 12);
ylabel('X error', 'fontsize', 12); grid on;

subplot(2,1,2); hold on;
plot(time, x_RMSE(2,:), 'linewidth', 2);
ylabel('Y error', 'fontsize', 12); grid on;
xlabel('Time');


%% function to get gradient of DEM
function [ grad_x, grad_y ] = DEM_grad( pos, DEM )

diff = 5;

x1 = pos(1) - diff;
x2 = pos(1) + diff;
y1 = pos(2) - diff;
y2 = pos(2) + diff;

grad_x = (DEM_height([x2; pos(2)], DEM) - DEM_height([x1; pos(2)], DEM))/(x2-x1);
grad_y = (DEM_height([pos(1); y2], DEM) - DEM_height([pos(1); y1], DEM))/(y2-y1);

end

%% function to get DEM data
function [ height ] = DEM_height( pos, DEM )

resolution = 30;

indx = floor(pos(1)/resolution);
indy = floor(pos(2)/resolution);

X = indx-2:1:indx+2;
Y = indy-2:1:indy+2;

% deal with a small area for computiational efficiency of interpolation
DEM_part = DEM(indx-2:indx+2, indy-2:indy+2); 

% interpolation
height = interp2(Y, X, DEM_part, pos(2)/resolution, pos(1)/resolution, 'cubic');
end