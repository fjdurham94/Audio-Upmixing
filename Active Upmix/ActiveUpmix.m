function ActiveUpmix(inputfile)
    % This active surround sound upmixing method aims to improve on the
    % resultant output of the passive upmixing matrix
    
    [input, Fs] = audioread(inputfile);
    % Define a frame size
    F_SIZE = 882; %corresponds to a frame length of 20ms at 44100Hz Fs
    
    % Find the dominance vector
    start_frame = 1;
    frame = input(start_frame*F_SIZE : start_frame*F_SIZE+F_SIZE,:);
    frame = log(abs(frame)); % log of full wave rectified sample values
    
    %biplot(frame)
    %clf;
    scatter(frame(:,1), frame(:,2), '.g');
    hold on; xlabel('L'); ylabel('R');
    scatter(mean(frame(:,1)), mean(frame(:,2)), 'xm');
    % Adjust axis
    ax = gca;
    axis equal;
    ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    ax.XLim = [-10 10]; ax.YLim = [-10 10];
    
    % Dominance bipolar control signal
    Elr = frame(:,1) - frame(:,2);
end