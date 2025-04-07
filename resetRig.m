close all;
clear java;

% Reset time synchronization
PsychTweak('reset');

Datapixx('Reset');
PsychDataPixx('ClearTimestampLog');
VBLSyncTest(1000, 0, 0.6, 0, 0, 1, 0,2,1)

% % additional calibrations...
% BitsPlusImagingPipelineTest(1); % monitor #1
% BitsPlusIdentityClutTest(1, 1); % monitor #2 (w/ datapixx)