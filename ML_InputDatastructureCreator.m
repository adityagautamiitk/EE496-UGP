function [] = ML_InputDatastructureCreator(inputFilePaths, outputFolder)
% This function converts DeepMIMO dataset format to the format required for main.m
%
% Inputs:
%   inputFilePaths - Cell array of paths to original .mat files or a single string
%   outputFolder - Path to output folder (should be 'root/Input-DataStructures')

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

    % Create output structure
    outputData = struct();
    outputData.channels = channels;
    outputData.user_locations = user_locations;

    % Generate output filename from input filename
    [~, baseFileName, ~] = fileparts(inputFilePath);
    outputFilePath = fullfile(outputFolder, [baseFileName '_processed.mat']);

    % Save the processed data
    save(outputFilePath, 'outputData');

    fprintf('File %d/%d: Data processed and saved to: %s\n', fileIdx, length(inputFilePaths), outputFilePath);
end

fprintf('All files processed successfully!\n');
end