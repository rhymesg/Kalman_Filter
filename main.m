% Run the introductory INS/GNSS example with a repeatable random stream.
% Setup, results, and citation: https://github.com/rhymesg/Kalman_Filter
rng(0, 'twister');
run(fullfile(fileparts(mfilename('fullpath')), 'examples', 'KF.m'));
