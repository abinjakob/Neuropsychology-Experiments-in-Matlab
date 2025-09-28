%% SELF MADE SOUNDS TASK WITH LSL MARKERS
% -----------------------------------------
% This Task involves making random sounds manually (eg. tapping on desk, glass etc.)
% for a fixed period of time. This script creates a marker stream via LSL to indicate 
% the start ('start') and end ('end') of the experiment.
%
% Pre-requisits:
% - LabStreamingLayer (LSL) MATLAB interface
% - Psychtoolbox (with PsychPortAudio enabled)
%
% Author(s) : Abin Jacob
%             Translational Psychology Lab
%             Carl von Ossietzky Universität Oldenburg
%             abin.jacob@uni-oldenburg.de 
% Date      : 26/09/2025
% --------------------------------------------------

clear; clc; close all;

% ------------------------------------------------------------------------
% ----------------------------- SCRIPT SETUP -----------------------------

startwait   = 20;    % initial wait period before experiment begins in seconds
expduration = 180;    % total duration of experiment in seconds

% ------------------------------------------------------------------------

% initialize LSL
disp('Loading LSL library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info   = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
outlet = lsl_outlet(info);

% PsychPortSetup
InitializePsychSound(1);                    % 1 = low-latency mode
fs         = 44100;                         % sampling rate
nrchannels = 1;                             % mono
pahandle   = PsychPortAudio('Open', [], 1, 1, fs, nrchannels);

% beep tone to indicate start & end of the experiment
amp      = 0.5;                          
duration = 0.2;                   
freq     = 880;  
t        = 0:1/fs:duration;
soundData = amp * sin(2*pi*freq*t); 
soundData = soundData(:)';                  % row
soundData = repmat(soundData, nrchannels,1);% channels x samples

% pause between start
disp(['Experiment will begin in ',num2str(startwait),' sec...']);
WaitSecs(startwait);



% -- main task loop --
% start experiment
PsychPortAudio('FillBuffer', pahandle, soundData);
PsychPortAudio('Start', pahandle, 1, 0, 1);
outlet.push_sample({'start'});
disp('Experiment Started');
WaitSecs(duration); % wait until beep finishes

% run for experiment duration
WaitSecs(expduration);

% end experiment
PsychPortAudio('FillBuffer', pahandle, soundData);
PsychPortAudio('Start', pahandle, 1, 0, 1);
outlet.push_sample({'end'});
disp('Experiment Complete');
WaitSecs(duration);

% cleanup
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);


