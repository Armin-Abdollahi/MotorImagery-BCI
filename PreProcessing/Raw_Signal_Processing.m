% Add the path to EEGLAB to MATLAB path
addpath('C:\Users\ASUS\Documents\MATLAB\eeglab2024.2');

% Initialize EEGLAB
eeglab;

% Define input and output folder paths
input_folder = 'D:\Master\5_Semester\Master_Thesis\Dissertation_Dataset\BCI_Database\Raw_Signal\1\Test\A4';
output_folder = 'D:\Master\5_Semester\Master_Thesis\Dissertation_Dataset\BCI_Database\Raw_Signal\2\Test\A4\Left Hand';

% Check if output folder exists, and if not, create it
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get the list of .gdf files in the input folder
file_list = dir(fullfile(input_folder, '*.gdf'));

% Channels to be removed
channels_to_remove = {'EOG1', 'EOG2', 'EOG3', 'EMGg', 'EMGd'};

% Process each .gdf file in the input folder
for file_idx = 1:length(file_list)
    % Full path of the input file
    input_file_path = fullfile(file_list(file_idx).folder, file_list(file_idx).name);
    
    % Load the EEG signal from the .gdf file
    EEG = pop_biosig(input_file_path);
    
    % Find the indices of the channels to be removed
    channels_idx = find(ismember({EEG.chanlocs.labels}, channels_to_remove));
    
    % Remove the specified channels
    EEG = pop_select(EEG, 'nochannel', channels_idx);
    
    % Apply high-pass filter with cutoff frequency of 0.5 Hz and a valid filter order
    filter_order = 3380; % Example of a valid even positive integer for filter order
    EEG = pop_eegfiltnew(EEG, 0.5, [], filter_order, 0, [], 0);
    
    % Extract epochs based on the event 'class1, Left hand - cue onset (BCI experiment)'
    event_type = 'class1, Left hand	- cue onset (BCI experiment)'; % Updated event type
    event_idx = find(strcmp({EEG.event.type}, event_type));
    
    if isempty(event_idx)
        disp(['No events found for type: ' event_type]);
        continue; % Skip this file if no events found
    end
    
    % Extract epochs
    EEG = pop_epoch(EEG, {event_type}, [0 5], 'newname', [EEG.setname ' epochs'], 'epochinfo', 'yes');

    % Full path of the output file
    [~, name, ~] = fileparts(file_list(file_idx).name);
    output_file_path = fullfile(output_folder, [name '_processed.gdf']);
    
    % Save the processed EEG signal to a new .gdf file
    pop_writeeeg(EEG, output_file_path, 'TYPE', 'GDF');
end

disp('Processing and saving completed.')