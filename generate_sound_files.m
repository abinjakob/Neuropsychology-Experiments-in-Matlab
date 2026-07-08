% GENERATE SOUND FILES
% --------------------
% 
% This script generates an audio file consisting of short sine tones
% repeated at user-defined intervals for a specified duration. The audio is
% saved as a WAV file to the specified output location.
%
% author:   Abin Jacob 
%           Translational Psychology Lab
%           Carl von Ossietzky Universität Oldenburg
%           abin.jacob@uni-oldenburg.de
% date  :   08/07/2026

clear; clc; close all; 




% --------------- Parameters ------------------------

fs            = 44100;    % sampling rate (Hz)
totalDuration = 600;      % total duration (sec) 
interval      = 3;        % time between tones (sec)

toneFreq      = 1000;     % tone frequency (Hz)
toneDuration  = 0.1;      % tone duration (sec)
amplitude     = 0.8;      % tone amplitude (0-1)

% save as 
savepath = 'L:\Cloud\T-PsyOL\PhD Project\nEEGlace\Generate Sounds\audio_files'; ;  

% -----------------------------------------------------




% generate tone
t = (0:1/fs:toneDuration-1/fs)';
tone = amplitude * sin(2*pi*toneFreq*t);
% insert tone every 3 seconds
toneStarts = 0:interval:(totalDuration - toneDuration);
audio = zeros(totalDuration * fs, 1);
for k = 1:length(toneStarts)
    startSample = round(toneStarts(k) * fs) + 1;
    endSample = startSample + length(tone) - 1;

    if endSample <= length(audio)
        audio(startSample:endSample) = tone;
    end
end

% save as WAV
filename = ['sine_beep_every_', num2str(interval),'_sec.wav'];
filepath = fullfile(savepath, filename); 
audiowrite(filepath, audio, fs);

fprintf('Saved "%s"\n', filename);
fprintf('Duration: %.1f minutes\n', totalDuration/60);

