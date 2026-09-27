function verify_figures
% Exercise chapter-number selection, output files, and simulation export.
% Run instructions and acceptance criteria: tests/integration/examples/README.md.
root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
original_path = path;
output_directory = tempname;
mkdir(output_directory);
cleanup = onCleanup(@() restore_environment(original_path, output_directory)); %#ok<NASGU>
addpath(root);

numbers = [1, 2, 3, 4, 5, 8, 9];
files = generate_figures(numbers, output_directory, 17);
assert(numel(files) == 21, 'Each of seven figures must produce PNG, PDF, and metadata.');
check_exports(output_directory, numbers);
first_image = imread(fullfile(output_directory, 'figure-02.png'));

single_directory = fullfile(output_directory, 'single');
files = generate_figures([2, 2], single_directory, 17);
assert(numel(files) == 3, 'A single figure request must export only that figure.');
check_exports(single_directory, 2);
assert(numel(dir(fullfile(single_directory, 'figure-*'))) == 3, ...
    'A single figure request exported unrelated figures.');
assert(isequal(first_image, imread(fullfile(single_directory, 'figure-02.png'))), ...
    'Figure 2 must be reproducible whether generated alone or with all figures.');

check_rejected_diagram(fullfile(output_directory, 'unsupported'));
fprintf('All figure export integration checks passed.\n');
end

function check_rejected_diagram(directory)
try
    generate_figures(6, directory);
    error('Test:ExpectedError', 'Figure 6 should not be accepted as a simulation plot.');
catch problem
    assert(strcmp(problem.identifier, 'KalmanFilter:NotSimulationFigure'), ...
        'Expected the unsupported-simulation-figure error, got %s.', problem.identifier);
end
assert(~exist(directory, 'dir'), 'Rejected requests must not create output directories.');
end

function check_exports(directory, numbers)
for number = numbers
    base = fullfile(directory, sprintf('figure-%02d', number));
    pixels = imread([base '.png']);
    assert(size(pixels, 1) > 100 && size(pixels, 2) > 100 && ...
        numel(unique(pixels(:))) > 1, 'Figure %d PNG is empty or blank.', number);
    file = fopen([base '.pdf'], 'r');
    assert(file ~= -1, 'Figure %d PDF is missing.', number);
    signature = fread(file, 5, '*char')';
    fclose(file);
    assert(strcmp(signature, '%PDF-'), 'Figure %d output is not a PDF.', number);
    metadata = jsondecode(fileread([base '.json']));
    assert(metadata.figure == number, 'Figure %d metadata refers to a different figure.', number);
end
end

function restore_environment(original_path, output_directory)
path(original_path);
if exist(output_directory, 'dir')
    rmdir(output_directory, 's');
end
end
