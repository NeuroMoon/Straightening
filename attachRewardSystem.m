
   
function p = attachRewardSystem(p)
% ATTACHREWARDSYSTEM specifies the h/w port to allow PLDAPS to communicate 
% with newEraSyringePump. 
%
% For additional troubleshooting: 
% You can check if the h/w port is responding appropriately. Run the
% following three lines:
% >> spec        = 'BaudRate=19200 DTR=1 RTS=1 ReceiveTimeout=1'; %
% low-level h/w specs.
% >> port        = '/dev/cu.usbserial-AH05SQV4';
% >> [h, errmsg] = IOPort('OpenSerialPort',port,spec); % if things go well,
% you won't see any warning or error message. If you see an error message,
% look into 'errmsg' and start googling.


% You'll need to make sure that newEraSyringePump is used in createRigPrefs
% Look under 'newEraSyringePump.use'. Set this to 'true'. 
%
% In case you're having a hard time with 'createRigPrefs()', un-comment the
% following line.
% p.trial.newEraSyringePump.use = true;

if(p.trial.newEraSyringePump.use)
    p.trial.newEraSyringePump.allowNewDiameter = 1;
    p.trial.newEraSyringePump.port='/dev/cu.usbserial-AH061MI4';
   
end
% if 'newEraSyringePump.use' is false and you setup the rewards system,
% PLDAPS will produce an error. 

end