function drawImageStimulus(p)
% DRAWIMAGESTIMULUS draws the current image 
% specified by 'p.trial.(modName).states.current_img_index'
%
% 2018-05-15  YB   wrote it. <yoonbai@utexas.edu>
%

texturePtrIndex         = p.trial.(modName).videoList(p.trial.(modName).sessionTrialIndex);

Screen('DrawTextures', p.trial.display.ptr, ...
    p.trial.(modName).stimulus.image.pointers(texturePtrIndex), ...
    [], ...
    p.trial.(modName).stimulus.image.dstRect);

