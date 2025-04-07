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

% image center 
x_deg               = p.trial.(modName).stimulus.image.location.X_DEG;
y_deg               = p.trial.(modName).stimulus.image.location.Y_DEG;

img_center_x        = x_deg * deg2pix;
img_center_y        = -y_deg * deg2pix;

img_diameter_pixels = round(p.trial.(modName).stimulus.image.size.DIAMETER_DEG * deg2pix);

% img_index_list      = S.trialMatrix(currentTrial,S.trialMatrix_index.IMAGE_LIST_0:S.trialMatrix_index.IMAGE_LIST_1);%%p.trial.(modName).imageList{p.trial.imagesequences.trialMatrixIndex};
img_index_list      = p.trial.(modName).imageList{p.trial.imagesequences.trialMatrixIndex};
num_img_in_trial    = p.trial.(modName).NUM_IMAGES_TRIAL;%length(img_index_list);
num_frame_per_img   = p.trial.(modName).NUM_FRAME;
texture_pointers    = nan(num_frame_per_img,num_img_in_trial);

% Vignette (need to resize when generating actual image stimulus)
flattop8            = im2double(imread('Flattop8.tif'));
flattop8            = squeeze(flattop8(:,:,end));
flattop8            = flattop8 ./ max(flattop8(:));
maskImg             = imresize(flattop8,[img_diameter_pixels, img_diameter_pixels]);
pixelRange          = 2^p.trial.(modName).stimulus.image.pixelBitDepth;
bgIntensityNormalized   = p.trial.display.bgColor(end);

file = dir('Video/*.mat');
for iV = 1:length(S.(modName).videoList)
    load(file(S.(modName).videoList(iV)).name);
    for iF=1:num_frame_per_img
        texture_pointers(iV,iF) = Screen('MakeTexture', p.trial.display.ptr, im(:,:,iF));
    end
  
end
theRect = [0 0 img_diameter_pixels img_diameter_pixels];

% pass this onto PLDAPS 
p.trial.(modName).stimulus.image.pointers   = texture_pointers;
p.trial.(modName).stimulus.image.srcRect    = CenterRectOnPoint(theRect, x_0, y_0);
p.trial.(modName).stimulus.image.dstRect    = OffsetRect(p.trial.(modName).stimulus.image.srcRect, img_center_x, img_center_y);