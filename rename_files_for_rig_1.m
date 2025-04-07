clear;
stim_folder         = 'stimSelected_awake_pilot_zoom1x';
subsample_folders   = {'subsample_1', 'subsample_2'};

%%% pilot %%%
% #1:   1 natural movie from acute (zoom1x, subsample 1): chironomus (acute)
% #2,3: 2 natural movies   (zoom1x, subsample 2): prairie1, carnegie-dam
% #4,5: 2 synthetic movies (zoom1x, subsample 2): chironomus*, carnegie-dam
movie_folders{1}    = fullfile(stim_folder, subsample_folders{1}, 'movie05-prairie1');
movie_folders{2}    = fullfile(stim_folder, subsample_folders{2}, 'movie01-chironomus');
movie_folders{3}    = fullfile(stim_folder, subsample_folders{2}, 'movie06-carnegie-dam');
movie_folders{4}    = fullfile(stim_folder, subsample_folders{2}, 'movie01-chironomus');
movie_folders{5}    = fullfile(stim_folder, subsample_folders{2}, 'movie06-carnegie-dam');

movie_categories    = {'natural', 'natural', 'natural', 'synthetic', 'synthetic'};

folder_out          = 'stimulus_pilot_0913';
uniq_img_id         = 1;

X = 512;
Y = 512; 
for i = 1:length(movie_folders)
    
    files           = dir([movie_folders{i}, '/', movie_categories{i}, '*']);
    if(~isempty(files))
        [~, ~, fext]    = fileparts(files(1).name);
        
        for j = 1:length(files)
            
            old_filepath    = fullfile(files(j).folder, files(j).name);
            
            new_filename    = sprintf('%s%s', num2str(uniq_img_id,'%03.f'), fext);
            new_filepath    = fullfile(stim_folder, folder_out, new_filename);
            
            
            img             = im2double(imread(old_filepath));
            if(size(img) ~= [Y,X])
                new_img      = imresize(img, [Y,X]); 
                imwrite(new_img, new_filepath);
                
            else
                copyfile(old_filepath, new_filepath);
            end
            
            uniq_img_id     = uniq_img_id + 1;
        end
    end
end

