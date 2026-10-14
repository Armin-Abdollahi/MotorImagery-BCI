% --- 1. EEGLAB Initialization ---
if ~exist('eeglab', 'file')
    addpath(genpath('./eeglab'));
end
eeglab;

% --- 2. Clean Relative Folder Paths ---
input_folder  = './data/raw_gdf'; 
output_folder = './data/processed_raw';

% Output subdirectories for both classes
out_left  = fullfile(output_folder, 'Left_Hand');
out_right = fullfile(output_folder, 'Right_Hand');

if ~exist(out_left, 'dir'),  mkdir(out_left);  end
if ~exist(out_right, 'dir'), mkdir(out_right); end

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
    
    % Define both classes with their exact event triggers (including the tab character)
    classes = {
        sprintf('class1, Left hand\t- cue onset (BCI experiment)'), out_left,  'Left';
        sprintf('class2, Right hand\t- cue onset (BCI experiment)'), out_right, 'Right'
    };

    [~, base_name, ~] = fileparts(file_list(file_idx).name);

    for c = 1:size(classes, 1)
        event_type = classes{c, 1};
        target_dir = classes{c, 2};
        label_name = classes{c, 3};

        event_idx = find(strcmp({EEG.event.type}, event_type));
        if isempty(event_idx)
            fprintf('No %s events found in %s\n', label_name, base_name);
            continue;
        end

        % Extract epochs for this specific class
        EEG_epoch = pop_epoch(EEG, {event_type}, [0 5], 'newname', [base_name '_' label_name], 'epochinfo', 'yes');

        % Save class-specific GDF file
        output_file_path = fullfile(target_dir, [base_name '_' label_name '_processed.gdf']);
        pop_writeeeg(EEG_epoch, output_file_path, 'TYPE', 'GDF');
    end

end

disp('Processing and saving completed.')