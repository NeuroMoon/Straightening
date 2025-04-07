function bool = isFixating(p)
% ISFIXATION returns a boolean value to indicate whether subject gaze is 
% within a pre-defined boundary around the fixation point.
% 
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%

%bool = true;

% Identify the field where all of our custom variables reside (this will be
% useful for 'modular' PLDAPS).
modName                 = p.trial.modName;

% Convert visual degrees to pixels
deg2pix                 = p.trial.display.ppd;

% Need to translate coordinate w.r.t. screen center
screenCenter            = p.trial.display.ctr;
x_0                     = screenCenter(1);
y_0                     = screenCenter(2); % REMINDER: Y coordinate values increase when going downward!

% fixation point location. The origin (0,0) corresponds to the [x_0, y_0]
centered_fix_X          = p.trial.(modName).stimulus.fp.location.X_DEG * deg2pix;
centered_fix_Y          = p.trial.(modName).stimulus.fp.location.Y_DEG * deg2pix;

% gaze (centered eye positions) w.r.t. center of monitor
centered_eye_X          = p.trial.eyeX - x_0;
centered_eye_Y          = y_0 - p.trial.eyeY;

distance_pixels         = distanceFromFixationPoint(centered_eye_X, centered_eye_Y, centered_fix_X, centered_fix_Y);

% eye movement allowance
fix_threshold_pixels    = p.trial.(modName).gaze.curr_window_radius_deg * deg2pix;

bool                                = distance_pixels < fix_threshold_pixels;

p.trial.(modName).isFixating   =  bool;