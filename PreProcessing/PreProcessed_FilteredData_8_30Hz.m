clear; clc;

% ⚡️ 1. Paths Configuration (Relative)
base_dir      = '.';
input_folder  = fullfile(base_dir, 'data', 'raw_gdf');
output_folder = fullfile(base_dir, 'data', 'Filtered_8_30Hz');

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% ⚡️ 2. Initialize EEGLAB
if ~exist('eeglab', 'file')
    addpath(genpath('./eeglab'));
end
eeglab;
close; % Close the EEGLAB GUI window

% ⚡️ 3. Parameters
channels_to_remove = {'EOG1', 'EOG2', 'EOG3', 'EMGg', 'EMGd'};
epoch_samples = 2560; % 5 seconds * 512 Hz

classes = {
    sprintf('class1, Left hand\t- cue onset (BCI experiment)'), 'Left_Hand';
    sprintf('class2, Right hand\t- cue onset (BCI experiment)'), 'Right_Hand'
};

% ⚡️ 4. Read all .gdf files in the folder
file_list = dir(fullfile(input_folder, '*.gdf'));

if isempty(file_list)
    fprintf('No .gdf files found in %s\n', input_folder);
    return;
end

for i = 1:length(file_list)
    file_name = file_list(i).name;
    file_path = fullfile(input_folder, file_name);
    [~, base_name, ~] = fileparts(file_name);
    
    fprintf('\n[%d/%d] Processing file: %s\n', i, length(file_list), file_name);
    
    % 📥 Load file
    try
        EEG = pop_biosig(file_path);
    catch ME
        warning('Failed to load %s: %s', file_name, ME.message);
        continue;
    end

    % ✅ Remove EOG and EMG channels
    rm_idx = find(ismember({EEG.chanlocs.labels}, channels_to_remove));
    if ~isempty(rm_idx)
        EEG = pop_select(EEG, 'nochannel', rm_idx);
    end

    % ✅ Apply Zero-phase Band-pass filter (8-30 Hz) - Mu & Beta Bands
    EEG = pop_eegfiltnew(EEG, 'locutoff', 8, 'hicutoff', 30);
    fprintf('✔ Applied band-pass filter (8-30 Hz) to %s\n', file_name);
    
    % ✅ Extract Epochs for both classes
    for c = 1:size(classes, 1)
        event_str  = classes{c, 1};
        class_name = classes{c, 2};
        
        event_indices = find(strcmp({EEG.event.type}, event_str));
        valid_epochs = 0;
        
        for j = 1:length(event_indices)
            start_sample = round(EEG.event(event_indices(j)).latency);
            end_sample   = start_sample + epoch_samples - 1; % Exactly 2560 samples
            
            if start_sample > 0 && end_sample <= EEG.pnts
                EEG_cropped = pop_select(EEG, 'point', [start_sample, end_sample]);
        
                % ✅ Channel-wise Z-score normalization
                data = EEG_cropped.data;  % size: [channels x time]
                data_zscored = (data - mean(data, 2)) ./ std(data, 0, 2);
                EEG_cropped.data = data_zscored;
        
                % 📤 Save individual trial to .mat
                out_filename = fullfile(output_folder, sprintf('Epoch_%d_%s_%s.mat', j, base_name, class_name));
                save(out_filename, 'EEG_cropped');
                valid_epochs = valid_epochs + 1;
            else
                fprintf('! Invalid epoch range for %s event %d, skipping...\n', class_name, j);
            end
        end
        fprintf('✔ Processed and saved %d valid epochs for %s.\n', valid_epochs, class_name);
    end
end

disp('====================================================');
disp('✅ All epochs for Right and Left hand (8-30 Hz) have been processed and saved.');
disp('====================================================');