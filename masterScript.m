
sca;
close all;
clear java;

cd('/Users/gorislab/Desktop/psychophysics/experiments/+Straightening/')

%%% required inputs
subject             = 'Jongmin'; %'MoeTest'; %
rig                 = 1;         

if rig == 1
    calib = 'rig_1_20180808.mat';
elseif rig == 2
    calib = 'rig220180821.mat';
elseif rig == 3
    calib = 'rig320180928.mat';
end
load(['~/Documents/Calib/2018/' calib])


gammaStruct.display.forceLinearGamma    = true;
gammaStruct.display.gamma.power         = gam.power; % this is for Rig 1

%% stimuli for pilot experiment

Straightening.createTrialMatrix(...
    subject, ...
    'reward',               .1, ...%.5 %.3
    'fp_x',                 0.0, ... % deg
    'fp_y',                 0.0, ... % deg
    'fixationSize',         .45, ... %.53... 61,... .64,... .65,... % CAN BE MADE LARGER (0.7)!!!!!!
    'nTrials',              50, ... 
    'gaze_offset_x',        0.0,  ...
    'gaze_offset_y',        0.0, ...
    'stim_center_x',        2.75, ... v          
    'stim_center_y',        -2.5, ...
    'stim_dur_sec',         .2, ...%.2
    'stim_diam_deg',        4);% 4                     


% make sure the CRT lookup table is precisely linear
% ('plot(gammatable)' should give you a unity line)
USE_PHYSICAL_DISPLAY = 1;
[gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', max(Screen('Screens')), USE_PHYSICAL_DISPLAY);


p   = pldaps(@Straightening.setup, subject, gammaStruct);

% override background luminance
p.trial.display.bgColor = [.25 .25 .25];

p.run;