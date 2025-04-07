function nextState = taskSequence(p, currentState)
% TASKSEQUENCE handles the state machine for the task according to the task
% sequence for the psychophysical experiment. Next state is determined by
% gaze and current state. Variables that track the current state of the
% subject is defined in 'defineVariables.m'.
%
% VARIABLES THAT WILL BE UPDATED HERE:
% 1. Next state
% 2. Timestamps indicating when the subject first entered each state: p.trial.(modName).states.timestamps
% 3. Response: p.trial.(modName).response
% 4. PLDAPS' "good trial": p.trial.pldaps.goodtrial
% 5. PLDAPS' variable for indicating the end of this trial: p.trial.finished
% 6. PLDAPS' variable to trigger next trial: p.trial.flagNextTrial;

% 2017-11-20  YB   wrote it. <yoonbai@utexas.edu>
%

% Identify the field where all of our custom variables reside (this will be
% useful for 'modular' PLDAPS).
modName     = p.trial.modName;

nextState	= nan;


switch currentState
    
    case p.trial.(modName).states.START
        delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.START;
        if(delta_t < (p.trial.(modName).states.duration.START))
            nextState   = p.trial.(modName).states.START;
        else
            nextState   = p.trial.(modName).states.FP_ON;
            p.trial.(modName).states.timestamps.FP_ON = p.trial.ttime;
            if(p.trial.datapixx.use)
                Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState);
            end
        end
        
        
    case p.trial.(modName).states.FP_ON
        % FP_ON is the initial state when the FP is presented. We'll wait
        % until monkey engages. The monkey might wander around, and we will
        % allow this up to a certain amount of time. This will be tracked
        % by a seprate timer to allow a longer period of waiting. 
        trial_delta_t   = p.trial.ttime - p.trial.(modName).states.timestamps.START;
        
        if(trial_delta_t < (p.trial.(modName).states.duration.MAX_TRIAL_DURATION))
            
            if(Straightening.isFixating(p)) 
                
                delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.FP_ON;
                % make sure this isn't an accidental eye drift
                if(delta_t < p.trial.(modName).states.duration.FP_ON)
                    nextState   = p.trial.(modName).states.FP_ON;
                else
                    nextState   = p.trial.(modName).states.FP_HOLD;
                    p.trial.(modName).states.timestamps.FP_HOLD = p.trial.ttime;
                    if(p.trial.datapixx.use)
                        Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState);
                    end
                    
                end
            else
                % we will be in this state until subject fixates
                nextState       = p.trial.(modName).states.FP_ON;
                % reset timestamp for next round of successful fixation during FP_ON
                p.trial.(modName).states.timestamps.FP_ON = nan;
            end
            
            p.trial.(modName).stimulus.fp.color.COLOR_INDEX = 7;
        else
            % we gave the monkey enough time to engage in the task, but the
            % monkey didn't want to do the task.
            nextState   = p.trial.(modName).states.TRIAL_COMPLETE;
            p.trial.(modName).response.subjectResponse = p.trial.(modName).response.NO_FIXATION;
            
        end
        
        
    case p.trial.(modName).states.FP_HOLD
        fp_hold_delta_t = p.trial.ttime - p.trial.(modName).states.timestamps.FP_HOLD; % lets say this can go up to 1.5 sec
        if  fp_hold_delta_t < 1.5
            if(Straightening.isFixating(p)) % while fixating...
                
                if isnan(p.trial.(modName).states.fix_hold_time)
                    delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.FP_HOLD;
                else
                    delta_t     = p.trial.ttime - p.trial.(modName).states.fix_hold_time;
                end
                if(delta_t < p.trial.(modName).states.duration.FP_HOLD  )
                    nextState   = p.trial.(modName).states.FP_HOLD;
                    sizePercentage = delta_t/(p.trial.(modName).states.duration.FP_HOLD );
                    p.trial.(modName).gaze.curr_window_radius_deg = p.trial.(modName).gaze.RADIUS_DEG + (1 - sizePercentage) * (p.trial.(modName).gaze.PRE_STIM_RADIUS_DEG - p.trial.(modName).gaze.RADIUS_DEG);
                else
                    % the monkey successfully held fixation - now neeeds to
                    % hold while stim on
                    nextState   = p.trial.(modName).states.IMG_ON;
                    p.trial.(modName).states.timestamps.IMG_ON = p.trial.ttime;
                    p.trial.(modName).gaze.curr_window_radius_deg = p.trial.(modName).gaze.RADIUS_DEG;
                    if(p.trial.datapixx.use)
                        Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState);
                    end
                end
                p.trial.(modName).stimulus.fp.color.COLOR_INDEX = 7;
            else
                p.trial.(modName).states.fix_hold_time = p.trial.ttime;
                nextState   = p.trial.(modName).states.FP_HOLD;
            end
        else % in this case, subject broke fixation.
            nextState   = p.trial.(modName).states.BREAK_FIX;
           % p.trial.finished        = true;
           % p.trial.(modName).response.subjectResponse = p.trial.(modName).response.BREAK_FIX;
           % p.trial.(modName).response.subjectSide = p.trial.(modName).response.INVALID;
           % p.trial.(modName).response.subjectConfidence = p.trial.(modName).response.INVALID;
        end
        
        
 
    case p.trial.(modName).states.IMG_ON
        if(Straightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.IMG_ON;
            
            if(delta_t > (p.trial.(modName).states.duration.IMG_ON))
                p.trial.(modName).response.subjectResponse = p.trial.(modName).response.HELD_FIXATION;
                nextState   = p.trial.(modName).states.FP_OFF;
                p.trial.(modName).states.timestamps.FP_OFF = p.trial.ttime;
                p.trial.(modName).states.current_frame_index=1;
                if(p.trial.datapixx.use)
                    Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState)
                end
            else
                nextState   = p.trial.(modName).states.IMG_ON;
                
                if delta_t> (p.trial.(modName).states.current_frame_index* p.trial.(modName).states.duration.FRAME) % if time elapsed greater than durration of frame- move onto next frame by increasing index
                    p.trial.(modName).states.current_frame_index= p.trial.(modName).states.current_frame_index+1;
                end
                
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
        
    case p.trial.(modName).states.FP_OFF
        if(Straightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.FP_OFF;
            
            if(delta_t > (p.trial.(modName).states.duration.FP_OFF))
                
                nextState   = p.trial.(modName).states.TRIAL_COMPLETE;
                if(p.trial.datapixx.use)
                    Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState);
                end
            else
                nextState   = p.trial.(modName).states.FP_OFF;
            end
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
            
        end
            
        
    case p.trial.(modName).states.TRIAL_COMPLETE
        % successfully ended trial, irrespective of response.
        % responses were already registered in previous states
        nextState                   = p.trial.(modName).states.TRIAL_COMPLETE;
        p.trial.pldaps.goodtrial    = true; 
        p.trial.finished            = true;
        p.trial.flagNextTrial       = true; % tell PLDAPS to start next trial
        p.trial.(modName).states.timestamps.TRIAL_COMPLETE = p.trial.ttime;
        
    case p.trial.(modName).states.BREAK_FIX
        nextState                   = p.trial.(modName).states.BREAK_FIX;
        p.trial.(modName).response.subjectResponse  = p.trial.(modName).response.BREAK_FIX;
        p.trial.pldaps.goodtrial    = false;  
        p.trial.finished            = true;
        p.trial.flagNextTrial       = true; % tell PLDAPS to start next trial
        p.trial.(modName).states.timestamps.BREAK_FIX = p.trial.ttime;
        if(p.trial.datapixx.use)
            Straightening.sendDigitalEvent( p.trial.pldaps.iTrial, nextState);
        end
        
    otherwise
        % you've entered an undefined state. This is a bug
        warning('YOU''VE REACHED AN UNDEFINED STATE IN taskSequenc.m!!');
        
end

end