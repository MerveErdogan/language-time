%Language advantage on time perception, integer
%with verbal command


sca;
close all;
clearvars;
clear;
Screen('Preference', 'SkipSyncTests', 1);

%% Get participant information
prompt = {'Subject Number', 'Gender',  'Age', 'Right_handed','C'};  %if type == 1, without verbal command (i.e., type==2) with verbal command
defaults = {'99',  'f', '99', 'y','00'};
answer = inputdlg(prompt, 'Experimental Setup Information', 1, defaults);
[subject, gender, age, handedness, condition] = deal(answer{:});

PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%variables
time = [1.8, 2, 2.2, 2.4, 2.6, 2.8,3, 3.2, 3.4, 3.6, 3.8, 4, 4.2]; %13 stimuli
trainingTrial = 5;
experimentTrial = 65; %each stimuli are asked 5 times, total trial
produr = zeros(1,experimentTrial); %produced time by the participant
iti = zeros(1,experimentTrial); % Target ITI intertrial interval
trialtime = zeros(1,experimentTrial); % total trial duration
trialtimeTraining = zeros(1,trainingTrial);% total trial duration training
waitFrames = 1; % Number of frames to wait when specifying good timing. 1 means we flip every frame. default is 1.
lickRT = zeros(1,experimentTrial); %clickRT as its name suggests
lickRTTraining = zeros(1,trainingTrial); %clickRT as its name suggests for training phase
produrtraining = zeros(1,trainingTrial); %produced duration in training phase

%% fixation cross variables size should change
fixCrossDim = 20; %fixation cross dimension in pixels %%
fixlineWidth = 2; %fixation cross line width in pixels
fixCrossx = [-fixCrossDim fixCrossDim 0 0]; %fixation cross x coordinates
fixCrossy = [0 0 -fixCrossDim fixCrossDim]; %fixation cross y coordinates
allFixCoord = [fixCrossx; fixCrossy]; %all fixation cross coordinates

%% All text variables (instructions etc...)
myText = ['Merhaba!', '\n\n', ...
    'Bu deneyde sizden ekranda belirecek olan mavi kare ile gosterilen belirli', '\n', ...
    'bir sureyi klavyedeki bosluk tusunu kullanarak yeniden uretmenizi istiyoruz.', '\n\n\n', ...
    'Her denemenin basinda goreceginiz mavi karenin ekranda kalma suresini', '\n', ...
    'hedef sure olarak dusunmenizi isteyecegiz ve deney boyunca bu hedef sureyi', '\n', ...
    'mumkun oldugunca dogru bir sekilde yeniden uretmenizi bekleyecegiz.', '\n\n\n', ...
    'Devam etmek icin SPACE tusuna basin!']; %reproduction without verbal command
myTextv = ['Merhaba!', '\n\n', ...
    'Bu deneyde sizden ekranda belli bir miktarlarda sure uretmeniz istenecek', '\n', ...
    'bu sureyi klavyedeki bosluk tusunu kullanarak yeniden uretmenizi istiyoruz.', '\n\n\n', ...
    'Her denemenin basinda size uretmeniz soylenen süreyi', '\n', ...
    'hedef sure olarak dusunmenizi isteyecegiz ve deney boyunca bu hedef sureyi', '\n', ...
    'mumkun oldugunca dogru bir sekilde yeniden uretmenizi bekleyecegiz.', '\n\n\n', ...
    'Devam etmek icin SPACE tusuna basin!']; %production with verbal command
noCountWarn = ['Onemli hatirlatma: Deney boyunca saymayin, ritim tutmayin ve', '\n', ...
    'zaman araliklarini tahmin ederken herhangi bir strateji gelistirmeyin.', '\n\n\n\n', ...
    'Devam etmek icin SPACE tusuna basin!'];
startMessage = ('\n\n\n\n\n\nHazir oldugunuzda SPACE tusuna basarak deneyi baslatabilirsiniz!');
targetDurMessage = ('\n\n\n\n\n\nHedef sureyi gormek icin SPACE tusuna basin!');
instructions1={myText, noCountWarn, startMessage}; %for non-verbal reproduction
instructions2 ={myTextv, noCountWarn, startMessage}; %for verbal production
reproMessage = ('\n\n\n\n uretimi baslatmak icin SPACE tusuna basin ve hedef surenin \n gectigini dusundugunuzde SPACE tusuna ikinci kez basin.');
% Text font, etc..
textFont = 'Courier'; %our text font
textSize = 35;
textStyle = 1;
%% Screen variables
Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
[resx, resy] = Screen('WindowSize',screenNumber); %screen size in pixels
xCenter = .5*resx;
yCenter = .5*resy;
%% Useful color definitions
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
blue =  [0 0 1];
[win, windowRect] = PsychImaging('OpenWindow',screenNumber, black);
topPriorityLevel = MaxPriority(win);
rectDim = [0 0 200 200]; %rectangle dimensions.
centeredRect = CenterRectOnPointd(rectDim,xCenter,yCenter); % Center the rectangle on the centre of the screen using fractional pixel
%% Query the frame duration
ifi = Screen('GetFlipInterval', win); %ifi is the inter frame interval, i.e., how much it takes to flip to the next screen after a key press
nStimulusFrames = round(time(randperm(numel(time)))/ifi);
%TextVariables
Screen('TextSize', win, textSize);
Screen('TextFont', win, textFont);
Screen('TextStyle', win, textStyle);
%% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA')
%% Here we give the instructions for the nonverbal part
HideCursor;
ListenChar;
[keyIsDown, keyPressTime, KeyCode] = KbCheck;
RestrictKeysForKbCheck((44));% participants can only use the space bar unless they are asked to do otherwise (e.g. mouse) to respond throughout the experiment
for instruction = instructions1

ListenChar(1);
DrawFormattedText(win, instruction{:},...
                  'center', resy * 0.25, white);
Screen('Flip', win);
WaitSecs(0.5);
KbWait;
end
%% Training
DrawFormattedText(win, '\n\n\n\n\n\nsimdi kisa bir deneme yapacagiz.', 'center', resy*0.25, white);
Screen('Flip',win);
WaitSecs(0.5);
KbWait;
%% FOR NONVERBAL. We are still in the training phase. Here we repeatedly present the target duration.
for targetFamiliarization = 1:trainingTrial; %should be 5. here we are trying to familiarize the participant with our target duration by displaying it many times repeatedly
ListenChar(1);
DrawFormattedText(win, targetDurMessage, 'center',resy*0.25,[127 255 0]);
Screen('Flip',win);
WaitSecs(0.5);
KbWait;
vblImageTra = Screen('Flip',win);
tic %to assure the precision of target duration. tic-toc results should be around ~3.2
for i=1:nStimulusFrames
Screen('FillRect',win,blue,centeredRect);
vblImageTra = Screen('Flip',win, vblImageTra + (waitFrames - 0.5)*ifi);
end
toc
Screen('Close');

end
DrawFormattedText(win,'\n\n\n\n\n\nSimdi sizden hedef sureyi tekrar uretmenizi isteyecegiz. \n\n<devam etmek icin SPACE tusuna basin.>','center',resy*0.25,white);
Screen('Flip',win);
KbWait;
%% Still training. Here, we also ask the participant to reproduce the target duration and report confidence and error direction
for trainingTrials = 1:trainingTrial %should be 4 or 5

ListenChar(1);
DrawFormattedText(win, targetDurMessage, 'center',resy*0.25,[127 255 0]);
Screen('Flip',win);
WaitSecs(0.5);
KbWait;
%Target duration with black square
vblNoise= Screen('Flip',win);
for j = 1:nStimulusFrames
Screen('FillRect',win,blue,centeredRect);
vblNoise= Screen('Flip',win, vblNoise + (waitFrames - 0.5)*ifi);
end
Screen('Close');

DrawFormattedText(win, reproMessage, 'center',resy*0.25, white);
Screen('Flip',win);

keyIsDown = 0;
keyIsUpOnce = 0;
offsetTraining = 0;

while ~keyIsDown %key'e bas?ld? m? diye kontrol ediyoruz.
[keyIsDown, onsetTraining] = KbCheck;
end

Screen('FillRect',win,blue,centeredRect);
Screen('Flip',win);


keyIsDown = 0; %kald?rmas?n? bekleyece?im i?in tekrar keyisdown? s?f?ra e?itliyorum.
while ~keyIsDown || ~keyIsUpOnce    %kat?l?mc? ikinci tu?a basmad?g? s?rece kareyi g?ster. veya kat?l?mc? elini hi? kald?rmasa da g?ster
[keyIsDown, offsetTraining] = KbCheck();
if ~keyIsDown %katilimci kaldirdiysa
keyIsUpOnce = 1;
end
end

Screen('Flip',win);
Screen('Close'); %memory flush

reproDurTraining(trainingTrials) = offsetTraining-onsetTraining;
%fixation cross
Screen('DrawLines',win,allFixCoord,...
       fixlineWidth,white,[xCenter yCenter], 2);
Screen('Flip',win);
WaitSecs(0.5+rand());


Screen('Close'); %memory flush 05.08.2018
end
%% Experiment
DrawFormattedText(win,'Alistirma kismi bitti!. \n\n\n Lutfen arastirmaciyi cagirin.','center', resy*0.25, white);
Screen('Flip',win);
KbWait;
DrawFormattedText(win,'Simdi deneyin test kismina geciyoruz. \n\n\n Bu kisimda, alistirma kisminda yaptiginizin aynisini yapacaksiniz. \n\n Hedef sure her 5 denemede bir size hatirlatilacak. \n\n Hazir oldugunuzda deneye baslamak icin SPACE tusuna basin!','center', resy*0.25, white);
Screen('Flip',win);
WaitSecs(1); %otherwise, it flips immediately
KbWait;

vbl = Screen('Flip',win);

for trial = 1:experimentTrial
trialOnset = GetSecs;
DrawFormattedText(win, targetDurMessage, 'center',resy*0.25,[127 255 0]);
Screen('Flip',win);
WaitSecs(0.5);
KbWait;

vblRect= Screen('Flip',win);
for j = 1:nStimulusFrames

Screen('FillRect',win,blue,centeredRect);
vblRect=Screen('Flip',win, vblRect + (waitFrames - 0.5)*ifi);
end
Screen('Close');

%% Reproduction with the blue square
vblImage = Screen('Flip',win);
DrawFormattedText(win, reproMessage, 'center',resy*0.25,white);
Screen('Flip',win);
WaitSecs(0.3); %otherwise, it flips immediately to the next frame. 0.3 is just an arbitrarily set value of duration. the shorter the better

keyIsDownExp = 0;
keyIsUpOnceExp = 0;
offset = 0;

while ~keyIsDownExp %key'e basildi mi diye kontrol ediyoruz.
[keyIsDownExp, onset] = KbCheck;
end

Screen('FillRect',win,blue,centeredRect);
Screen('Flip',win);


keyIsDownExp = 0; %kaldirmasini bekleyecegim icin tekrar keyisdown sifira e?itliyorum.
while ~keyIsDownExp || ~keyIsUpOnceExp    %katilimci ikinci tusa basmadigi surece kareyi goster. veya katilimc? elini hic kaldirmasa da goster
[keyIsDownExp, offset] = KbCheck();
if ~keyIsDownExp %katilimci kaldirdiysa
keyIsUpOnceExp = 1;
end
end

Screen('Flip',win);
Screen('Close'); %memory flush

reproDur(trial) = offset-onset;


t_end=GetSecs;
iti(trial)=t_end-trialTermination;
Screen('Close'); %memory flush, 05.08.2018. if shit gets deleted, blame this row.
end
