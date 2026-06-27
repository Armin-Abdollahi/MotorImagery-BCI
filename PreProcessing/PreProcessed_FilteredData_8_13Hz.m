% ⚡️ Paths
input_folder = 'D:\Master\5_Semester\Master_Thesis\Dissertation_Dataset\BCI_Database\Signals\PreProcessed_Signal\1';  % Path to the input folder containing EEG signals
output_folder = 'D:\Master\5_Semester\Master_Thesis\Dissertation_Dataset\BCI_Database\Signals\PreProcessed_Signal\Filtered_8_13Hz';  % Path to the output folder for filtered signals
mkdir(output_folder);  % Create the output folder if it doesn't exist

% ⚡️ Load EEGLAB
eeglab;
close; % Close the EEGLAB GUI window that pops up

% ⚡️ Read all .gdf files in the folder
file_list = dir(fullfile(input_folder, '*.gdf'));

for i = 1:length(file_list)
    % 📥 Load the file
    file_name = file_list(i).name;
    file_path = fullfile(input_folder, file_name);
    fprintf('Processing file: %s\n', file_name);
    EEG = pop_biosig(file_path);

    % ✅ Remove EOG and EMG channels
    channels_to_remove = {'EOG1', 'EOG2', 'EOG3', 'EMGg', 'EMGd'};
    % Find the indices of the target channels to remove
    rm_idx = [];
    for ch = 1:length(channels_to_remove)
        idx = find(strcmp({EEG.chanlocs.labels}, channels_to_remove{ch}));
        if ~isempty(idx)
            rm_idx = [rm_idx, idx];
        end
    end
    % Remove the selected channels
    if ~isempty(rm_idx)
        EEG = pop_select(EEG, 'nochannel', rm_idx);
    end

    % ✅ Apply Band-pass filter (8-13 Hz)
    % This range covers Alpha (8-13 Hz) which are crucial for motor imagery tasks.
    EEG = pop_eegfiltnew(EEG, 'locutoff', 8, 'hicutoff', 13);
    fprintf('✔ Applied band-pass filter (8-13 Hz) to %s\n', file_name);
    
    % ✅ Extract Right Hand events
    right_hand_events = find(strcmp({EEG.event.type}, 'class2, Right hand	- cue onset (BCI experiment)'));
    
    for j = 1:length(right_hand_events)
        start_sample = round(EEG.event(right_hand_events(j)).latency);
        end_sample = start_sample + 2559;
    
        if start_sample > 0 && end_sample <= EEG.pnts
            EEG_cropped = pop_select(EEG, 'point', [start_sample, end_sample]);
    
            % ✅ Z-score normalization channel-wise
            data = EEG_cropped.data;  % size: [channels x time]
            data_zscored = (data - mean(data, 2)) ./ std(data, 0, 2);
            EEG_cropped.data = data_zscored;
    
            % 📤 Save to .mat
            output_filename_right = fullfile(output_folder, sprintf('Epoch_%d_%s_Right_Hand.mat', j, file_name(1:end-4)));
            save(output_filename_right, 'EEG_cropped');
    
            % fprintf('✔ Cropped + normalized right hand epoch %d saved as %s\n', j, output_filename_right);
        else
            fprintf('! Invalid epoch range for right hand event %d, skipping...\n', j);
        end
    end
    fprintf('✔ Processed %d right hand epochs.\n', length(right_hand_events));
    
    % ✅ Extract Left Hand events
    left_hand_events = find(strcmp({EEG.event.type}, 'class1, Left hand	- cue onset (BCI experiment)'));
    
    for j = 1:length(left_hand_events)
        start_sample = round(EEG.event(left_hand_events(j)).latency);
        end_sample = start_sample + 2559;
    
        if start_sample > 0 && end_sample <= EEG.pnts
            EEG_cropped = pop_select(EEG, 'point', [start_sample, end_sample]);
    
            % ✅ Z-score normalization channel-wise
            data = EEG_cropped.data;
            data_zscored = (data - mean(data, 2)) ./ std(data, 0, 2);
            EEG_cropped.data = data_zscored;
    
            % 📤 Save to .mat
            output_filename_left = fullfile(output_folder, sprintf('Epoch_%d_%s_Left_Hand.mat', j, file_name(1:end-4)));
            save(output_filename_left, 'EEG_cropped');
    
            % fprintf('✔ Cropped + normalized left hand epoch %d saved as %s\n', j, output_filename_left);
        else
            fprintf('! Invalid epoch range for left hand event %d, skipping...\n', j);
        end
    end
    fprintf('✔ Processed %d left hand epochs.\n\n', length(left_hand_events));
end
disp('✅ All epochs for Right and Left hand have been processed and saved in .mat format.');