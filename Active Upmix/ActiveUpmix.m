function ActiveUpmix(inputFile)
    % This active surround sound upmixing method aims to improve on the
    % resultant output of the passive upmixing matrix
    close all;
    clear all;
    inputFile = 'TestClips/UTB_clip.flac';
    
    [input, Fs] = audioread(inputFile);
    % Define a frame size
    F_SIZE = 882; %corresponds to a frame length of 20ms at 44100Hz Fs
    NFRAMES = floor(length(input)/F_SIZE);
    
    Erl = []; Ecs = [];
    start = 1;
    bar = waitbar(1/NFRAMES, 'Determining frame dominance...');
    % Apply passive matrix to each frame and detect dominant source
    for current_frame = 1:NFRAMES % floor will need to be changed to zero pad
    %for current_frame = 1:5
        waitbar(current_frame/NFRAMES, bar, 'Determining frame dominance...');
        frame = input(start + (current_frame-1) * F_SIZE : F_SIZE * current_frame, :);
        psv_matrix = PassiveMatrix(frame(:,1), frame(:,2));

        % Find the dominance vector
        frame_log = log(abs(psv_matrix)); % log of full wave rectified sample values
        
        %Clip L R C and S channels to avoid infinite dominance values
        frame_log(frame_log(:,1) < -10, 1)  = -10; % Left
        frame_log(frame_log(:,1) > 10, 1) = 10;
        frame_log(frame_log(:,2) < -10, 2)  = -10; % Right
        frame_log(frame_log(:,2) > 10, 2) = 10;
        
        frame_log(frame_log(:,3) < -10, 3)  = -10; % Centre
        frame_log(frame_log(:,3) > 10, 3) = 10;
        frame_log(frame_log(:,5) < -10, 5)  = -10; % Surround
        frame_log(frame_log(:,5) > 10, 5) = 10;

        Erl = [Erl; frame_log(:,2) - frame_log(:,1)];
        Ecs = [Ecs; frame_log(:,3) - frame_log(:,5)];
        
        %biplot(frame)
        %clf;
        % Scatter the log values on a 2D plot to visualise the dominance in the
        % frame, x axis is inverted so the left dominant points are on the left
        % of the y axis.
        
        %scatter(frame(:,2) - frame(:,1), frame(:,3) - frame(:, 5), '.g');
        %hold on; 
        %scatter(mean(frame(:,2) - frame(:,1)), mean(frame(:,3) - frame(:, 5)), 'xr');
        %fprintf('Mean frame(%i) dominance: L->R: %f, S->C: %f\n', current_frame, mean(frame(:,2) - frame(:,1)), mean(frame(:,3) - frame(:, 5)));
    end
    close(bar);
        
%     xlabel('L -> R'); ylabel('S -> C');
%     % Adjust axis
%     ax = gca;
%     axis equal;
%     ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
%     ax.XLim = [-10 10]; ax.YLim = [-10 10];

    % Normalise control signals Erl and Ecs
    Erl = Erl./max(abs(Erl));
    Ecs = Ecs./max(abs(Ecs));
    
    % Split bipolar controal signals into 4 unipolar signals by setting
    % one polarity to zero.
    Er = Erl; El = Erl;
    Er(Er<0) = 0;
    El(El>0) = 0;
    
    Ec = Ecs; Es = Ecs;
    Ec(Ec<0) = 0;
    Es(Es>0) = 0;
    
    % Combine control signals with original L and R to create Active Upmix
    %ouput.
    input = input(1:size(Er,1), :); % Temporary fix, need to process last few samples which aren't a entire frame.
    psv_matrix = PassiveMatrix(input(:,1), input(:,2));
    l = input(:,1); r = input(:,2);
    c = psv_matrix(:,3); s = psv_matrix(:,5);
    
    Lo = l - Er.*r - Er.*l;
    Ro = r - El.*l - El.*r;
    
    Co = c - Es.*s - Es.*c;
    So = s - Ec.*c - Ec.*s;
    
    % LFE is taken as the centre channel.
    upMix = [Lo, Ro, Co, Co, So, So];
    
    % Finally apply the LFP to LFE and surround as well as surround channel
    % phase delay.
    upMix = filtersAndDelay(upMix, Fs);
    
    % 2.1 mix for reference with sub.
    z = zeros(size(l));
    mix2_1 = [l, r, z, upMix(:,4), z, z];
    
    outputFile = makeOutputFileName(inputFile,'act_mix');
    outputFile_2_1 = makeOutputFileName(inputFile,'2_1_mix');
    %dsp.AudioFileWriter to save as a 5.1 flac
    fprintf('Writing 5.1 mix to file [%s]\n' ,outputFile);
    FW = dsp.AudioFileWriter(outputFile, 'FileFormat', 'FLAC');
    step(FW, upMix);
    release(FW);
    
    fprintf('Writing 2.1 mix to file [%s]\n' ,outputFile_2_1);
    FW = dsp.AudioFileWriter(outputFile_2_1, 'FileFormat', 'FLAC');
    step(FW, mix2_1);
    release(FW);
end

function outputFile = makeOutputFileName(fileName,mix)
    dot_locs = strfind(fileName,'.');
    last_dot = dot_locs(end);
    outputFile = [fileName(1:last_dot-1) '_' mix '.flac'];
end