function drawGainOffsetText(p, targetScreenPointer)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%

modName             = p.trial.modName;


x_text                  = sprintf('X: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.x_gain, p.trial.(modName).gaze.x_offset);
y_text                  = sprintf('Y: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.y_gain, p.trial.(modName).gaze.y_offset);
increment_size_text     = sprintf('increment size: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.gain_step_size, p.trial.(modName).gaze.offset_step_size);


% if(p.trial.eyeTrackerToggle == false) % adjust X
%     Screen('TextSize',targetScreenPointer, 25);
%     DrawFormattedText(targetScreenPointer, x_text, 50,  50, [255,   0,   0, 255]);
%     Screen('TextSize',targetScreenPointer, 15);
%     DrawFormattedText(targetScreenPointer, y_text, 50, 80, [255, 255, 255, 255]);
% else
%     Screen('TextSize',targetScreenPointer, 15);
%     DrawFormattedText(targetScreenPointer, x_text, 50,  50, [255, 255, 255, 255]);
%     Screen('TextSize',targetScreenPointer, 25);
%     DrawFormattedText(targetScreenPointer, y_text, 50, 80, [255,   0,   0, 255]);
% end

text(0, 0.9, x_text, 'fontsize', 20); drawnow;
text(0, 0.7, y_text, 'fontsize', 20); drawnow;

end 