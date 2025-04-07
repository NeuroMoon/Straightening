function p = trialFunction(p, state)
% TRIALFUNCTION is a function to link your own task sequence to PLDAPS. This
% specific format depends on the requirements of PLDAPS. This function
% gets called for every frame and changes internal PLDAPS states. PLDAPS 
% cycles through states that are pre-defined (default) or custom-built.
% Default states are provided by 'pldapsDefaultTrialFunction()'.
% It is strongly recommended to build your code on top of 
% 'pldapsDefaultTrialFunction()'.
%
% What are these states? 
% PLDAPS states are designed to operate at the level of individual frames
% and synchronizing data acquitition with Plexon and PTB.
%
% Default order of state-traversal:
%
% 1. p.trial.pldaps.trialStates.frameUpdate
% 2. p.trial.pldaps.trialStates.framePrepareDrawing
% 3. p.trial.pldaps.trialStates.frameDraw
% .. p.trial.pldaps.trialStates.frameIdlePreLastDraw;
% .. p.trial.pldaps.trialStates.frameDrawTimecritical;
% 6. p.trial.pldaps.trialStates.frameDrawingFinished;
% .. p.trial.pldaps.trialStates.frameIdlePostDraw;       
% 8. p.trial.pldaps.trialStates.frameFlip;
% .. means not implemented by PLDAPS version 4.2 (open-reception branch)
%
% CAUTION: if a certain frame state took too long, everything will get pushed
% back and frames could be dropped (p.data.timing: refer to flip times to double-check)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%  


% Identify the struct-field where all of our variables reside.
modName = p.trial.modName;

% Use PLDAPS' default trial function
pldapsDefaultTrialFunction(p, state, modName);

% Switch among several states at the resolution of individual frames
switch state

    % Arrange in the order of most frequently visited cases--starting with
    % cases that deal functions at the level of individual frames
    
    % FRAME STATES 
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.frameUpdate
        
        % Update circular buffer for eye tracing. Eye positions are updated in 'frameUpdate' in
        % 'pldapsDefaultTrialFunction()'
        Straightening.adjustGainOffsets(p);
        newest              = [p.trial.eyeX, p.trial.eyeY];
        p.trial.eyeTraceXY  = [p.trial.eyeTraceXY(2:end,:); newest];
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(modName).states.previous_state = p.trial.(modName).states.current_state;
        p.trial.(modName).states.current_state  = Straightening.taskSequence(p, p.trial.(modName).states.previous_state);
        
    % *** Present image buffers (do not make textures here. this is designed to
    % "draw" or present pre-existing image buffers. 
    % Also, this is where 'pldapsDefaultTrialFunction()' overlays the grid 
    case p.trial.pldaps.trialStates.frameDraw
        
        % target monitors
        monkeyDisplay       = p.trial.display.ptr;
        experimenterDisplay = p.trial.display.overlayptr;
        
        % image presentation
        if(p.trial.(modName).states.current_state == p.trial.(modName).states.IMG_ON)
            Straightening.drawImageStimulus(p);
            
        end
        
        % keep FP on until FP_OFF
        if(p.trial.(modName).states.current_state <= p.trial.(modName).states.FP_OFF)
            Straightening.drawFixationPoint(p);
            
            % draw fixation boundary (only on the experimenter's monitor)
            Straightening.drawFixationBoundary(p);
        
        end
        
        % EYE trace (only on the experimenter's monitor)
        Straightening.drawEyeTrace(p, experimenterDisplay);
        
        %Straightening.drawGainOffsetText(p, p.trial.display.overlayptr);
        %Straightening.drawProgressText(p, p.trial.display.overlayptr);
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        % boolean status is saved to 'p.trial.Straightening.isFixating'
        %Straightening.isFixating(p); 
        
    % You can modify frame rates here
    case p.trial.pldaps.trialStates.frameFlip
     
        
        
    % TRIAL STATES 
    % --------------------------------------------------------------------%    
    % Called once at the beginning of every trial
    case p.trial.pldaps.trialStates.trialSetup  

        
        % Initialize circular buffer for eye tracing
        buffSize                = floor(0.3 / p.trial.display.ifi); % 0.3 seconds of tracing
        p.trial.eyeTraceXY      = nan(buffSize,2);      
        
        % custom switch to toggle b/w X or Y gain/offset
        p.trial.eyeTrackerToggle = false; 
        
        % load gaze gain/offset from file
        filepath        = p.trial.TRIAL_MATRIX_FILEPATH;
        
        load(filepath, 'S'); % 'S' is the struct that contains experiment info
        p.trial.(modName).gaze.x_gain           = S.(modName).gaze.x_gain;
        p.trial.(modName).gaze.y_gain           = S.(modName).gaze.y_gain;
        p.trial.(modName).gaze.x_offset         = S.(modName).gaze.x_offset;
        p.trial.(modName).gaze.y_offset         = S.(modName).gaze.y_offset;
        p.trial.(modName).gaze.gain_step_size   = S.(modName).gaze.gain_step_size;
        p.trial.(modName).gaze.offset_step_size = S.(modName).gaze.offset_step_size;
        
        % pick up from where we left off
        sessionFolder                           = ['./Data/', datestr(now, 'mm-dd-yyyy'), '/'];
        sessionFilePath                         = [sessionFolder, 'sessionInfo.mat'];
        load(sessionFilePath, 'session');
        p.trial.(modName).sessionTrialIndex     = session.sessionTrialIndex;
        
        progress_text = sprintf('Session index: %d, iTrial: %d, Success: %d, Total: %d', p.trial.(modName).sessionTrialIndex, p.trial.pldaps.iTrial, p.trial.(modName).successfulTrialCount, length(p.conditions));
        text(0, 0.5, progress_text, 'fontsize', 20); drawnow;
        
        clf; axis off;
        x_text = sprintf('X: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.x_gain, p.trial.(modName).gaze.x_offset);
        y_text = sprintf('Y: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.y_gain, p.trial.(modName).gaze.y_offset);
        
        text(0, 0.9, x_text, 'fontsize', 20); drawnow;
        text(0, 0.7, y_text, 'fontsize', 20); drawnow;
            
    % Device buffers are cleared and prepared here (pldapsDefaultTrialFunction.m) 
    case p.trial.pldaps.trialStates.trialPrepare
        
        % start keeping track of timestamps (or framestamps)
        p.trial.(modName).states.timestamps.START = p.trial.ttime;
        if(p.trial.datapixx.use)
            Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, p.trial.(modName).states.START);
        end
        
        % Audible cue
        if(p.trial.sound.use)
           %PsychPortAudio('Start', p.trial.sound.cue, 1, [], [], GetSecs + 0.2);
           PsychPortAudio('Start', p.trial.sound.cue, 1, [], [], []);
        end
            
        % PLDAPS maintenance
        p.trial.pldaps.goodtrial    = false;
        p.trial.finished            = false;
        p.trial.flagNextTrial       = false; % tell PLDAPS not to start next trial
        % each trial has a list of images. this is the image index that
        % gets incremented within each trial ( <= no. of images per trial)
        p.trial.(modName).states.current_img_index = 1;
        p.trial.(modName).states.current_frame_index = 1;
        
    % Called once at the end of every trial 
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % in case we reach max. number of frames...
        if(p.trial.iFrame == p.trial.pldaps.maxFrames)
            p.trial.flagNextTrial = true;
        end
        
        % save inter-trial information (i.e. gain/offset, trial list)
        filepath        = p.trial.TRIAL_MATRIX_FILEPATH;
        load(filepath, 'S'); % 'S' is the struct that contains experiment info
        
        if p.trial.(modName).sessionTrialIndex == 1 % JM 2025-03-21
            counter = 0;
        else
            counter = S.trialMatrix(p.trial.(modName).sessionTrialIndex-1,S.trialMatrix_index.COUNTER);
        end
        
        % determine outcome from subject's response 
        switch p.trial.(modName).response.subjectResponse 
            case p.trial.(modName).response.BREAK_FIX
                
                p.trial.(modName).outcome.trialOutcome = p.trial.(modName).outcome.BREAK_FIX;
                p.trial.(modName).counter = 0; % JM 2025-03-21
                p.trial.(modName).reward.trial.amount = 0; % JM 2025-03-21

            case p.trial.(modName).response.NO_FIXATION
                
                p.trial.(modName).outcome.trialOutcome = p.trial.(modName).outcome.FAILURE;                
                p.trial.(modName).counter = 0; % JM 2025-03-21
                p.trial.(modName).reward.trial.amount = 0; % JM 2025-03-21
                
            case p.trial.(modName).response.HELD_FIXATION
                
                p.trial.(modName).outcome.trialOutcome = p.trial.(modName).outcome.SUCCESS;
                counter = counter + 1; % JM 2025-03-21
                p.trial.(modName).counter = counter; % JM 2025-03-21
                if counter == 1
                    p.trial.(modName).reward.trial.amount = 1 * p.trial.(modName).reward.amount;
                elseif counter == 2
                    p.trial.(modName).reward.trial.amount = 2 * p.trial.(modName).reward.amount;
                elseif counter == 3
                    p.trial.(modName).reward.trial.amount = 4 * p.trial.(modName).reward.amount;
                elseif counter >= 4
                    p.trial.(modName).reward.trial.amount = 8 * p.trial.(modName).reward.amount;
                end
        end
        
        
        % in case of using audible feedback, determine appropriate feedback
        % based on p.trial.custom.outcome
        if(p.trial.sound.use)
            switch p.trial.(modName).outcome.trialOutcome
                case p.trial.(modName).outcome.SUCCESS
                    %PsychPortAudio('Start', p.trial.sound.reward,    1, [], [], GetSecs + 0.2);
                    PsychPortAudio('Start', p.trial.sound.reward,    1, [], [], []);
                case p.trial.(modName).outcome.FAILURE
                    PsychPortAudio('Start', p.trial.sound.incorrect, 1, [], [], GetSecs + 1);
%                     PsychPortAudio('Start', p.trial.sound.incorrect, 1, [], [], []);
                case p.trial.(modName).outcome.BREAK_FIX
                    PsychPortAudio('Start', p.trial.sound.breakfix,  1, [], [], GetSecs + 1);         
%                     PsychPortAudio('Start', p.trial.sound.breakfix,  1, [], [], []);         
            end
        end
        
        % in case of using drugs
        if(p.trial.newEraSyringePump.use)
            p.trial.behavior.reward.timeReward = nan(2,p.trial.behavior.reward.iReward);
            switch p.trial.(modName).outcome.trialOutcome
                case p.trial.(modName).outcome.SUCCESS
                    
                    pds.newEraSyringePump.give(p, p.trial.(modName).reward.trial.amount);
                    
                case p.trial.(modName).outcome.FAILURE
                    
                case p.trial.(modName).outcome.BREAK_FIX 
                    
            end
        end
        
        S.(modName).gaze.x_gain             = p.trial.(modName).gaze.x_gain;
        S.(modName).gaze.y_gain             = p.trial.(modName).gaze.y_gain;
        S.(modName).gaze.x_offset           = p.trial.(modName).gaze.x_offset;
        S.(modName).gaze.y_offset           = p.trial.(modName).gaze.y_offset;
        S.(modName).gaze.gain_step_size     = p.trial.(modName).gaze.gain_step_size;
        S.(modName).gaze.offset_step_size   = p.trial.(modName).gaze.offset_step_size;
        
        % always update trial matrix 
        % update visited trials with PLDAPS trial index
        pdsTrialColumnIndex     = S.trialMatrix_index.PDS_DATA_INDEX;
        S.trialMatrix(p.trial.(modName).sessionTrialIndex, pdsTrialColumnIndex) = p.trial.pldaps.iTrial;

        % update response column
        respColumnIndex     = S.trialMatrix_index.RESPONSE;
        S.trialMatrix(p.trial.(modName).sessionTrialIndex, respColumnIndex) = p.trial.(modName).response.subjectResponse;
        
        % update counter column
        counterColumnIndex = S.trialMatrix_index.COUNTER; % JM 2025-03-21
        S.trialMatrix(p.trial.(modName).sessionTrialIndex, counterColumnIndex) = p.trial.(modName).counter; % JM 2025-03-21
        
        % update reward column
        rewardColumnIndex = S.trialMatrix_index.REWARD; % JM 2025-03-21
        S.trialMatrix(p.trial.(modName).sessionTrialIndex, rewardColumnIndex) = p.trial.(modName).reward.trial.amount; % JM 2025-03-21

        % update successful trial counts
        clf; axis off;
        p.trial.(modName).successfulTrialCount = nansum(S.trialMatrix(:, respColumnIndex) == p.trial.(modName).response.HELD_FIXATION);
        progress_text = sprintf('Session index: %d, iTrial: %d, Success: %d, Total: %d', p.trial.(modName).sessionTrialIndex, p.trial.pldaps.iTrial, p.trial.(modName).successfulTrialCount, length(p.conditions));
        text(0, 0.5, progress_text, 'fontsize', 20); drawnow;

        save(filepath, 'S');

        p.trial.(modName).sessionTrialIndex = p.trial.(modName).sessionTrialIndex + 1;

        % update session info (in case of crashes)
        sessionFolder                           = ['./Data/', datestr(now, 'mm-dd-yyyy'), '/'];
        sessionFilePath                         = [sessionFolder, 'sessionInfo.mat'];
        load(sessionFilePath, 'session');
        session.sessionTrialIndex               = p.trial.(modName).sessionTrialIndex;
        save(sessionFilePath, 'session');
        
        % ITI
        switch p.trial.(modName).outcome.trialOutcome
            case p.trial.(modName).outcome.SUCCESS
                WaitSecs(p.trial.(modName).ITI);
                
            case p.trial.(modName).outcome.FAILURE
                WaitSecs(p.trial.(modName).ITI + .6);
                
            case p.trial.(modName).outcome.BREAK_FIX
                WaitSecs(p.trial.(modName).ITI + 2); 

        end
        
        % clear figure
        clf;
        
        
    % EXPERIMENT SESSION STATES 
    % --------------------------------------------------------------------%     
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % send digital event to plexon rig to indicate session started
        if(p.trial.datapixx.use)
            Straightening.sendDigitalEvent( 2^10-1, 2^4-1);
        end
        
        % This state gets called exactly once after the screen was opened 
        % (and after the specifyExperiment file got called). 
        % This is a good place to define textures.
        filepath        = p.trial.TRIAL_MATRIX_FILEPATH;
        load(filepath, 'S'); % 'S' is the struct that contains experiment info
        
        % start from where we left off
        sessionFolder                           = ['./Data/', datestr(now, 'mm-dd-yyyy'), '/'];
        sessionFilePath                         = [sessionFolder, 'sessionInfo.mat'];
        load(sessionFilePath, 'session');
        p.trial.(modName).sessionTrialIndex     = session.sessionTrialIndex;
       
        % generate image textures for this session
        p = Straightening.generateImageStimuli(p);
        
        % separate figure to keep track of session
        figure(100); hold on; axis off;
        
    case p.trial.pldaps.trialStates.experimentCleanUp
        % note: this is used when p.trial.pldaps.useModularStateFunctions
        % is set to 'true'.
        
        % send digital event to plexon rig to indicate session ended
        if(p.trial.datapixx.use)
            Straightening.sendDigitalEvent( 2^10-1, 2^4-1);
        end
        
        
end

end