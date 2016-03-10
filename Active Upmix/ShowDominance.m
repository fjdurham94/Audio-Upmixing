
    % Use the dominance detection techniques as found in the active upmixer
    % and visualise the results in a plot.
%     close all;
%     clear all;
    inputFile = 'TestClips/ADITL_clip_psv_mix.flac';
    
    
    [input, Fs] = audioread(inputFile);
    % Define a frame size
    F_SIZE = 882*20; %corresponds to a frame length of 20ms at 44100Hz Fs
    NFRAMES = floor(length(input)/F_SIZE);
    
    Erl = []; Ecs = [];
    start = 1;
    bar = waitbar(1/NFRAMES, 'Determining frame dominance...');
    % Apply passive matrix to each frame and detect dominant source
    bpfspec = fdesign.bandpass(100/Fs, 200/Fs, 1600/Fs, 2000/Fs, 50, 0.1, 50);
    bpf = design(bpfspec, 'equiripple');
    for current_frame = 1:NFRAMES % floor will need to be changed to zero pad
    %for current_frame = 1:5
        waitbar(current_frame/NFRAMES, bar, 'Determining frame dominance...');
        frame = input(start + (current_frame-1) * F_SIZE : F_SIZE * current_frame, :);
        frame = filter(bpf, frame);

        % Find the dominance vector
        frame_log = log(abs(frame)); % log of full wave rectified sample values
        
        %Clip L R C and S channels to avoid infinite dominance values
        frame_log(frame_log(:,1) < -10, 1)  = -10; % Left
        frame_log(frame_log(:,1) > 10, 1) = 10;
        frame_log(frame_log(:,2) < -10, 2)  = -10; % Right
        frame_log(frame_log(:,2) > 10, 2) = 10;
        
        frame_log(frame_log(:,3) < -10, 3)  = -10; % Centre
        frame_log(frame_log(:,3) > 10, 3) = 10;
        frame_log(frame_log(:,5) < -10, 5)  = -10; % Surround
        frame_log(frame_log(:,5) > 10, 5) = 10;

        Erl = [Erl; mean(frame_log(:,2) - frame_log(:,1))];
        Ecs = [Ecs; mean(frame_log(:,3) - frame_log(:,5))];
        
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
    
    %scatter(Erl, Ecs, '.b');
    
        
%     xlabel('L -> R'); ylabel('S -> C');
%     % Adjust axis
%     ax = gca;
%     axis equal;
%     ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
%     ax.XLim = [-10 10]; ax.YLim = [-10 10];
    
    theta = atan(Erl./Ecs);
    mag = sqrt(Erl.^2 + Ecs.^2);
    plot(theta);
    ax = gca;
    ax.XAxisLocation = 'origin';