function PassiveUpmix(inputFile)
    outputFile = makeOutputFileName(inputFile,'5_1_mix');
    outputFile_2_1 = makeOutputFileName(inputFile,'2_1_mix');
    %Passive Upmix from 2 channel to 5.1 surround

    %Set up AudioPlayer object
    %H = dsp.AudioPlayer;
    %H.DeviceName = 'USB Sound Device'; %My 5.1 soundcard
    %set(H,'ChannelMappingSource','Property');
    %H.ChannelMapping = [1 2 4 3 5 6]; %This then matches the FileWriter
    %flac ouput

    %Read in an audio file
    fprintf('Reading file [%s]\n', inputFile);
    [input,Fs]=audioread(inputFile);

    inL=input(:,1);
    inR=input(:,2);

    upMix = PassiveMatrix(inL, inR, Fs);
    % upMix is a Lx6 matrix [left, right, centre, LFE, rearleft, rearright]
    
    % 90phase shift on the rear pair
    fprintf('Applying phase shift to surround channel\n');
    upMix(:,5) = imag(hilbert(upMix(:,5))); % The imaginary part of a hilbert transform is a +90 degree phase shift of the original
    upMix(:,6) = -upMix(:,5);
    
    % LPF applied to surround channel to give the idea of the sound being
    % further away. 7Khz taken from Dolby Pro Logic operation section 1.2
    fprintf('Applying 7kHz LPF to surround channels\n');
    lpfspec7kHz = fdesign.lowpass('Fp,Fst,Ap,Ast',7000,7500,0.1,50,Fs); % Generates LPF specification object
    lpf7kHz = design(lpfspec7kHz, 'equiripple'); % Creates filter from specification obj
    upMix(:,5) = filter(lpf7kHz, upMix(:,5));
    upMix(:,6) = filter(lpf7kHz, upMix(:,6));
    
    %version with L R and Sub for comparison
    z = zeros(size(inL));
    mix2_1 = [inL, inR, z, upMix(:,4), z, z];

    %dsp.AudioFileWriter to save as a 5.1 flac
    fprintf('Writing 5.1 mix to file [%s]\n' ,outputFile);
    FW = dsp.AudioFileWriter(outputFile, 'FileFormat', 'FLAC');
    step(FW, upMix);
    release(FW);
    
    fprintf('Writing 2.1 mix to file [%s]\n' ,outputFile_2_1);
    FW = dsp.AudioFileWriter(outputFile_2_1, 'FileFormat', 'FLAC');
    step(FW, mix2_1);
    release(FW);
    
    %Play out the upmix
    %step(H,upMix);
    %{
    %function to play the output file
    playFile('output.flac')
    %}
    
    fprintf('DONE!\n');
end

function outputFile = makeOutputFileName(fileName,mix)
    dot_locs = strfind(fileName,'.');
    last_dot = dot_locs(end);
    outputFile = [fileName(1:last_dot-1) mix '.flac'];
end