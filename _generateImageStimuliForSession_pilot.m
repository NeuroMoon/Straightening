function p = generateImageStimuliForSession_pilot(p)

modName             = p.trial.modName;

deg2pix             = p.trial.display.ppd;
screenCenter        = p.trial.display.ctr;

% screen center
x_0                 = screenCenter(1);
y_0                 = screenCenter(2);

% image center 
x_deg               = p.trial.(modName).stimulus.image.location.X_DEG;
y_deg               = p.trial.(modName).stimulus.image.location.Y_DEG;

img_center_x        =  x_deg * deg2pix;
img_center_y        = -y_deg * deg2pix;

img_diam_pixels         = round(ImageSequences.CONSTANTS_PILOT.NATIVE_IMAGE_DIAM_DEG * deg2pix);
vignette_diam_pixels    = round(p.trial.(modName).stimulus.image.size.DIAMETER_DEG * deg2pix);

texture_pointers    = nan(p.trial.(modName).NUM_UNIQ_IMAGES, 1);

maskImg             = zeros(img_diam_pixels, img_diam_pixels);
apply_mask          = ImageSequences.CONSTANTS_PILOT.APPLY_VIGNETTE || img_diam_pixels ~= vignette_diam_pixels;
if(apply_mask)
    % Vignette (need to resize when generating actual image stimulus)
    flattop8                = im2double(imread(fullfile(ImageSequences.CONSTANTS_PILOT.STIMULUS_FOLDER, ImageSequences.CONSTANTS_PILOT.MASK_FOLDER, 'Flattop8.tif')));
    flattop8                = squeeze(flattop8(:,:,end));
    flattop8                = flattop8 ./ max(flattop8(:));
    maskImg_tmp             = imresize(flattop8,[vignette_diam_pixels, vignette_diam_pixels]);
    
    % place mask to center of image
    offset                  = floor((img_diam_pixels - vignette_diam_pixels)/2);
    y_location              = offset+1 : offset+vignette_diam_pixels;
    x_location              = offset+1 : offset+vignette_diam_pixels;
    maskImg(y_location, x_location) = maskImg_tmp;
end

pixelRange              = 2^p.trial.(modName).stimulus.image.pixelBitDepth;
bgIntensityNormalized   = p.trial.display.bgColor(end);

for i = 1:p.trial.(modName).NUM_UNIQ_IMAGES
    
    if(p.trial.(modName).UNIQ_IMAGES(i) > ImageSequences.CONSTANTS_PILOT.BLANK)
        % X2 subsampling
        img_filepath    = fullfile(ImageSequences.CONSTANTS_PILOT.STIMULUS_FOLDER, ImageSequences.CONSTANTS_PILOT.SUBSAMPLE_FOLDERS{2}, sprintf('%03d.png', p.trial.(modName).UNIQ_IMAGES(i)));
    else
        img_filepath    = fullfile(ImageSequences.CONSTANTS_PILOT.STIMULUS_FOLDER, ImageSequences.CONSTANTS_PILOT.SUBSAMPLE_FOLDERS{1}, sprintf('%03d.png', p.trial.(modName).UNIQ_IMAGES(i)));
    end
    img                 = im2double(imread(img_filepath));
    
    % enforce normalized background luminance to be zero
    img                 = img - mean([img(1,1),img(1,end),img(end,1),img(end,end)]);
    img                 = img + p.trial.display.bgColor(end);
    
    img                 = imresize(img, [img_diam_pixels, img_diam_pixels]);
    
    if(apply_mask)
        img                 = img - bgIntensityNormalized;
        img                 = img .* maskImg;
        img                 = img + bgIntensityNormalized; 
    end
    img                 = uint8(img .* pixelRange);
    
    texture_index       = p.trial.(modName).UNIQ_IMAGES(i);
    texture_pointers(texture_index) = Screen('MakeTexture', p.trial.display.ptr, img);
    
end
theRect = [0 0 img_diam_pixels img_diam_pixels];

% pass this onto PLDAPS 
p.trial.(modName).stimulus.image.pointers   = texture_pointers;
p.trial.(modName).stimulus.image.srcRect    = CenterRectOnPoint(theRect, x_0, y_0);
p.trial.(modName).stimulus.image.dstRect    = OffsetRect(p.trial.(modName).stimulus.image.srcRect, img_center_x, img_center_y);

