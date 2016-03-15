function PassiveUpmix(inputFile)
    outputFile = makeOutputFileName(inputFile,'psv_mix');
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

    fprintf('Aplying passive matrix\n');
    upMix = PassiveMatrix(inL, inR);
    % upMix is a Lx6 matrix [left, right, centre, LFE, rearleft, rearright]
    
    upMix = filtersAndDelay(upMix, Fs);
    
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
    outputFile = [fileName(1:last_dot-1) '_' mix '.flac'];
end