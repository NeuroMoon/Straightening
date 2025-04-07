function sendDigitalEvent( trialNum, myEvent)

% INPUTS
%   bitmask             - allocate 1 bit (most significant bit, bit# 15): 
%                      NOTE: 15-th bit will always be high to distinguish
%                       this as a custom event, and not a PLDAPS event. 
%   trialNum            - allocate 10 bits (bits 0-9) 
%                       NOTE: accommodates (2^10) trials
%   myEvent             - allocate 4  bits (bits 12-15)
%                       NOTE: accommodates (2^4) unique events
% OUTPUTS
%   timings            - timestamps of the strobed word
%

% consider bit positions as '0' indexed. Subtract one from the bit position  
% Bit mask to distinguish trial number.
bitMask     = bitshift(2^0, (15-1)); % 15th bit position
word        = bitshift(mod(trialNum, 2^10), 4) + mod(myEvent,2^4);
word        = word + bitMask;

% %Set bits to zero in case things don't reset (and in case the user
% %forgets to set the mode to 3)
% % Datapixx('SetDoutValues',0,2^16)
% % Datapixx('RegWr');
% Datapixx('SetDoutValues',0)
% Datapixx('RegWr');

%first we set the bits without the strobe, to ensure they are all
%settled when we flip the strobe bit (plexon need all bits to be set
%100ns before the strobe)
Datapixx('SetDoutValues',word);
Datapixx('RegWr');

%now add the strobe signal. We could just set the strobe with a bitmask,
%but computational requirements are the same (due to impememntation on
%the Datapixx side)
Datapixx('SetDoutValues',2^16 + word);
Datapixx('RegWr');

%Set bits to zero in case things don't reset (and in case the user
%forgets to set the mode to 3)
% Datapixx('SetDoutValues',0,2^16)
% Datapixx('RegWr');
Datapixx('SetDoutValues',0)
Datapixx('RegWr');

% % consider bit positions as '0' indexed. Subtract one from the bit position  
% % Bit mask to distinguish trial number.
% bitMask     = 2^(15-1); % 15th bit position
% word        = mod(trialNum, 2^10)*2^4 + mod(myEvent,2^4);
% word    = word + bitMask;
% 
% 
% %first we set the bits without the strobe, to ensure they are all
% %settled when we flip the strobe bit (plexon need all bits to be set
% %100ns before the strobe)
% Datapixx('SetDoutValues',word);
% Datapixx('RegWr');
% 
% %now add the strobe signal. We could just set the strobe with a bitmask,
% %but computational requirements are the same (due to impememntation on
% %the Datapixx side)
% Datapixx('SetDoutValues',2^16 + word);
% Datapixx('RegWr');
% 
% %Set bits to zero in case things don't reset (and in case the user
% %forgets to set the mode to 3)
% Datapixx('SetDoutValues',0,2^16)
% Datapixx('RegWr');
% Datapixx('SetDoutValues',0)
% Datapixx('RegWr');

%{
if nargout==0
    %first we set the bits without the strobe, to ensure they are all
    %settled when we flip the strobe bit (plexon need all bits to be set
    %100ns before the strobe)
    Datapixx('SetDoutValues',word);
    Datapixx('RegWr');
    
    %now add the strobe signal. We could just set the strobe with a bitmask,
    %but computational requirements are the same (due to impememntation on
    %the Datapixx side)
    Datapixx('SetDoutValues',2^16 + word);
    Datapixx('RegWr');
    
    %Set bits to zero in case things don't reset (and in case the user
    %forgets to set the mode to 3)
    Datapixx('SetDoutValues',0,2^16)
    Datapixx('RegWr');
    Datapixx('SetDoutValues',0)
    Datapixx('RegWr');
else
    t=nan(2,1);
    oldPriority=Priority;
    if oldPriority < MaxPriority('GetSecs')
            Priority(MaxPriority('GetSecs'));
    end
    Datapixx('SetDoutValues',word);
    Datapixx('RegWr');

    Datapixx('SetDoutValues',2^16 + word);
    Datapixx('SetMarker');
    
    t(1)=GetSecs;
    Datapixx('RegWr');
    t(2)=GetSecs;
    
    Datapixx('SetDoutValues',0,2^16)
    Datapixx('RegWrRd');
    dpTime=Datapixx('GetMarker');
    
    Datapixx('SetDoutValues',0)
    Datapixx('RegWr');

    if Priority ~= oldPriority
            Priority(oldPriority);
    end
    
    timings=[mean(t) dpTime diff(t)];
end
%}

