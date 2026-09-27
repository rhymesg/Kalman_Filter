% Linear Kalman filter: INS/GNSS; DOI: 10.5772/intechopen.80600.
% Reference and citation: https://github.com/rhymesg/Kalman_Filter/blob/master/docs/kalman-filter.md


% Please cite the following book chapter if you find this code helpful.
%%% Y. Kim and H. Bang, Introduction to Kalman Filter and Its Applications, InTechOpen, 2018

% Example 2.3 - INS/GNSS navigation

close all
clc
clear

%% settings

N = 20; % number of time steps
dt = 1; % time between time steps
M = 100; % number of Monte-Carlo runs

sig_acc_true = [0.3; 0.3; 0.3]; % true value of standard deviation of accelerometer noise
sig_gps_true = [3; 3; 3; 0.03; 0.03; 0.03]; % true value of standard deviation of GPS noise

sig_acc = [0.3; 0.3; 0.3]; % user input of standard deviation of accelerometer noise
sig_gps = [3; 3; 3; 0.03; 0.03; 0.03]; % user input of standard deviation of GPS noise

Q = [diag(0.25*dt^4*sig_acc.^2), zeros(3); zeros(3), diag(dt^2*sig_acc.^2)]; % process noise covariance matrix
R = [diag(sig_gps(1:3).^2), zeros(3); zeros(3), diag(sig_gps(4:6).^2)]; % measurement noise covariance matrix

F = [eye(3), eye(3)*dt; zeros(3), eye(3)]; % state transition matrix
B = [0.5*eye(3)*dt^2; eye(3)*dt]; % control-input matrix
H = eye(6); % measurement matrix


%% true trajectory

x_true = zeros(6,N+1); % true state
a_true = zeros(3,N);   % true acceleration

x_true(:,1) = [0; 0; 0; 5; 5; 0]; % initial true state
for k = 2:1:N+1
    x_true(:,k) = F*x_true(:,k-1) + B*a_true(:,k-1);
end

%% Kalman filter simulation

res_x_est = zeros(6,N+1,M); % Monte-Carlo estimates
res_x_err = zeros(6,N+1,M); % Monte-Carlo estimate errors
P_diag = zeros(6,N+1); % diagonal term of error covariance matrix

% filtering
for m = 1:1:M
    % initial guess
    x_est(:,1) = [2; -2; 0; 5; 5.1; 0.1];
    P = [eye(3)*4^2, zeros(3); zeros(3), eye(3)*0.4^2];
    P_diag(:,1) = diag(P);
    for k = 2:1:N+1
        
        %%% Prediction
        % obtain acceleration output
        u = a_true(:,k-1) + normrnd(0, sig_acc_true);
        
        % predicted state estimate
        x_est(:,k) = F*x_est(:,k-1) + B*u;
        
        % predicted error covariance
        P = F*P*F' + Q;
        
        %%% Update
        % obtain measurement
        z = x_true(:,k) + normrnd(0, sig_gps_true);
        
        % measurement residual
        y = z - H*x_est(:,k);
        
        % Kalman gain
        K = P*H'/(R+H*P*H');
        
        % updated state estimate
        x_est(:,k) = x_est(:,k) + K*y;
        
        % updated error covariance
        P = (eye(6) - K*H)*P;
        
        P_diag(:,k) = diag(P);
    end
    
    res_x_est(:,:,m) = x_est;
    res_x_err(:,:,m) = x_est - x_true;
    
end

%% get result statistics

x_est_avg = mean(res_x_est,3);
x_err_avg = mean(res_x_err,3);
x_RMSE = zeros(3,N+1); % root mean square error
for k = 1:1:N+1
    x_RMSE(1,k) = sqrt(mean(res_x_err(1,k,:).^2,3));
    x_RMSE(2,k) = sqrt(mean(res_x_err(2,k,:).^2,3));
    x_RMSE(3,k) = sqrt(mean(res_x_err(3,k,:).^2,3));
    x_RMSE(4,k) = sqrt(mean(res_x_err(4,k,:).^2,3));
    x_RMSE(5,k) = sqrt(mean(res_x_err(5,k,:).^2,3));
    x_RMSE(6,k) = sqrt(mean(res_x_err(6,k,:).^2,3));
end

%% plot results

time = (0:1:N)*dt;

figure('Name', 'KF state estimates (additional plot)', 'NumberTitle', 'off');
subplot(2,1,1); hold on;
plot(time, x_true(1,:), 'linewidth', 2);
plot(time, res_x_est(1,:,1), '--', 'linewidth', 2);
legend({'True', 'Estimated'}, 'fontsize', 12);
ylabel('X position', 'fontsize', 12); grid on;

subplot(2,1,2); hold on;
plot(time, x_true(4,:), 'linewidth', 2);
plot(time, res_x_est(4,:,1), '--', 'linewidth', 2);
ylabel('X velocity', 'fontsize', 12); xlabel('Time', 'fontsize', 12); grid on;

figure('Name', 'Figure 2: KF uncertainty', 'NumberTitle', 'off', 'Tag', 'chapter-figure-02');
subplot(2,1,1); hold on;
plot(time, x_RMSE(1,:), 'linewidth', 2);
plot(time, sqrt(P_diag(1,:)), '--', 'linewidth', 2);
legend({'RMSE', 'Estimated'}, 'fontsize', 12);
ylabel('X position error std', 'fontsize', 12); grid on;

subplot(2,1,2); hold on;
plot(time, x_RMSE(4,:), 'linewidth', 2);
plot(time, sqrt(P_diag(4,:)), '--', 'linewidth', 2);
ylabel('X velocity error std', 'fontsize', 12); xlabel('Time', 'fontsize', 12); grid on;

figure('Name', 'Figure 1: KF estimation errors', 'NumberTitle', 'off', 'Tag', 'chapter-figure-01');
subplot(6,1,1); hold on;
plot(time, res_x_err(1,:,1));
plot(time, res_x_err(1,:,2));
ylabel('p_x', 'fontsize', 12); grid on;

subplot(6,1,2); hold on;
plot(time, res_x_err(2,:,1));
plot(time, res_x_err(2,:,2));
ylabel('p_y', 'fontsize', 12); grid on;

subplot(6,1,3); hold on;
plot(time, res_x_err(3,:,1));
plot(time, res_x_err(3,:,2));
ylabel('p_z', 'fontsize', 12); grid on;

subplot(6,1,4); hold on;
plot(time, res_x_err(4,:,1));
plot(time, res_x_err(4,:,2));
ylabel('v_x', 'fontsize', 12); grid on;

subplot(6,1,5); hold on;
plot(time, res_x_err(5,:,1));
plot(time, res_x_err(5,:,2));
ylabel('v_y', 'fontsize', 12); grid on;

subplot(6,1,6); hold on;
plot(time, res_x_err(6,:,1));
plot(time, res_x_err(6,:,2));
ylabel('v_z', 'fontsize', 12); xlabel('Time', 'fontsize', 12); grid on;