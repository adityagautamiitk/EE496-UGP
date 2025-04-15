function [] = ML_InputDatastructureCreator(varargin)
% This function converts DeepMIMO dataset format to the format required for main.m
%
% Inputs:
%   inputFilePaths - Cell array of paths to original .mat files or a single string
%   outputFolder - Path to output folder (should be 'root/Input-DataStructures')

% Check if the function is called without arguments
if nargin == 0
    % Define default paths
    sub6_file = '/home/adityagautam/Documents/GitHub/EE496-UGP/DeepMIMOv2_O1_3p5/DeepMIMO_dataset/dataset_3p5.mat';
    mmwave_file = '/home/adityagautam/Documents/GitHub/EE496-UGP/DeepMIMOv2_O1_3p5/DeepMIMO_dataset/dataset_28.mat';
    inputFilePaths = {sub6_file, mmwave_file};

    % Define output folder
    outputFolder = fullfile(fileparts(mfilename('fullpath')), '..', 'Input-DataStructures');
elseif nargin == 1
    inputFilePaths = varargin{1};
    outputFolder = fullfile(fileparts(mfilename('fullpath')), '..', 'Input-DataStructures');
elseif nargin == 2
    inputFilePaths = varargin{1};
    outputFolder = varargin{2};
else
    error('Invalid number of input arguments. Expected 0, 1, or 2 arguments.');
end

% Handle single file input
if ischar(inputFilePaths)
    inputFilePaths = {inputFilePaths};
end

% Create output directory if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Process each input file
for fileIdx = 1:length(inputFilePaths)
    inputFilePath = inputFilePaths{fileIdx};

    % Load the original data
    load(inputFilePath, 'DeepMIMO_dataset');

    % Get the number of users
    numUsers = length(DeepMIMO_dataset{1}.user);

    % Get channel dimensions from the first user
    firstUserChannel = DeepMIMO_dataset{1}.user{1}.channel;
    channelSize = size(firstUserChannel);

    % Assuming the channel dimensions are [1 x numAntennaElements x numSubcarriers]
    numAntennaElements = channelSize(2);
    numSubcarriers = channelSize(3);

    % Initialize arrays with correct dimensions
    channels = zeros(numAntennaElements, numSubcarriers, numUsers);
    user_locations = zeros(3, numUsers);

    % Extract data for each user
    for i = 1:numUsers
        % Get channel data
        userChannel = DeepMIMO_dataset{1}.user{i}.channel;

        % Extract the channel matrix (removing singleton dimension)
        channels(:, :, i) = squeeze(userChannel(1, :, :));

        % Get user location (transpose to get 3xN format)
        user_locations(:, i) = DeepMIMO_dataset{1}.user{i}.loc';
    end

    % Generate output filename from input filename
    [~, baseFileName, ~] = fileparts(inputFilePath);

    % Extract frequency notation (3p5 or 28) from filename
    if contains(baseFileName, '3p5')
        freqNotation = '3p5';
    elseif contains(baseFileName, '28')
        freqNotation = '28';
    else
        freqNotation = 'unknown';
    end

    outputFilePath = fullfile(outputFolder, ['dataset_' freqNotation '_processed.mat']);

    % Create variable name based on frequency for uniqueness
    varName = ['data_' freqNotation];

    % Create output structure with unique variable name
    eval([varName ' = struct();']);
    eval([varName '.channels = channels;']);
    eval([varName '.user_locations = user_locations;']);

    % Save the processed data with the unique variable name
    eval(['save(''' outputFilePath ''', ''' varName ''');']);

    fprintf('File %d/%d: Data processed and saved to: %s as variable %s\n', ...
        fileIdx, length(inputFilePaths), outputFilePath, varName);
end

fprintf('All files processed successfully!\n');
end