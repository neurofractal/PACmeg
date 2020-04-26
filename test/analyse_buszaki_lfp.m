%% Paths (RS)
fieldtripDir    = '/Users/rseymoue/Documents/scripts/fieldtrip-20191213';
path_to_buz     = '/Users/rseymoue/Documents/Github/buzcode';
script_dir      = '/Users/rseymoue/Documents/GitHub/PACmeg';
data_dir        = '/Users/rseymoue/ec013.152_157';
save_dir        = '/Users/rseymoue/Documents/GitHub/PACmeg/test';

% Add Fieldtrip to path
disp('Adding Fieldtrip, EEGlab and PACmeg to your MATLAB path');
addpath(fieldtripDir)
addpath(genpath(path_to_buz));
ft_defaults;

% Add analyse_OPMEG Scripts to path
addpath(genpath(script_dir));

% cd to save dir
cd(data_dir)

%% Load the LFP data using bz_GetLFP
 
[lfp] = bz_GetLFP('all')

%% Rearrange into Fieldtrip Format
data = [];
data.fsample = lfp.samplingRate;
data.trial{1} = double(lfp.data)';
data.time{1} = lfp.timestamps';
data.sampleinfo          = [1 length(data.trial{1}(1,:))];

data.label = [];

for i = 1:length(lfp.channels)
    data.label{i,1} = num2str(lfp.channels(i));
end


save('data','data','-v7.3')

ft_databrowser([],data);









