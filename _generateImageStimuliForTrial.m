function p = generateImageStimuliForTrial(p)

modName             = p.trial.modName;

deg2pix             = p.trial.display.ppd;
screenCenter        = p.trial.display.ctr;

% screen center
x_0                 = screenCenter(1);
y_0                 = screenCenter(2);

% image center 
x_deg               = p.trial.(modName).stimulus.image.location.X_DEG;
y_deg               = p.trial.(modName).stimulus.image.location.X_DEG;

% x_deg               = x_deg - x_0;
% y_deg               = y_0 - y_deg;

img_center_x        = x_deg * deg2pix;
img_center_y        = -y_deg * deg2pix;

% stimulus.image.size.DIAMETER_DEG        = 15;
% stimulus.image.location.X_DEG           = -5; %[-4, 0];
% stimulus.image.location.Y_DEG           = -5; %[-4, 0];

img_diameter_pixels = p.trial.(modName).stimulus.image.size.DIAMETER_DEG * deg2pix;
% img_radius_pixels   = floor(img_diameter_pixels / 2);

img_index_list      = p.trial.(modName).imageList{p.trial.imagesequences.sessionTrialIndex};
num_img_in_trial    = length(img_index_list);
texture_pointers    = nan(num_img_in_trial, 1);

% Vignette (need to resize when generating actual image stimulus)
flattop8            = im2double(imread('./Stimulus/Flattop8.tif'));
flattop8            = squeeze(flattop8(:,:,end));
flattop8            = flattop8 ./ max(flattop8(:));
maskImg             = imresize(flattop8,[img_diameter_pixels, img_diameter_pixels]);
pixelRange          = 2^p.trial.(modName).stimulus.image.pixelBitDepth;
bgIntensityNormalized   = p.trial.display.bgColor(end);
bgIntensity         = bgIntensityNormalized * pixelRange;
for i = 1:num_img_in_trial
    
    img                 = im2double(imread(fullfile('./Stimulus/', sprintf('%03d.png', img_index_list(i)))));
    %img                 = imread(fullfile('./Stimulus/', sprintf('%03d.png', img_index_list(i))));
    img                 = imresize(img, [img_diameter_pixels, img_diameter_pixels]);
  
  
    img                 = img - bgIntensityNormalized;
    img                 = img .* maskImg;
    img                 = img + bgIntensityNormalized;
    img                 = uint8(img.*pixelRange);
    texture_pointers(i) = Screen('MakeTexture', p.trial.display.ptr, img);
    
end
theRect = [0 0 img_diameter_pixels img_diameter_pixels];
%CenterRectOnPointd(theRect, x_0, y_0);

% pass this onto PLDAPS 
p.trial.(modName).stimulus.image.pointers   = texture_pointers;
p.trial.(modName).stimulus.image.srcRect    = CenterRectOnPoint(theRect, x_0, y_0);
p.trial.(modName).stimulus.image.dstRect    = OffsetRect(p.trial.(modName).stimulus.image.srcRect, img_center_x, img_center_y);


%{
%% Stimulus dimensions

% position & diameter are hard coded for now
x_deg       = p.trial.(modName).grating.location.X_DEG
y_deg       = p.trial.(modName).grating.location.Y_DEG
img_center_x       = x_deg * deg2pix;
img_center_y       = y_deg * deg2pix;
diameter_pix= p.trial.(modName).grating.size.DIAMETER_DEG * deg2pix;
TF          = p.trial.(modName).grating.TF; % cyc/sec
SF          = p.trial.(modName).grating.SF; % cyc/deg
phase       = p.trial.(modName).grating.phase; % sine grating or cosine grating?

backgroundColorOffset       = [0,0,0,0];

% WARNING: This is a PRE-multiplier that PTB asks for. Need to verify if
% '1'   will produce the intended michelson contrast or if
% '0.5' will produce the intended michelson contrast!
contrastPreMultiplicator    = 1;

[texPtr, texRect] = ...
    CreateProceduralSineGrating( ...
        p.trial.display.ptr, ...
        round(diameter_pix), ...
        round(diameter_pix), ...
        backgroundColorOffset, ...
        round(diameter_pix/2), ...
        contrastPreMultiplicator);
% 
% [texPtr, texRect] = ...
%     OriDiscFlex.CreateProceduralSineGrating_vignetted( ...
%         p.trial.display.ptr, ...
%         round(diameter_pix), ...
%         round(diameter_pix), ...
%         backgroundColorOffset, ...
%         round(diameter_pix/2), ...
%         contrastPreMultiplicator);

% pass this onto PLDAPS 
p.trial.(modName).grating.ptr        = texPtr;
p.trial.(modName).grating.srcRect    = CenterRectOnPoint(texRect, x_0, y_0);
p.trial.(modName).grating.dstRect    = OffsetRect(p.trial.(modName).grating.srcRect, img_center_x, img_center_y);

newRect = OffsetRect(p.trial.(modName).grating.dstRect, 1,1);
p.trial.(modName).grating.maskRect = newRect;
 
    % Find the color values which correspond to white and black.
    
    gray = 128; 

    % Import image and and convert it, stored in
    % MATLAB matrix, into a Psychtoolbox OpenGL texture using 'MakeTexture';
    maskdata = uint8(imread('Flattop8.tif'));
    
    % Scale flattop8
    maskdata = 255 - imresize(maskdata, [round(diameter_pix) round(diameter_pix)]);
    
    
    % We create a Luminance+Alpha matrix for use as transparency mask:
    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.
    
    transLayer=2; 
    maskblob = uint8(ones(size(maskdata ,1), size(maskdata ,1), transLayer) * gray);

    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    maskblob(:,:,transLayer) = maskdata(:,:,1);
    
    % Build a single transparency mask texture
    masktex=Screen('MakeTexture', p.trial.display.ptr;, maskblob);
    p.trial.(modName).grating.mask = masktex;

end

%}