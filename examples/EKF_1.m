% Extended Kalman filter: target tracking; DOI: 10.5772/intechopen.80600.
% Reference and citation: https://github.com/rhymesg/Kalman_Filter/blob/master/docs/extended-kalman-filter.md


% Please cite the following book chapter if you find this code helpful.
%%% Y. Kim and H. Bang, Introduction to Kalman Filter and Its Applications, InTechOpen, 2018

% Example 3.3.1 - Target tracking

close all
clc
clear

%% settings

N = 20; % number of time steps
dt = 1; % time between time steps
M = 100; % number of Monte-Carlo runs

sig_mea_true = [0.02; 0.02; 1.0]; % true value of standard deviation of measurement noise

sig_pro = [0.5; 0.5; 0.5]; % user input of standard deviation of process noise
sig_mea = [0.02; 0.02; 1.0]; % user input of standard deviation of measurement noise

sig_init = [1; 1; 0; 0; 0; 0]; % standard deviation of initial guess

Q = [zeros(3), zeros(3); zeros(3), diag(sig_pro.^2)]; % process noise covariance matrix
R = diag(sig_mea.^2); % measurement noise covariance matrix

F = [eye(3), eye(3)*dt; zeros(3), eye(3)]; % state transition matrix
B = eye(6); % control-input matrix
u = zeros(6,1); % control vector

H = zeros(3, 6); % measurement matrix - to be determined

%% true trajectory

% sensor trajectory
p_sensor = zeros(3,N+1);
for k = 1:1:N+1
    p_sensor(1,k) = 20 + 20*cos(2*pi/30 * (k-1));
    p_sensor(2,k) = 20 + 20*sin(2*pi/30 * (k-1));
    p_sensor(3,k) = 50;
end

% true target trajectory
x_true = zeros(6,N+1); 
x_true(:,1) = [10; -10; 0; -1; -2; 0]; % initial true state
for k = 2:1:N+1
    x_true(:,k) = F*x_true(:,k-1) + B*u;
end

%% extended Kalman filter simulation

res_x_est = zeros(6,N+1,M); % Monte-Carlo estimates
res_x_err = zeros(6,N+1,M); % Monte-Carlo estimate errors
P_diag = zeros(6,N+1); % diagonal term of error covariance matrix

% filtering
for m = 1:1:M
    % initial guess
    x_est(:,1) = x_true(:,1) + normrnd(0, sig_init);
    P = diag(sig_init.^2);
    P_diag(:,1) = diag(P);
    for k = 2:1:N+1
        
        %%% Prediction
      
        % predicted state estimate
        x_est(:,k) = F*x_est(:,k-1) + B*u;
        
        % predicted error covariance
        P = F*P*F' + Q;
        
        %%% Update
        % obtain measurement
        p = x_true(1:3,k) - p_sensor(:,k); % true relative position
        z_true = [atan2(p(1), p(2));
                  atan2(p(3), sqrt(p(1)^2 + p(2)^2));
                  norm(p)]; % true measurement
              
        z = z_true + normrnd(0, sig_mea_true); % erroneous measurement
        
        % predicted meausrement
        pp = x_est(1:3,k) - p_sensor(:,k); % predicted relative position
        z_p = [atan2(pp(1), pp(2));
               atan2(pp(3), sqrt(pp(1)^2 + pp(2)^2));
               norm(pp)]; % predicted measurement
        
        % measurement residual
        y = z - z_p;
        y(1:2) = atan2(sin(y(1:2)), cos(y(1:2)));
        
        % measurement matrix
        H = [pp(2)/(pp(1)^2+pp(2)^2), -pp(1)/(pp(1)^2+pp(2)^2), 0, zeros(1,3);
            -pp(1)*pp(3)/(pp'*pp)/norm(pp(1:2)), -pp(2)*pp(3)/(pp'*pp)/norm(pp(1:2)), norm(pp(1:2))/(pp'*pp), zeros(1,3);
            pp(1)/norm(pp), pp(2)/norm(pp), pp(3)/norm(pp), zeros(1,3)];
                
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
x_RMSE = zeros(6,N+1); % root mean square error
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

figure('Name', 'Figure 4: Target state estimates', 'NumberTitle', 'off', 'Tag', 'chapter-figure-04');
subplot(2,1,1); hold on;
plot(time, x_true(1,:), 'linewidth', 2);
plot(time, res_x_est(1,:,1), '--', 'linewidth', 2);
legend({'True', 'Estimated'}, 'fontsize', 12);
ylabel('X position', 'fontsize', 12); grid on;

subplot(2,1,2); hold on;
plot(time, x_true(4,:), 'linewidth', 2);
plot(time, res_x_est(4,:,1), '--', 'linewidth', 2);
ylabel('X velocity', 'fontsize', 12); xlabel('Time', 'fontsize', 12); grid on;

figure('Name', 'Figure 5: Target uncertainty', 'NumberTitle', 'off', 'Tag', 'chapter-figure-05');
subplot(2,1,1); hold on;
plot(time, x_RMSE(1,:), 'linewidth', 2);
plot(time, sqrt(P_diag(1,:)), '--', 'linewidth', 2);
legend({'RMSE', 'Estimated'}, 'fontsize', 12);
ylabel('X position error std', 'fontsize', 12); grid on;

subplot(2,1,2); hold on;
plot(time, x_RMSE(4,:), 'linewidth', 2);
plot(time, sqrt(P_diag(4,:)), '--', 'linewidth', 2);
ylabel('X velocity error std', 'fontsize', 12); xlabel('Time', 'fontsize', 12); grid on;

figure('Name', 'Figure 3: Sensor and target trajectories', 'NumberTitle', 'off', 'Tag', 'chapter-figure-03');
plot(p_sensor(1,:), p_sensor(2,:), 'linewidth', 2); hold on;
plot(x_true(1,:), x_true(2,:), 'linewidth', 2); hold on;
legend({'Sensor', 'Target'}, 'fontsize', 12);
xlabel('X', 'fontsize', 12); ylabel('Y', 'fontsize', 12);
axis equal;
