function drawFixationPoint(p)
% DRAWFIXATIONPOINT draws the fixation point. If color is not specified,
% default color is white. Value of 'color' is defined in the 'TrialMatrix'.
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%


if nargin < 2 
    colorVec = p.trial.display.monkeyCLUT(7,:);
else
    colorVec = p.trial.display.monkeyCLUT(color,:);
end

% Need to translate coordinate w.r.t. screen center
screenCenter            = p.trial.display.ctr;
x_0                     = screenCenter(1);
y_0                     = screenCenter(2);

% draw fixation point
modName                 = p.trial.modName;
deg2pix                 = p.trial.display.ppd;

fp_diameter_deg         = p.trial.(modName).stimulus.fp.size.curr_diameter_deg;
fixPointRect            = [0, 0, ...
                        fp_diameter_deg * deg2pix, ...
                        fp_diameter_deg * deg2pix];

donutRect               = [0, 0, ...
                        2*fp_diameter_deg * deg2pix, ...
                        2*fp_diameter_deg * deg2pix];
                    
fp_x_pixels             = p.trial.(modName).stimulus.fp.location.X_DEG * deg2pix + x_0;
fp_y_pixels             = y_0 - p.trial.(modName).stimulus.fp.location.Y_DEG * deg2pix;
centeredFixPointRect    = CenterRectOnPointd(fixPointRect, ...
                            fp_x_pixels, ...
                            fp_y_pixels);

centeredDonutRect       = CenterRectOnPointd(donutRect, ...
                            fp_x_pixels, ...
                            fp_y_pixels);

blackColor              = p.trial.display.monkeyCLUT(10,:);

% centeredFixPointRect    = CenterRectOnPointd(fixPointRect, ...
%                                     p.trial.display.ctr(1), ...
%                                     p.trial.display.ctr(2));
%                                 
%Screen('FillRect', p.trial.display.ptr, colorVec, centeredFixPointRect);

if(p.trial.(modName).stimulus.fp.shape.current == p.trial.(modName).stimulus.fp.shape.SQUARE)
    Screen('FillRect', p.trial.display.ptr, colorVec, centeredFixPointRect);
elseif(p.trial.(modName).stimulus.fp.shape.current == p.trial.(modName).stimulus.fp.shape.CIRCLE)
    Screen('FillOval', p.trial.display.ptr, blackColor, centeredDonutRect);
    Screen('FillOval', p.trial.display.ptr, colorVec,   centeredFixPointRect);
end

% 
% 
% % struct-field where all of our conditions reside.
% modName                 = p.trial.modName;
% 
% deg2pix                 = p.trial.display.ppd;
% 
% % Need to translate coordinate w.r.t. screen center
% screenCenter            = p.trial.display.ctr;
% x_0                     = screenCenter(1);
% y_0                     = screenCenter(2);
% 
% % For specific field names, refer to 'loadBlockTrialMatrixFromFile.m'
% %   OR 'createTrialMatrix.m'
% fp_diameter_pixels      = p.trial.(modName).stimulus.size.DIAMETER_DEG * deg2pix;
% fp_colorVector          = p.trial.display.monkeyCLUT(p.trial.(modName).stimulus.color.COLOR_INDEX, :);
% fp_x_pixels             = p.trial.(modName).X_DEG * deg2pix + x_0;
% fp_y_pixels             = y_0 - p.trial.(modName).Y_DEG * deg2pix;
% 
% fixPointRect            = [0, 0, fp_diameter_pixels, fp_diameter_pixels];
% 
% centeredFixPointRect    = CenterRectOnPointd(fixPointRect, ...
%     fp_x_pixels, ...
%     fp_y_pixels);
% 
% if(p.trial.(modName).stimulus.shape.current == p.trial.(modName).stimulus.shape.SQUARE)
%     Screen('FillRect', targetScreenPointer, fp_colorVector, centeredFixPointRect);
% elseif(p.trial.(modName).stimulus.shape.current == p.trial.(modName).stimulus.shape.CIRCLE)
%     Screen('FillOval', targetScreenPointer, fp_colorVector, centeredFixPointRect);
% end

end