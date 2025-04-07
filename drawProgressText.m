function drawProgressText(p, targetScreenPointer)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%

modName = p.trial.modName;
progress_text                  = sprintf('trial %d(%d)/%d', p.trial.(modName).sessionTrialIndex, p.trial.pldaps.iTrial, length(p.conditions));
Screen('TextSize',targetScreenPointer, 20);
DrawFormattedText(targetScreenPointer, progress_text, 50,  100, [255, 255, 255, 255]);
 
% progress_text = sprintf('Session index: %d, iTrial: %d, Total: %d', p.trial.(modName).sessionTrialIndex, p.trial.pldaps.iTrial, length(p.conditions));
% 
% text(0, 0.5, progress_text, 'fontsize', 20); drawnow;
end 