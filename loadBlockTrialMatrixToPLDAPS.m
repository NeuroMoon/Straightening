function p = loadBlockTrialMatrixToPLDAPS(p, dataFolder)
% LOADBLOCKLTRIALMATRIXTOPLDAPS reads the experiment session information
% from two files: (1) sessionInfo.mat, and (2) +Fixation_(subject).mat. 
% (1) Session information is updated and save in 'sessionInfo.mat'. When 
%    the block is finished, this file will be updated again. 
% (2) Subject is identified from the session info, and the corresponding
%    experiment trial-matrix is imported. A certain number of trials for
%    this block is extracted and returned in a struct, blockTrialMatrix. 
%    'blockTrialMatrix' contains all of the variables and parameters for
%    this task.
%
% After loading the two MAT files, this function passes on all 
% task-relevant variables and parameters to PLDAPS, under the the 
% struct field 'p.trial', where users are allowed to put custom fields. 
% To translate fields from 'blockTrialMatrix' to PLDAPS in a seamless 
% manner, we have assigned fields in 'createTrialMatrix.m' under our 
% pre-defined modular name, 'modName'. This function assumes you have 
% followed the convention of putting all of your task-related fields under
% 'modName'.
%
% The task for this function is to assign your trial matrix to PLDAPS by
% assiging a cell array to 'p.condition'. 
%
% 2017-11-20  YB   wrote it. <yoonbai@utexas.edu>
%

% currentPath         = taskFolder;
% sessionInfoFolder   = dataFolder;
%cd(sessionInfoFolder);

load(fullfile(dataFolder, 'sessionInfo.mat'), 'session');
%subject             = session.subject;
if(~session.isOngoing)
    
    if(p.trial.eyelink.use)
        eyelinkCalibrate();
    end
end
% For practical purposes we'll keep this to false in case of crashes.
% isOngoing will only be true when at the end of the block the observer decides to:
% 1. continue to next block
% 2. continue to eye calibration
session.isOngoing       = false;
session.endExperiment   = false;
save('sessionInfo.mat', 'session');

load(session.trialMatrixFile, 'S'); % 'S' is the struct that contains the trial matrix 

% assign module name
modName             = S.modName;
if(~isfield(p.trial, 'modName'))
    p.trial.modName = modName; % save string for struct field
end

% assign parameters under the struct field name
p.trial.(modName)                   = S.(modName);

currentTrialMatrix                  = S.trialMatrix;

% iterate thru trial matrix conditions
numTrials       = size(currentTrialMatrix,1);
fieldStrings    = fieldnames(S.trialMatrix_index);
structArray     = cell(numTrials, 1);
for i = 1:numTrials
    
    iStruct         = struct;
    % the following field names are defined in 'createTrialMatrix.m'
    for j = 1:length(fieldStrings)
        iStruct.(modName).(fieldStrings{j}) = currentTrialMatrix(i,j);
    end
    structArray{i} = iStruct;
end

% pass this onto PLDAPS
p.trial.TRIAL_MATRIX_FILEPATH       = session.trialMatrixFile;
p.conditions                        = structArray;
p.defaultParameters.pldaps.finish   = length(p.conditions);

% start from where we left
p.trial.(modName).sessionTrialIndex  = session.sessionTrialIndex;
p.trial.(modName).successfulTrialCount  = 0;
        

 