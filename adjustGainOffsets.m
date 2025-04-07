function adjustGainOffsets(p)
%
% 2017-11-20  YB   wrote it. <yoonbai@utexas.edu>
%

modName         = p.trial.modName;


% GAIN keys
keyCode_up      = p.trial.keyboard.codes.Uarrow;
keyCode_down    = p.trial.keyboard.codes.Darrow;
keyCode_g       = p.trial.keyboard.codes.gKey;

% OFFSET keys
keyCode_left    = p.trial.keyboard.codes.Larrow;
keyCode_right   = p.trial.keyboard.codes.Rarrow;
keyCode_o       = p.trial.keyboard.codes.oKey;

% X key
keyCode_x       = p.trial.keyboard.codes.xKey;

% Y key
keyCode_y       = p.trial.keyboard.codes.yKey;

if p.trial.keyboard.pressedQ
    % TO DO: consider using switch-case statements instead of multiple
    % if-else statements. Switch-cases are more efficient for single-event
    % key strokes. 
    
    % There is a bug here. Can you fix it please?
    if(p.trial.keyboard.firstPressQ(keyCode_x) || p.trial.keyboard.firstPressQ(keyCode_y))
        p.trial.eyeTrackerToggle = ~p.trial.eyeTrackerToggle;
    end
    
    
    %% OFFSET
    % check up arrow
    if(p.trial.keyboard.firstPressQ(keyCode_up))
        if(p.trial.eyeTrackerToggle == 0) % adjust X
            p.trial.(modName).gaze.x_offset = p.trial.(modName).gaze.x_offset + p.trial.(modName).gaze.offset_step_size;
        else
            p.trial.(modName).gaze.y_offset = p.trial.(modName).gaze.y_offset + p.trial.(modName).gaze.offset_step_size;
        end
        
    end
    
    % check down arrow
    if(p.trial.keyboard.firstPressQ(keyCode_down))
        if(p.trial.eyeTrackerToggle == 0) % adjust X
            p.trial.(modName).gaze.x_offset = p.trial.(modName).gaze.x_offset - p.trial.(modName).gaze.offset_step_size;
        else
            p.trial.(modName).gaze.y_offset = p.trial.(modName).gaze.y_offset - p.trial.(modName).gaze.offset_step_size;
        end
        
    end
    
    % check 'o' key
    if(p.trial.keyboard.firstPressQ(keyCode_o))
        p.trial.(modName).gaze.offset_step_size = p.trial.(modName).gaze.offset_step_size + 0.10;
    end
    
    %% GAIN
    % check left arrow
    if(p.trial.keyboard.firstPressQ(keyCode_left))
        if(p.trial.eyeTrackerToggle == 0) % adjust X
            p.trial.(modName).gaze.x_gain = p.trial.(modName).gaze.x_gain - p.trial.(modName).gaze.gain_step_size;
        else
            p.trial.(modName).gaze.y_gain = p.trial.(modName).gaze.y_gain - p.trial.(modName).gaze.gain_step_size;
        end
    end
    
    % check right arrow
    if(p.trial.keyboard.firstPressQ(keyCode_right))
        if(p.trial.eyeTrackerToggle == 0) % adjust X
            p.trial.(modName).gaze.x_gain = p.trial.(modName).gaze.x_gain + p.trial.(modName).gaze.gain_step_size;
        else
            p.trial.(modName).gaze.y_gain = p.trial.(modName).gaze.y_gain + p.trial.(modName).gaze.gain_step_size;
        end
    end
    
    % check 'g' key
    if(p.trial.keyboard.firstPressQ(keyCode_g))
        p.trial.(modName).gaze.gain_step_size = p.trial.(modName).gaze.gain_step_size + 0.10;
    end
    
    
    clf; axis off;
    x_text = sprintf('X: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.x_gain, p.trial.(modName).gaze.x_offset);
    y_text = sprintf('Y: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.y_gain, p.trial.(modName).gaze.y_offset);

    text(0, 0.9, x_text, 'fontsize', 20); drawnow;
    text(0, 0.7, y_text, 'fontsize', 20); drawnow;
    
%     progress_text = sprintf('Session index: %d, iTrial: %d, Success: %d, Total: %d', p.trial.(modName).sessionTrialIndex, p.trial.pldaps.iTrial, p.trial.(modName).successfulTrialCount, length(p.conditions));
%     text(0, 0.5, progress_text, 'fontsize', 20); drawnow;
            
    
end

% if APPLY_CENTERING is true, adjust offset & gain w.r.t. screen center
APPLY_CENTERING = true; 

screenCenter    = p.trial.display.ctr;
x_0             = screenCenter(1);
y_0             = screenCenter(2);

deg2pix         = p.trial.display.ppd;

gain_x          = p.trial.(modName).gaze.x_gain;
offset_x        = p.trial.(modName).gaze.x_offset * deg2pix;

gain_y          = p.trial.(modName).gaze.y_gain;
offset_y        = p.trial.(modName).gaze.y_offset * deg2pix;

if(p.trial.eyelink.useAsEyepos) 
    
    eyeIdx      = p.trial.eyelink.eyeIdx;
    % calibrated X samples starts at 'eyeIdx+13'. For raw X samples, it is 'raw=14: left x; raw=15: right x'
    % calibrated Y samples starts at 'eyeIdx+15'. For raw Y samples, it is 'raw=16: left y; raw=17: right y'
         
    if p.trial.pldaps.eyeposMovAv > 1
        if(~APPLY_CENTERING)
            eInds        = (p.trial.eyelink.sampleNum - p.trial.pldaps.eyeposMovAv+1) : p.trial.eyelink.sampleNum;
            p.trial.eyeX = gain_x * (mean(p.trial.eyelink.samples(eyeIdx+13, eInds)) + offset_x);
            p.trial.eyeY = gain_y * (mean(p.trial.eyelink.samples(eyeIdx+15, eInds)) - offset_y);
        else
            eInds        = (p.trial.eyelink.sampleNum - p.trial.pldaps.eyeposMovAv+1) : p.trial.eyelink.sampleNum;
            centered_x   = mean(p.trial.eyelink.samples(eyeIdx+13, eInds)) - x_0;
            centered_y   = mean(p.trial.eyelink.samples(eyeIdx+15, eInds)) - y_0;
            p.trial.eyeX = gain_x * (centered_x + x_0 + offset_x);
            p.trial.eyeY = gain_y * (centered_y + y_0 - offset_y);
        end
        
    else
        if(~APPLY_CENTERING)
            p.trial.eyeX = gain_x * (p.trial.eyelink.samples(eyeIdx+13, p.trial.eyelink.sampleNum) + offset_x); % raw=14: left x; raw=15: right x
            p.trial.eyeY = gain_y * (p.trial.eyelink.samples(eyeIdx+15, p.trial.eyelink.sampleNum) - offset_y); % raw=16: left y; raw=17: right x
        else
            centered_x   = p.trial.eyelink.samples(eyeIdx+13, p.trial.eyelink.sampleNum) - x_0;
            centered_y   = p.trial.eyelink.samples(eyeIdx+15, p.trial.eyelink.sampleNum) - y_0;
            p.trial.eyeX = gain_x * (centered_x + x_0 + offset_x);
            p.trial.eyeY = gain_y * (centered_y + y_0 - offset_y);
        end
    end
 
elseif(p.trial.mouse.useAsEyepos)
    
    if p.trial.pldaps.eyeposMovAv==1
        
        if(~APPLY_CENTERING)
            p.trial.eyeX = gain_x * (p.trial.mouse.cursorSamples(1,p.trial.mouse.samples) + offset_x);
            p.trial.eyeY = gain_y * (p.trial.mouse.cursorSamples(2,p.trial.mouse.samples) - offset_y);
        else
            centered_x   = p.trial.mouse.cursorSamples(1, p.trial.mouse.samples) - x_0;
            centered_y   = p.trial.mouse.cursorSamples(2, p.trial.mouse.samples) - y_0;
            p.trial.eyeX = gain_x * (centered_x + x_0 + offset_x);
            p.trial.eyeY = gain_y * (centered_y + y_0 - offset_y);
        end
        
    else
        
        if(~APPLY_CENTERING)
            mInds        =(p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
            p.trial.eyeX = gain_x * (mean(p.trial.mouse.cursorSamples(1,mInds)) + offset_x);
            p.trial.eyeY = gain_y * (mean(p.trial.mouse.cursorSamples(2,mInds)) - offset_y);
        else
            mInds        = (p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
            centered_x   = mean(p.trial.mouse.cursorSamples(1,mInds)) - x_0;
            centered_y   = mean(p.trial.mouse.cursorSamples(2,mInds)) - y_0;
            p.trial.eyeX = gain_x * (centered_x + x_0 + offset_x);
            p.trial.eyeY = gain_y * (centered_y + y_0 - offset_y);
        end
        
    end
    
end


end