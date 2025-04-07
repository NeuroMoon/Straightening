function p = setup(p)
% SETUP is the initial function called to run PLDAPS
%
% 2017-12-1  YB   wrote it. version 3.0 <yoonbai@utexas.edu>
%  


% EXPT_FOLDER     = '~/Desktop/psychophysics/experiments/';
% TASK_FOLDER     = fullfile(EXPT_FOLDER, '+ImageSequences');
%DATA_FOLDER     = fullfile(TASK_FOLDER, datestr(now, 'mm-dd-yyyy'), 'Data');

TASK_FOLDER     = './';
DATA_FOLDER     = fullfile(TASK_FOLDER, 'Data', datestr(now, 'mm-dd-yyyy'));

 
if(isa(p, 'pldaps'))
   
    
    % Use PLDAPS' modular mode:
    % The 'runModularTrial' option needs be accompanied by
    % p.trial.pldaps.useModularStateFunctions = true;
    p.trial.pldaps.useModularStateFunctions         = true;
    p.defaultParameters.pldaps.trialMasterFunction  = 'runModularTrial';
%     

%     % Module string
%     [upperDirectory, currDirectory] = fileparts(pwd);
%     moduleStr                       = erase(currDirectory, '+');
    
    % Trial function that will be called every frame
    %p.defaultParameters.pldaps.trialFunction        = [moduleStr, '.', 'trialFunction']; 
    p.defaultParameters.pldaps.trialFunction        = 'Straightening.trialFunction';
    
    
    % load trial matrix for this block
    
    p = Straightening.loadBlockTrialMatrixToPLDAPS(p, DATA_FOLDER);
    
    % load task-related parameters 
    %p = ImageSequences.loadTaskParametersToPLDAPS(p, DATA_FOLDER);
    
    % attach reward system
    %p = Fixation.attachRewardSystem(p);
    % seconds per trial.
%     modName = p.trial.modName;
%     p.trial.pldaps.maxTrialLength = p.trial.(modName).states.duration.MAX_TRIAL_DURATION;
%     p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    
else
    
    error('Input parameter is not a PLDAPS object!\n');
    
end