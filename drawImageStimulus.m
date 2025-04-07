function drawImageStimulus(p)
% DRAWIMAGESTIMULUS draws the current image 
% specified by 'p.trial.(modName).states.current_img_index'
%
% 2018-05-15  YB   wrote it. <yoonbai@utexas.edu>
%

modName                 = p.trial.modName;
current_image_idx       = p.trial.(modName).states.current_img_index;
current_frame_idx= ((current_image_idx*p.trial.(modName).NUM_FRAME)-p.trial.(modName).NUM_FRAME)+  p.trial.(modName).states.current_frame_index;
% when using 'generateImageStimuliForSession.m'
texturePtrIndex         = current_frame_idx;%p.trial.(modName).imageList{p.trial.(modName).sessionTrialIndex}(current_image_idx);

Screen('DrawTextures', p.trial.display.ptr, ...
    p.trial.(modName).stimulus.image.pointers(texturePtrIndex), ...
    [], ...
    p.trial.(modName).stimulus.image.dstRect);

