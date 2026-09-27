function files = generate_figures(numbers, output_directory, seed)
% Export selected chapter figures using the current examples, not historical curves.
% Usage and provenance: docs/figures.md.
root = fileparts(mfilename('fullpath'));
if nargin < 1
    numbers = [1, 2, 3, 4, 5, 8, 9];
end
if nargin < 2
    output_directory = fullfile(root, 'figures');
end
if nargin < 3
    seed = 0;
end
validateattributes(numbers, {'numeric'}, {'vector', 'nonempty', 'real', 'finite', 'integer', '>=', 1, '<=', 9});
validateattributes(seed, {'numeric'}, {'scalar', 'real', 'finite', 'integer', '>=', 0, '<=', 2^32-1});
if ~all(ismember(numbers, [1, 2, 3, 4, 5, 8, 9]))
    error('KalmanFilter:NotSimulationFigure', 'Figures 6 and 7 are explanatory diagrams, not simulation plots.');
end
numbers = unique(numbers(:)');
if ~(ischar(output_directory) && isrow(output_directory)) && ...
        ~(isstring(output_directory) && isscalar(output_directory))
    error('KalmanFilter:OutputDirectory', 'Output directory must be a character row or scalar string.');
end
output_directory = char(output_directory);
if isempty(output_directory)
    error('KalmanFilter:OutputDirectory', 'Output directory must not be empty.');
end
if ~exist(output_directory, 'dir')
    [created, message] = mkdir(output_directory);
    assert(created, 'KalmanFilter:OutputDirectory', '%s', message);
end

original_rng = rng;
original_visibility = get(groot, 'defaultFigureVisible');
cleanup = onCleanup(@() restore_environment(original_rng, original_visibility)); %#ok<NASGU>
set(groot, 'defaultFigureVisible', 'off');
groups = {[1, 2], [3, 4, 5], [8, 9]};
scripts = {'KF.m', 'EKF_1.m', 'EKF_2.m'};
files = cell(0, 1);

for group = 1:numel(groups)
    selected = intersect(numbers, groups{group});
    if isempty(selected)
        continue;
    end
    rng(seed, 'twister');
    execute_script(fullfile(root, 'examples', scripts{group}));
    source = fullfile('examples', scripts{group});
    for number = selected
        fig = findall(groot, 'Type', 'figure', 'Tag', sprintf('chapter-figure-%02d', number));
        assert(isscalar(fig), 'KalmanFilter:MissingFigure', 'Expected exactly one figure for chapter Figure %d.', number);
        base = fullfile(output_directory, sprintf('figure-%02d', number));
        height = 650;
        if number == 1
            height = 1100;
        end
        set(fig, 'Units', 'pixels', 'Position', [100, 100, 900, height]);
        set(fig, 'PaperPositionMode', 'auto');
        print(fig, [base '.png'], '-dpng', '-r150');
        print(fig, [base '.pdf'], '-dpdf', '-bestfit');
        metadata = struct('figure', number, 'seed', seed, 'generator', 'twister', ...
            'matlab_version', version, 'source', source, ...
            'publication_doi', '10.5772/intechopen.80600', ...
            'basis', 'Current repository source; results may differ from the published figure.');
        write_metadata([base '.json'], metadata);
        files(end+1:end+3, 1) = {[base '.png']; [base '.pdf']; [base '.json']}; %#ok<AGROW>
    end
    close all;
end
fprintf('Exported %d chapter figures to %s\n', numel(numbers), output_directory);
end

function execute_script(script_file)
% Isolate the supplied scripts' clear statements from exporter configuration.
run(script_file);
end

function write_metadata(filename, metadata)
[file, message] = fopen(filename, 'w');
assert(file ~= -1, 'KalmanFilter:Metadata', '%s', message);
cleanup = onCleanup(@() fclose(file)); %#ok<NASGU>
fprintf(file, '%s\n', jsonencode(metadata));
end

function restore_environment(original_rng, visibility)
close all;
rng(original_rng);
set(groot, 'defaultFigureVisible', visibility);
end
