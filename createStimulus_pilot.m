clear;
stim_db_folder      = 'stimulus_database';
subsample_folders   = {'awake_subs1', 'awake_subs2'};
zoom_folder         = 'stimSelected-zoom1x';

movies              = {'movie01-chironomus', ...
                        'movie04-egomotion', ...
                        'movie05-prairie1', ...
                        'movie06-carnegie_dam'};
movie_categories    = {'natural', 'synthetic'};
    
blank_id            = 500;

X = 512;
Y = 512;

    
for speed = 1:length(subsample_folders)
    
    uniq_img_id         = 1;
    folder_out          = fullfile('./Stimulus_pilot', subsample_folders{speed});
    
    for i = 1:length(movies)
        
        natural_seq_idx     = [];
        movie_folder        = fullfile(stim_db_folder, subsample_folders{speed}, zoom_folder, movies{i});
        
        for j = 1:length(movie_categories)
            
            files           = dir([movie_folder, '/', movie_categories{j}, '*']);
            if(~isempty(files))
                
                [~, ~, fext]    = fileparts(files(1).name);
                
                if(strcmp(movie_categories{j}, 'natural'))
                    natural_seq_idx = 1:numel(files);
                    file_idx    = natural_seq_idx;
                elseif(strcmp(movie_categories{j}, 'synthetic'))
                    file_idx    = natural_seq_idx(2:end-1);
                end
                
                for k = file_idx
                    
                    old_filepath    = fullfile(files(k).folder, files(k).name);
                    
                    if(speed == 1) % original frame rate
                        new_filename    = sprintf('%s%s', num2str(uniq_img_id,'%03.f'), fext);
                    else           % twice the frame rate 
                        new_filename    = sprintf('%s%s', num2str(uniq_img_id + blank_id,'%03.f'), fext);
                    end
                    
                    new_filepath    = fullfile(folder_out, new_filename);
                    
                    
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
    end
end % speed

