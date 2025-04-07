function p = generateImageStimuli(p)
modName             = p.trial.modName;
filepath            = p.trial.TRIAL_MATRIX_FILEPATH;

load(filepath, 'S'); % 'S' is the struct that contains experiment info
currentTrial=p.trial.(modName).sessionTrialIndex;


deg2pix             = p.trial.display.ppd;
screenCenter        = p.trial.display.ctr;

% screen center
x_0                 = screenCenter(1);
y_0                 = screenCenter(2);
%originPix           = [x_0, y_0]';

% image center 
x_deg               = p.trial.(modName).stimulus.image.location.X_DEG;
y_deg               = p.trial.(modName).stimulus.image.location.Y_DEG;

% x_deg               = x_deg - x_0;
% y_deg               = y_0 - y_deg;

img_center_x        = x_deg * deg2pix;
img_center_y        = -y_deg * deg2pix;

% stimulus.image.size.DIAMETER_DEG        = 15;
% stimulus.image.location.X_DEG           = -5; %[-4, 0];
% stimulus.image.location.Y_DEG           = -5; %[-4, 0];

img_diameter_pixels = round(p.trial.(modName).stimulus.image.size.DIAMETER_DEG * deg2pix);
% img_radius_pixels   = floor(img_diameter_pixels / 2);

img_index_list      = S.trialMatrix(currentTrial,S.trialMatrix_index.IMAGE_LIST_0:S.trialMatrix_index.IMAGE_LIST_1);%%p.trial.(modName).imageList{p.trial.imagesequences.trialMatrixIndex};
num_img_in_trial    = p.trial.(modName).NUM_IMAGES_TRIAL;%length(img_index_list);
num_frame_per_img    = p.trial.(modName).NUM_FRAME;
texture_pointers    = nan(num_img_in_trial, 1);

% Vignette (need to resize when generating actual image stimulus)
flattop8            = im2double(imread('Flattop8.tif'));
flattop8            = squeeze(flattop8(:,:,end));
flattop8            = flattop8 ./ max(flattop8(:));
maskImg             = imresize(flattop8,[img_diameter_pixels, img_diameter_pixels]);
pixelRange          = 2^p.trial.(modName).stimulus.image.pixelBitDepth;
bgIntensityNormalized   = p.trial.display.bgColor(end);
bgIntensity         = bgIntensityNormalized * pixelRange;
for iI = 1:num_img_in_trial
    
    imgO               = load(fullfile('./uncertainty_stimulus/',p.trial.(modName).imageList{img_index_list(iI)}));
    %img                 = imread(fullfile('./Stimulus/', sprintf('%03d.png', img_index_list(i))));
    %keyboard
    for iF=1:num_frame_per_img
        img = imgO.trial(1:img_diameter_pixels,1:img_diameter_pixels,iF);
        %img                 = imresize(img, [img_diameter_pixels, img_diameter_pixels]);
        if imgO.Stim.param(imgO.Stim.index.CONTRAST)==0
           img = img*0 +.5; % add blanks
        end

        img                 = img - bgIntensityNormalized;
        img                 = img .* maskImg;
        img                 = img + bgIntensityNormalized;
        img                 = uint8(img.*pixelRange);
        texture_pointers(iF,iI) = Screen('MakeTexture', p.trial.display.ptr, img);
    end
  
end
texture_pointers=texture_pointers(:);
theRect = [0 0 img_diameter_pixels img_diameter_pixels];
%CenterRectOnPointd(theRect, x_0, y_0);

% pass this onto PLDAPS 
p.trial.(modName).stimulus.image.pointers   = texture_pointers;
p.trial.(modName).stimulus.image.srcRect    = CenterRectOnPoint(theRect, x_0, y_0);
p.trial.(modName).stimulus.image.dstRect    = OffsetRect(p.trial.(modName).stimulus.image.srcRect, img_center_x, img_center_y);