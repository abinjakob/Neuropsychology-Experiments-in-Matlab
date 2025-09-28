%% SILENT SPEECH TASK WITH LSL MARKERS
% ------------------------------------
% This Shows fixation cross for 1s, then displays "Ka" for 1s.
% During "Ka", sends an LSL marker with precise flip timestamp.
% Repeats for 40 trials. ESC exits anytime.

clear; clc; close all;

% ------------------------------------------------------------------------
% ----------------------------- SCRIPT SETUP -----------------------------

nTrials = 60;                       % total number of trials
minITI = 2;                         % minimum inter trial interval
fixDuration = 2;                    % fixation duration (s)
textDuration  = 2;                  % text display duration (s)
startwait = 20;                     % initial wait period before experiment begins (s)

% ------------------------------------------------------------------------


% initialize LSL
disp('Loading LSL library...');
lib = lsl_loadlib();
disp('Creating marker stream...');
info   = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','fixcross_ka');
outlet = lsl_outlet(info);

% pause between start
disp(['Experiment will begin in ',num2str(startwait),' sec...']);
WaitSecs(startwait);

% screem setup
Screen('Preference','SkipSyncTests',1);
[win, winRect] = Screen('OpenWindow', max(Screen('Screens')), [128 128 128]);
[xCenter, yCenter] = RectCenter(winRect);

% fixation cross
crossLength = 40; crossColor = [0 0 0]; crossWidth = 4;

% text to display
Screen('TextSize', win, 100); textColor = [0 0 0];

% key to exit experiment
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');

% -- main task loop --
try
    % display task name
    DrawFormattedText(win, 'Silent Speech Task', 'center', 'center', textColor);
    vbl = Screen('Flip', win);           
    outlet.push_sample({'SS'});     
    waitOrEscape(3, escapeKey);

    % pasuse before start
    DrawFormattedText(win, '', 'center', 'center', textColor);
    vbl = Screen('Flip', win); 
    iti = minITI + rand;
    waitOrEscape(2, escapeKey);

    for trial = 1:nTrials

        if rand > .5
            text2show = 'Ka';
        else
            text2show = 'Pa';
        end
        
        % show fixation cross
        Screen('DrawLine', win, crossColor, xCenter-crossLength, yCenter, xCenter+crossLength, yCenter, crossWidth);
        Screen('DrawLine', win, crossColor, xCenter, yCenter-crossLength, xCenter, yCenter+crossLength, crossWidth);
        Screen('Flip', win);
        waitOrEscape(fixDuration, escapeKey);
        
        % show text and send LSL marker
        DrawFormattedText(win, text2show, 'center', 'center', textColor);
        vbl = Screen('Flip', win);           
        outlet.push_sample({text2show});     
        waitOrEscape(textDuration, escapeKey);

        % ITI with random time
        DrawFormattedText(win, '', 'center', 'center', textColor);
        vbl = Screen('Flip', win); 
        iti = minITI + rand;
        waitOrEscape(iti, escapeKey);
    end
    
catch ME
    disp(ME.message);
end

% clean up
sca;
disp('Experiment ended.');


% define local functions
% function to allow quiting experiment with 'ESC'
function waitOrEscape(duration, escapeKey)
    tStart = GetSecs;
    while (GetSecs - tStart) < duration
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && keyCode(escapeKey)
            error('User pressed ESC. Exiting experiment.');
        end
        WaitSecs(0.01); % avoid busy-waiting
    end
end
