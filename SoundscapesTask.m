%% PLAY SOUNDSCAPE AUDIO FILES WITH LSL MARKERS
% ---------------------------------------------
% This script plays all soundscape (MP3) files in a specified folder using 
% Psychtoolbox's PsychPortAudio and sends a marker via LSL immediately before 
% each playback.
%
% Pre-requisits:
% - LabStreamingLayer (LSL) MATLAB interface
% - Psychtoolbox (with PsychPortAudio enabled)
%
% Author(s) : Abin Jacob
%             Translational Psychology Lab
%             Carl von Ossietzky Universität Oldenburg
%             abin.jacob@uni-oldenburg.de 
% Date      : 25/09/2025
% --------------------------------------------------

clear; clc; close all;

% ------------------------------------------------------------------------
% ----------------------------- SCRIPT SETUP -----------------------------

% path to audio files
audiofolder = 'C:\Users\messung\Desktop\Mentalab-Pilots\Paradigms\auido_files';

% initial wait period before experiment begins 
startwait = 20;        

% ------------------------------------------------------------------------


% initialize LSL
disp('Loading LSL library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
outlet = lsl_outlet(info);

% read audio file names from folder
fileList = dir(fullfile(audiofolder, '*.mp3'));
if isempty(fileList)
    error('No MP3 files found in folder: %s', audiofolder);
end

% initialize PsychPortAudio
InitializePsychSound(1); % Request low-latency mode

% pause between start
disp(['Experiement will begin in ',num2str(startwait),' sec...']);
WaitSecs(startwait);



% -- main task loop -- 
for k = 1:length(fileList)
    % load file
    filePath = fullfile(audiofolder, fileList(k).name);
    [audioData, fs] = audioread(filePath);
    audioData = audioData';  % [channels x samples]
    nrchannels = size(audioData,1);

    % open device for this file's sample rate & channels
    pahandle = PsychPortAudio('Open', [], 1, 1, fs, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, audioData);

    % send file name as marker via LSL
    [~, marker, ~] = fileparts(fileList(k).name);
    disp(['Sending marker: ' marker]);
    outlet.push_sample({marker});

    % start playback
    startTime = PsychPortAudio('Start', pahandle, 1, 0, 1);
    disp(['Playback started for ' marker ' at time: ' num2str(startTime)]);

    % wait until finished
    PsychPortAudio('Stop', pahandle, 1);
    PsychPortAudio('Close', pahandle);

    % pause between files
    WaitSecs(1);
end

PsychPortAudio('Close');
disp('All files played successfully.');

