function createTrialMatrix(initials, varargin)
% createTrialMatrix for +ImageSequences defines all conditions for a
% single recording in the awake rig
% 
% -------COMPONENTS--------- 
% * Full list of parameters under 'S.(S.modname)'
%   - each category is specified under a subfield:
%       ex) S.fixation.stimulus, S.fixation.response
%
% * Trial matrix:
%   - matrix of the entire experiment (trials x fields)
%   
% * Trial matrix description
%   - description of each field (column)
%
% 2018-09-04  YB   wrote it. <yoonbai@utexas.edu>
% 

%% Initiate S, a structure that summarizes all variables and will be filled 
% with registered responses
% ////
S                   = struct;

%% Hardcoded stuff
%-------------------------------------------------------------------------%
% Specify module for this experiment
S.toolbox           = '+Straightening';

% Define modular name, a custom field name that puts all of our variables  
% under the field for custom variables, 'p.trial'
% * IMPORTANT: We will transfer all of our variables under 'S.modName' to
%              PLDAPS. Therefore, variables that will be used with PLDAPS 
%              are defined here. 
S.modName           = lower(erase(S.toolbox,'+')); %'imagesequences';

% Experiment description for future generations
S.comment           = char({...
    'Fixation task for studying the temporal straightening hypothesis', ... % JM 2025-03-23
    'add comments... ', ...
    '...'
    });

%% Input parser
%-------------------------------------------------------------------------%
% Required input    : subject initials, cell array of movies for each category
% Optional inputs   : 'reward', 'fixationSize', 'numImages' (per trial)
% Save subject initials
S.subject                   = initials;

parser                      = inputParser;

parser.addRequired('initials',      @ischar);       % subject

default_rewardAmt               = 0.1;      % mL
default_fixationSize            = 3.0;      % degrees
default_numRepetitions          = 1;
default_fp_x                    = 0;
default_fp_y                    = 0;
default_gaze_offset_x           = 0;
default_gaze_offset_y           = 0;
default_stim_diam_deg           = 4;
default_stim_center_x           = 4;
default_stim_center_y           = -4;
default_stim_dur_sec            = 0.100;

parser.addParameter('rewardAmount',         default_rewardAmt,           @isnumeric);
parser.addParameter('fp_x',                 default_fp_x,                @isnumeric);
parser.addParameter('fp_y',                 default_fp_y,                @isnumeric);
parser.addParameter('fixationSize',         default_fixationSize,        @isnumeric);
parser.addParameter('nTrials',              default_numRepetitions,      @isnumeric);
parser.addParameter('gaze_offset_x',        default_gaze_offset_x,       @isnumeric);
parser.addParameter('gaze_offset_y',        default_gaze_offset_y,       @isnumeric);
parser.addParameter('stim_diam_deg',        default_stim_diam_deg,       @isnumeric);
parser.addParameter('stim_center_x',        default_stim_center_x,       @isnumeric);
parser.addParameter('stim_center_y',        default_stim_center_y,       @isnumeric);
parser.addParameter('stim_dur_sec',         default_stim_dur_sec,        @isnumeric);


% sort input variables
parse(parser, initials, varargin{:})

% Construct list of images for each trial
%-------------------------------------------------------------------------%
% No. of trials
nTrials = parser.Results.nTrials;

% List of videos
file = dir('Video/*.mat');
videoList = randperm(size(file,1),nTrials);
S.(S.modName).videoList = videoList;


% State-related variables
%-------------------------------------------------------------------------%
states                              = struct;
slowDownFactor                      = 1; %  slow down for debugging 


% Define task states
i = 0;
states.START                        =  i;    i = i + 1;
states.FP_ON                        =  i;    i = i + 1;
states.FP_HOLD                      =  i;    i = i + 1;
%states.STIM_ON                      =  i;    i = i + 1;
states.IMG_ON                       =  i;    i = i + 1;
states.IMG_OFF                      =  i;    i = i + 1;
states.FP_OFF                       =  i;    i = i + 1;
states.TRIAL_COMPLETE               =  i;    i = i + 1;
states.BREAK_FIX                    =  i;    i = i + 1;

% State durations (in units of seconds)
states.duration.START               = 0.05 ; % allocate time for audible cue
states.duration.FP_ON               = 0.05 ; 
states.duration.FP_HOLD             = 0.1 ;  
states.duration.IMG_ON              = parser.Results.stim_dur_sec;
states.duration.FP_OFF              = (0.2+ (0.2 * rand(1)));%Rndm Jitter
% states.duration.FP_OFF              = 0.2;
states.duration.TRIAL_COMPLETE      = 0.01   ;


states.duration.FRAME             = 1/60 ; %% Should this be 75??
S.(S.modName).NUM_FRAME      = states.duration.IMG_ON  * (1/states.duration.FRAME);% * S.(S.modName).NUM_IMAGES_TRIAL; % num frame per presentation

states.fix_hold_time = nan; %added 1/12/2021

% timestamps: when did the subject reach each state?
states.timestamps.START             = nan;
states.timestamps.FP_ON             = nan;
states.timestamps.FP_HOLD           = nan;
%states.timestamps.STIM_ON           = nan;
states.timestamps.IMG_ON            = nan;
states.timestamps.IMG_OFF           = nan;
states.timestamps.FP_OFF            = nan;
states.timestamps.TRIAL_COMPLETE    = nan;

% Variables to track subject's state within a single trial
states.current_state                = states.START;
states.previous_state               = nan;
states.current_img_index            = 1;
states.current_frame_index            = 1;

% Maximum duration for trial, across all states
states.duration.MAX_TRIAL_DURATION  = 5; % seconds

% slowDownFactor
durationFields = fieldnames(states.duration);
for i = 1:length(durationFields)
    states.duration.(durationFields{i}) = states.duration.(durationFields{i}) * slowDownFactor;
end

% put state-related parameters in the main struct, S
S.(S.modName).states                = states;           



% Stimulus-related variables
%-------------------------------------------------------------------------%
% Constants within a block         : FP size, shape, color, duration
% Varying parameters within block  : FP location

stimulus                            = struct;

% Fixation Point ---------------------
% FP shapes
stimulus.fp.shape.CIRCLE                = 1;
stimulus.fp.shape.SQUARE                = 0;
stimulus.fp.shape.current               = stimulus.fp.shape.CIRCLE;

% FP location(s)
stimulus.fp.location.X_DEG              = parser.Results.fp_x;
stimulus.fp.location.Y_DEG              = parser.Results.fp_y;

% FP diameter in visual degrees
stimulus.fp.size.DIAMETER_DEG           = 0.2; %[1, 5, 10];
stimulus.fp.size.PRE_STIM_DIAMETER_DEG  = 0.2; %[1, 5, 10];

stimulus.fp.size.curr_diameter_deg      = stimulus.fp.size.PRE_STIM_DIAMETER_DEG; %[1, 5, 10];



% FP color (index for monkey CLUT)
% Monkey CLUT indices are: WHITE: 8, RED:7, BLUE: 11, GREEN: 12, BLACK: 10
stimulus.fp.color.COLOR_INDEX           = 8; %[8, 7, 12, 10];  

% % FP presentation duration in seconds
% stimulus.fp.duration.DURATION_SEC      = 0.25; %[0.25, 0.5, 1];

% Image stimulus ---------------------
% stimulus.image.on_duration_sec          = 0.2; % seconds
% stimulus.image.off_duration_sec         = 0.1; % seconds
stimulus.image.size.DIAMETER_DEG        = parser.Results.stim_diam_deg;
stimulus.image.location.X_DEG           = parser.Results.stim_center_x;
stimulus.image.location.Y_DEG           = parser.Results.stim_center_y;
stimulus.image.pixelBitDepth            = 8; % 8 bits

% Vignette (need to resize when generating actual image stimulus)
%flattop8                                = im2double(imread('Flattop8.tif'));
%flattop8                                = squeeze(flattop8(:,:,end));
%stimulus.image.vinette                  = flattop8;

S.(S.modName).stimulus                  = stimulus;



% Gaze
%-------------------------------------------------------------------------%
gaze                                = struct;

% fixation boundary 
gaze.RADIUS_DEG                     = parser.Results.fixationSize;  
gaze.PRE_STIM_RADIUS_DEG            = gaze.RADIUS_DEG * 2;%2;  

% current gaze window radius (this changes thoughout the task)
gaze.curr_window_radius_deg         = gaze.PRE_STIM_RADIUS_DEG;

% custom eye calibration
gaze.gain_step_size                 = 0.1;
gaze.offset_step_size               = 0.1;
gaze.x_gain                         = 1; % arbitrary units
gaze.x_offset                       = parser.Results.gaze_offset_x; % in visual degrees
gaze.y_gain                         = 1.0;
gaze.y_offset                       = parser.Results.gaze_offset_y;

% eye tracing (history)
gaze.trace_dot_width                = 2; % size of dots for tracing
gaze.trace_history_sec              = 0.5;% length of tracing history, in seconds

S.(S.modName).gaze                  = gaze;



% Response
%-------------------------------------------------------------------------%
response                            = struct;

% possible responses for this task
response.HELD_FIXATION              =  1;
response.NO_FIXATION                =  0;
response.BREAK_FIX                  = -1;

% placeholder for subject's response
response.subjectResponse            = nan;

S.(S.modName).response              = response;



% Outcome
%-------------------------------------------------------------------------%
outcome                             = struct;

% possible outcomes for this task
outcome.SUCCESS                     =  1;
outcome.FAILURE                     =  0;
outcome.BREAK_FIX                   = -1;

% placeholder for trial outcome
outcome.trialOutcome                = nan;
S.(S.modName).outcome               = outcome;

% Juice
reward.amount                       = parser.Results.rewardAmount;  % mL
reward.trial.amount                 = NaN; % JM 2025-03-21 
S.(S.modName).reward                = reward; % JM 2025-03-21 

% Counter
S.(S.modName).counter               = NaN; % JM 2025-03-21 

% ITI
S.(S.modName).ITI                   = .2; % Normal =.2 seconds, Moe = .3 or.5


% Audible feedback (PLDAPS expects a particular value for each sound. to be continued...)
%-------------------------------------------------------------------------%
sound                               = struct;
sound.CUE                           = 1;
sound.SUCESS                        = 2;
sound.FAILURE                       = 3;
sound.BREAK_FIX                     = 7;
S.(S.modName).sound                 = sound;



%% TRIAL MATRIX

% Trial matrix index for each field (column)
%-------------------------------------------------------------------------%
index_num = 1;
S.trialMatrix_index.FP_X_DEG        = index_num; index_num = index_num + 1;
S.trialMatrix_index.FP_Y_DEG        = index_num; index_num = index_num + 1;
S.trialMatrix_index.PDS_DATA_INDEX  = index_num; index_num = index_num + 1;
S.trialMatrix_index.IMAGE_DIAM_DEG  = index_num; index_num = index_num + 1;
S.trialMatrix_index.IMAGE_X_DEG     = index_num; index_num = index_num + 1;
S.trialMatrix_index.IMAGE_Y_DEG     = index_num; index_num = index_num + 1;

S.trialMatrix_index.IMAGE_LIST      = index_num; index_num = index_num + 1; 
S.trialMatrix_index.MOTION_LIST     = index_num; index_num = index_num + 1;

S.trialMatrix_index.RESPONSE        = index_num; index_num = index_num + 1;
S.trialMatrix_index.FEEDBACK        = index_num; index_num = index_num + 1;
S.trialMatrix_index.REWARD          = index_num; index_num = index_num + 1; % JM 2025-03-21
S.trialMatrix_index.COUNTER         = index_num; % JM 2025-03-21



% Trial matrix descriptions for each field (column)
%-------------------------------------------------------------------------%
S.trialmatrix_description{S.trialMatrix_index.FP_X_DEG}    = ...
    sprintf('column %s, FP x-location, range: %s, in visual degrees from center', ...
        num2str(S.trialMatrix_index.FP_X_DEG), ...
        num2str(stimulus.fp.location.X_DEG));
    
S.trialmatrix_description{S.trialMatrix_index.FP_Y_DEG}    = ...
    sprintf('column %s, FP y-location, range: %s, in visual degrees from center', ...
        num2str(S.trialMatrix_index.FP_Y_DEG), ...
        num2str(stimulus.fp.location.Y_DEG));
    
S.trialmatrix_description{S.trialMatrix_index.PDS_DATA_INDEX}    = ...
    sprintf('column %s, Trial index for ''PDS.data'' list', ...
        num2str(S.trialMatrix_index.PDS_DATA_INDEX));
    
S.trialmatrix_description{S.trialMatrix_index.IMAGE_DIAM_DEG}    = ...
    sprintf('column %s, Diameter of stimulus (degrees)', ...
        num2str(S.trialMatrix_index.PDS_DATA_INDEX));
    
S.trialmatrix_description{S.trialMatrix_index.IMAGE_X_DEG}    = ...
    sprintf('column %s, Image x-location, range: %s, in visual degrees from center', ...
        num2str(S.trialMatrix_index.IMAGE_X_DEG), ...
        num2str(stimulus.image.location.X_DEG));
    
S.trialmatrix_description{S.trialMatrix_index.IMAGE_Y_DEG}    = ...
    sprintf('column %s, Image y-location, range: %s, in visual degrees from center', ...
        num2str(S.trialMatrix_index.IMAGE_Y_DEG), ...
        num2str(stimulus.image.location.Y_DEG));

S.trialmatrix_description{S.trialMatrix_index.IMAGE_LIST}        = ...
    sprintf('column %s, Image ID presented for this trial', ...
        num2str(S.trialMatrix_index.IMAGE_LIST));
    
S.trialmatrix_description{S.trialMatrix_index.MOTION_LIST}        = ...
    sprintf('column %s, Motion ID presented for this trial (1: stationary, 2: approaching, 3: leftward, 4: rightward)', ...
        num2str(S.trialMatrix_index.MOTION_LIST));
    
S.trialmatrix_description{S.trialMatrix_index.RESPONSE}        = ...
    sprintf('column %s, observer response, range: [0 1], meaning: [not fixated, successfully fixated]', ...
        num2str(S.trialMatrix_index.RESPONSE));

S.trialmatrix_description{S.trialMatrix_index.FEEDBACK} = ...
    sprintf('column %s, feedback received by observer (0: FAILURE, 1: SUCCESS, -1: BREAK FIXATION, NaN: no feedback', ...
        num2str(S.trialMatrix_index.FEEDBACK));
    
S.trialmatrix_description{S.trialMatrix_index.REWARD} = ...
    sprintf('column %s,  Reward earned in trial (ml)', ...
    num2str(S.trialMatrix_index.REWARD)); % JM 2025-03-21
    
S.trialmatrix_description{S.trialMatrix_index.COUNTER}        = ...
    sprintf('column %s, current streak of correct trials', ...
        num2str(S.trialMatrix_index.COUNTER)); % JM 2025-03-21




% Trial matrix  
%-------------------------------------------------------------------------%
% assign conditions values to a temporary matrix
trialMatrix                                         = nan(length(trialMatrix), index_num);

trialMatrix(:,S.trialMatrix_index.FP_X_DEG)         = stimulus.fp.location.X_DEG;%randsample(stimulus.fp.location.X_DEG, S.blockSize, true);
trialMatrix(:,S.trialMatrix_index.FP_Y_DEG)         = stimulus.fp.location.Y_DEG;%randsample(stimulus.fp.location.Y_DEG, S.blockSize, true);

trialMatrix(:,S.trialMatrix_index.PDS_DATA_INDEX)   = NaN;

trialMatrix(:,S.trialMatrix_index.IMAGE_DIAM_DEG)   = stimulus.image.size.DIAMETER_DEG;

trialMatrix(:,S.trialMatrix_index.IMAGE_X_DEG)      = stimulus.image.location.X_DEG;%randsample(stimulus.image.location.X_DEG, S.blockSize, true);
trialMatrix(:,S.trialMatrix_index.IMAGE_Y_DEG)      = stimulus.image.location.Y_DEG;%randsample(stimulus.image.location.Y_DEG, S.blockSize, true);

trialMatrix(:,S.trialMatrix_index.IMAGE_LIST)       = videoList;

trialMatrix(:,S.trialMatrix_index.FEEDBACK)         = NaN;
trialMatrix(:,S.trialMatrix_index.RESPONSE)         = NaN;

trialMatrix(:,S.trialMatrix_index.COUNTER)          = NaN; % JM 2025-03-21

S.trialMatrix       = trialMatrix;




%% Save out S
%-------------------------------------------------------------------------%
folder      = ['./Data/', datestr(now, 'mm-dd-yyyy'), '/'];
mkdir(folder);

% TODO: check if file already exists. Warn user if this is the case. Ask if
% you would like to override.
rep_index   = 1;
files       = dir([folder,S.toolbox(2:end),'_',initials,'*']);
if(~isempty(files))
    rep_index = length(files) + 1;
end
filename    = sprintf('%s_%s_%02d.mat', S.toolbox(2:end), initials, rep_index);
filepath    = [folder, filename];

save(filepath, 'S');

fprintf('New data matrix was created for ''%s'' \n', initials);


%% make session info file
%-------------------------------------------------------------------------%
session                     = struct;
session.subject             = initials;
session.trialMatrixFile     = filepath; % current trial matrix
session.sessionTrialIndex   = 1;        % index for current trial matrix
session.isOngoing           = false;
sessionFilePath             = [folder, 'sessionInfo.mat'];
save(sessionFilePath, 'session');


