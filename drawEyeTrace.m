function drawEyeTrace(p, targetScreenPointer)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
% 

%draw the eyepositon to the second srceen only
%move the color and size parameters to
%p.trial.pldaps.draw.eyepos?
modName             = p.trial.modName;



if p.trial.pldaps.draw.eyepos.use
    
    % Need to translate coordinate w.r.t. screen center
    screenCenter    = p.trial.display.ctr;
    x_0             = screenCenter(1);
    y_0             = screenCenter(2);

    eyeTrace_X = p.trial.eyeTraceXY(:,1) - x_0;
    eyeTrace_Y = p.trial.eyeTraceXY(:,2) - y_0;
    
    traceLength_sec     = p.trial.(modName).gaze.trace_history_sec;
    traceLength         = floor(traceLength_sec / p.trial.display.ifi);
    if(length(eyeTrace_X) < traceLength)
        traceLength = length(eyeTrace_X);
    end
    if(traceLength > 1)
        dotPositionMatrix = [eyeTrace_X(end-traceLength+1:end)'; ...
            eyeTrace_Y(end-traceLength+1:end)'];
        % WTF! i can't use custom colors for the overlay. I can
        % only use p.trial.display.clut.window, or
        % p.trial.display.clut.eyepos. I'll have to resort to
        % different sizes for tracing.
        dotColor        = p.trial.display.clut.window;
        dotColors       = repmat(dotColor, [1 traceLength]) .* ...
            repmat(linspace(1,1,traceLength),[length(p.trial.display.clut.window) 1]);
        dotSizes        = repmat(p.trial.(modName).gaze.trace_dot_width, [1 traceLength]) .* linspace(0.5,1.5,traceLength);
        
        Screen('Drawdots',  ...
            targetScreenPointer, ...
            dotPositionMatrix, ...
            dotSizes, ...
            dotColors, ...
            p.trial.display.ctr(1:2), ...
            2);
    else
        Screen('Drawdots',  ...
            targetScreenPointer, ...
            [p.trial.eyeX p.trial.eyeY]', ...
            p.trial.(modName).gaze.trace_dot_width, ...
            p.trial.display.clut.eyepos, ...
            p.trial.display.ctr(1:2), ...
            2);
    end
end

end